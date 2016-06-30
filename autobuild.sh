#!/bin/bash -e

DATE=$(date +%Y%m%d)
SITES="mainz wiesbaden rheingau"

# Error codes
E_ILLEGAL_ARGS=126
E_ILLEGAL_TAG=127
E_DIR_NOT_EMPTY=128

# Help function used in error messages and -h option
usage() {
  echo ""
  echo "Autobuild script for Freifunk MWU Gluon firmware."
  echo "Use the seperater -- to pass options directly to build.sh"
  echo ""
  echo "-b: Firmware branch name: stable | testing | experimental"
  echo "-c: Start with a clean working dir"
  echo "-d: Enable bash debug output"
  echo "-h: Show this help"
  echo "-r: Release suffix number (default: 1)"
  echo "-s: Gluon sites to build (optional)"
  echo "    Default: \"${SITES}\""
  echo ""
}

# Evaluate arguments for build script.
while getopts b:cdhr:s: flag; do
  case ${flag} in
    d)
      set -x
      ;;
    h)
      usage
      exit
      ;;
    b)
      if [[ " stable testing experimental " =~ " ${OPTARG} " ]] ; then
        BRANCH="${OPTARG}"
      else
        echo "Error: Invalid branch set."
        usage
        exit ${E_ILLEGAL_ARGS}
      fi
      ;;
    c)
      CLEAN=true
      ;;
    r)
      SUFFIX="${OPTARG}"
      ;;
    s)
      SITES="${OPTARG}"
      ;;
  esac
done

# Strip of used arguments
shift $((OPTIND - 1));

# Set release number if not set
if [[ -z "${SUFFIX}" ]]; then
  SUFFIX="1"
fi

# Generate suffix and checkout latest gluon master
if [[ "${BRANCH}" == "experimental" ]]; then
  SUFFIX="~exp${DATE}$(printf %02d ${SUFFIX})"

  echo "--- Init & Checkout Latest Gluon Master ---"
  git submodule init
  git submodule update --remote
fi

# Build testing as stable to get correct autoupdater branch
if [[ "${BRANCH}" == "testing" ]]; then
  BRANCH_EFFECTIVE="stable"
else
  BRANCH_EFFECTIVE="${BRANCH}"
fi

# Ensure the build tree is clean
for SITE in ${SITES}; do
  RELEASE="${SITE}${SUFFIX}"

  if [[ ${CLEAN} ]] ; then
    echo "--- Clean entire build tree ---"
    ./build.sh -s ${SITE} -b ${BRANCH} -r ${RELEASE} "${@}" -c dirclean
  fi

  echo "--- Build Firmware / update ---"
  ./build.sh -s ${SITE} -b ${BRANCH_EFFECTIVE} -r ${RELEASE} "${@}" -c update

  # exit loop after first run (running them once is enough)
  break
done

# Build the firmware, sign and deploy
for SITE in ${SITES}; do
  RELEASE="${SITE}${SUFFIX}"
  echo "--- Build Firmware for ${SITE}/ ${RELEASE} ---"

  echo "--- Build Firmware for ${SITE}/ update ---"
  ./build.sh -s ${SITE} -b ${BRANCH_EFFECTIVE} -r ${RELEASE} "${@}" -c update

  echo "--- Build Firmware for ${SITE}/ build ---"
  ./build.sh -s ${SITE} -b ${BRANCH_EFFECTIVE} -r ${RELEASE} "${@}" -c build

  echo "--- Build Firmware for ${SITE}/ sign ---"
  ./build.sh -s ${SITE} -b ${BRANCH} -r ${RELEASE} -c sign

  echo "--- Build Firmware for ${SITE}/ deploy ---"
  ./build.sh -s ${SITE} -b ${BRANCH} -r ${RELEASE} -c deploy
done
