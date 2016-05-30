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
  echo "Autobuild script for experimental Freifunk MWU Gluon firmware."
  echo ""
  echo "-h: Show this help"
  echo "-s: Gluon sites to build (optional)"
  echo "    Default: \"${SITES}\""
}

# Evaluate arguments for build script.
while getopts :dh:s: flag; do
  case ${flag} in
    d)
      set -x
      ;;
    h)
      usage
      exit
      ;;
    s)
      SITES="${OPTARG}"
      ;;
    *)
      usage
      exit ${E_ILLEGAL_ARGS}
      ;;
  esac
done

# Strip of all remaining arguments
shift $((OPTIND - 1));

# Check if there are remaining arguments
if [[ "${#}" > 0 ]]; then
  echo "Error: To many arguments: ${*}"
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Ensure the build tree is clean
echo "--- Clean entire build tree ---"
for SITE in ${SITES}; do
  RELEASE="${SITE}~exp${DATE}"
  ./build.sh -s ${SITE} -b experimental -r ${RELEASE} -a -c clean
  ./build.sh -s ${SITE} -b experimental -r ${RELEASE} -a -c dirclean
done

# Checkout latest gluon master
echo "--- Init & Checkout Latest Gluon Master ---"
git submodule init
git submodule update --remote

# Build the firmware, sign and deploy
for SITE in ${SITES}; do
  echo "--- Build Firmware for ${SITE} ---"
  RELEASE="${SITE}~exp${DATE}"

  echo "--- Build Firmware for ${SITE}/ update ---"
  ./build.sh -s ${SITE} -b experimental -r ${RELEASE} -a -c update

  echo "--- Build Firmware for ${SITE}/ build ---"
  ./build.sh -s ${SITE} -b experimental -r ${RELEASE} -a -c build

  echo "--- Build Firmware for ${SITE}/ sign ---"
  ./build.sh -s ${SITE} -b experimental -r ${RELEASE} -a -c sign

  echo "--- Build Firmware for ${SITE}/ deploy ---"
  ./build.sh -s ${SITE} -b experimental -r ${RELEASE} -a -c deploy
done
