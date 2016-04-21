#!/bin/bash -e
# =====================================================================
# Build script for Freifunk MWU firmware
#
# Credits:
#   - Freifunk Fulda for their build script
#   - Freifunk Bremen for their version schema
# =====================================================================

# Default make options
CORES=$(nproc)
MAKEOPTS="-j $((CORES+1)) V=s"

# Default to build all Gluon targets if parameter -t is not set
TARGETS="ar71xx-generic ar71xx-nand mpc85xx-generic x86-generic \
x86-kvm_guest x86-64 x86-xen_domu ramips-rt305x brcm2708-bcm2708 \
brcm2708-bcm2709 sunxi"

# Sites directory
SITES_DIR="sites"

# Gluon directory
GLUON_DIR="gluon"

# Deployment directory
DEPLOYMENT_DIR="/var/www/html/_library"

# Autosign key
SIGN_KEY="/home/admin/.ecdsakey"

# Build targets marked broken
BROKEN=false

# Error codes
E_ILLEGAL_ARGS=126
E_ILLEGAL_TAG=127

# Help function used in error messages and -h option
usage() {
  echo ""
  echo "Build script for Freifunk MWU Gluon firmware."
  echo ""
  echo "-a: Build targets marked as broken (optional)"
  echo "    Default: ${BROKEN}"
  echo "-b: Firmware branch name (testing or experimental)"
  echo "-c: Build command: update | build | sign | deploy"
  echo "-d: Enable bash debug output"
  echo "-h: Show this help"
  echo "-i: Build identifier (optional)"
  echo "    Default: \"${BUILD}\""
  echo "-m: Setting for make options (optional)"
  echo "    Default: \"${MAKEOPTS}\""
  echo "-r: Release suffix number (optional)"
  echo "    Default: 1"
  echo "-s: Site directory to use (required)"
  echo "    Availible: $(ls -m ${SITES_DIR})"
  echo "-t: Gluon target architectures to build (optional)"
  echo "    Default: \"${TARGETS}\""
}

# Evaluate arguments for build script.
if [[ "${#}" == 0 ]]; then
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Evaluate arguments for build script.
while getopts ab:c:dhm:i:t:r:s: flag; do
  case ${flag} in
    b)
      case "${OPTARG}" in
        testing| \
        experimental)
          BRANCH="${OPTARG}"
          ;;
        *)
          echo "Error: Invalid branch set."
          usage
          exit ${E_ILLEGAL_ARGS}
          ;;
      esac
      ;;
    c)
      case "${OPTARG}" in
        update)
          COMMAND="${OPTARG}"
          ;;
        build)
          COMMAND="${OPTARG}"
          ;;
        sign)
          COMMAND="${OPTARG}"
          ;;
        deploy)
          COMMAND="${OPTARG}"
          ;;
        *)
          echo "Error: Invalid build command set."
          usage
          exit ${E_ILLEGAL_ARGS}
          ;;
      esac
      ;;
    d)
      set -x
      ;;
    h)
      usage
      exit
      ;;
    m)
      MAKEOPTS="${OPTARG}"
      ;;
    i)
      BUILD="${OPTARG}"
      ;;
    t)
      TARGETS="${OPTARG}"
      ;;
    r)
      RELEASE_NUM="${OPTARG}"
      ;;
    s)
      if [ -d "${SITES_DIR}/${OPTARG}" ]; then
        SITE="${OPTARG}"
        SITE_DIR="$(readlink -f ${SITES_DIR}/${OPTARG})"
      else
        echo "Error: Invalid site directory set."
        usage
        exit ${E_ILLEGAL_ARGS}
      fi
      ;;
    a)
      BROKEN=true
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

# Set branch name
if [[ -z "${BRANCH}" ]]; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
fi

if [[ -z "${BUILD}" ]]; then
  BUILD=${BRANCH}
fi

# Set command
if [[ -z "${COMMAND}" ]]; then
  echo "Error: Build command missing."
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Set release number
if [[ -z "${RELEASE_NUM}" ]]; then
  RELEASE_NUM="1"
fi

if [[ "${BRANCH}" == "experimental" ]]; then
  GLUON_TAG=$(git --git-dir="${GLUON_DIR}/.git" describe --always)
  GLUON_TAG="${GLUON_TAG#v}"
  GLUON_TAG="${GLUON_TAG//-*}"
  RELEASE="${GLUON_TAG}+${SITE}~exp$(date +%Y%m%d)$(printf %02d ${RELEASE_NUM})"
elif [[ "${BRANCH}" == "testing" ]]; then
  if ! GLUON_TAG=$(git --git-dir="${GLUON_DIR}/.git" describe --exact-match); then
    echo 'The gluon tree is not checked out at a tag.'
    echo 'Please use `git checkout <tagname>` to use an official gluon release'
    echo 'or build it manually. Only with a tag we can autogenerate the'
    echo 'release string!'
    exit ${E_ILLEGAL_TAG}
  fi
  GLUON_TAG="${GLUON_TAG#v}"
  RELEASE="${GLUON_TAG}+${SITE}${RELEASE_NUM}"
fi

#echo ${RELEASE}; exit 0

# Number of days that may pass between releasing an updating
PRIORITY=0

update() {
  make ${MAKEOPTS} \
       GLUON_SITEDIR="${SITE_DIR}" \
       GLUON_RELEASE="${RELEASE}" \
       GLUON_BRANCH="${BRANCH}" \
       BROKEN="${BROKEN}" \
       update
}

build() {
  for TARGET in ${TARGETS}; do
    echo
    echo "--- Build Gluon Images for target: ${TARGET}"
    make ${MAKEOPTS} \
         GLUON_SITEDIR="${SITE_DIR}" \
         GLUON_RELEASE="${RELEASE}" \
         GLUON_BRANCH="${BRANCH}" \
         GLUON_TARGET="${TARGET}" \
         BROKEN="${BROKEN}" \
         all
  done

  echo
  echo "--- Build Gluon Manifest"
  make ${MAKEOPTS} \
       GLUON_SITEDIR="${SITE_DIR}" \
       GLUON_RELEASE="${RELEASE}" \
       GLUON_BRANCH="${BRANCH}" \
       GLUON_PRIORITY="${PRIORITY}" \
       BROKEN="${BROKEN}" \
       manifest

  echo "--- Write Build file"
  cat > "output/build.info" <<EOF
BUILD=${BUILD}
RELEASE=${RELEASE}
BRANCH=${BRANCH}
HOST=$(uname -n)
EOF

}

sign() {
  echo
  echo "--- Sign Gluon Firmware Build"

  # Add the signature to the local manifest
  contrib/sign.sh \
      "${SIGN_KEY}" \
      "output/images/sysupgrade/${BRANCH}.manifest"
}

deploy() {
  echo
  echo "--- Deploy Gluon Firmware Images and Manifest"

  # Create the deployment directory
  TARGET="${DEPLOYMENT_DIR}/${RELEASE}"
  mkdir --parents --verbose \
    "${TARGET}"

  # Copy images and modules to DEPLOYMENT_DIR
  CP_CMD="cp --verbose --recursive --no-dereference"
  $CP_CMD "output/images/factory"         "${TARGET}/factory"
  $CP_CMD "output/images/sysupgrade"      "${TARGET}/sysupgrade"
  $CP_CMD "output/modules/"*"${RELEASE}"  "${TARGET}/modules"
}

(
  # Change working directory to gluon tree
  cd "${GLUON_DIR}"

  # Execute the selected command
  ${COMMAND}
)
