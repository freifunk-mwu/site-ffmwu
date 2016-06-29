#!/bin/bash -e
# =====================================================================
# Build script for Freifunk MWU firmware
#
# Credits:
# - Freifunk Fulda for their build script
# - Freifunk Bremen for their version schema
# =====================================================================

# Default make options
CORES=$(nproc)
MAKEOPTS="-j$((CORES+1))"

# Default to build all Gluon targets if parameter -t is not set
TARGETS="ar71xx-generic ar71xx-nand mpc85xx-generic x86-generic \
x86-kvm_guest x86-64 x86-xen_domu"

# Sites directory
SITES_DIR="./sites"

# Gluon directory
GLUON_DIR="./gluon"

# Deployment directory
DEPLOYMENT_DIR="/var/www/html/firmware/_library"

# Autosign key
SIGN_KEY="${HOME}/.ecdsakey"

# Build targets marked broken
BROKEN=false
TARGETS_BROKEN="ramips-rt305x brcm2708-bcm2708 brcm2708-bcm2709 sunxi"

# Overwrite Git Tag for experimental releases
GLUON_EXP_TAG="2016.1"

# Error codes
E_ILLEGAL_ARGS=126
E_ILLEGAL_TAG=127
E_DIR_NOT_EMPTY=128

# Help function used in error messages and -h option
usage() {
  echo ""
  echo "Build script for Freifunk MWU Gluon firmware."
  echo ""
  echo "-a: Build targets marked as broken (optional)"
  echo "    Default: ${BROKEN}"
  echo "-b: Firmware branch name: stable | testing | experimental"
  echo "-c: Build command: update | build | sign | deploy"
  echo "-d: Enable bash debug output"
  echo "-h: Show this help"
  echo "-i: Build identifier (optional)"
  echo "    Will be applied to the deployment directory"
  echo "-m: Setting for make options (optional)"
  echo "    Default: \"${MAKEOPTS}\""
  echo "-r: Release suffix (required)"
  echo "-s: Site directory to use (required)"
  echo "    Availible: $(ls -m ${SITES_DIR})"
  echo "-t: Gluon target architectures to build (optional)"
  echo "    Default: \"${TARGETS}\""
  echo "    Broken: \"${TARGETS_BROKEN}\""
}

# Evaluate arguments for build script.
if [[ "${#}" == 0 ]]; then
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Evaluate arguments for build script.
while getopts ab:c:dhm:i:t:r:s: flag; do
  case ${flag} in
    d)
      set -x
      ;;
    h)
      usage
      exit
      ;;
    b)
      case "${OPTARG}" in
        stable| \
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
        update| \
        build| \
        sign| \
        deploy| \
        clean| \
        dirclean)
          COMMAND="${OPTARG}"
          ;;
        *)
          echo "Error: Invalid build command set."
          usage
          exit ${E_ILLEGAL_ARGS}
          ;;
      esac
      ;;
    m)
      if [[ ${OPTARG} == +* ]]; then

        MAKEOPTS="${MAKEOPTS} ${OPTARG#+}"
      else
        MAKEOPTS="${OPTARG}"
      fi
      ;;
    i)
      BUILD="${OPTARG}"
      ;;
    t)
      TARGETS_OPT="${OPTARG}"
      ;;
    r)
      RELEASE="${OPTARG}"
      ;;
    s)
      if [[ -d "${SITES_DIR}/${OPTARG}" ]]; then
        SITE_DIR="${SITES_DIR}/${OPTARG}"
      elif [[ -d "${OPTARG}" ]]; then
        SITE_DIR="${OPTARG}"
      else
        echo "Error: Invalid site directory set."
        usage
        exit ${E_ILLEGAL_ARGS}
      fi
      SITE_DIR="$(readlink -f ${SITE_DIR})"
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

# Generate target list
if [[ -z "${TARGETS_OPT}" && "${BROKEN}" == true ]]; then
  TARGETS="${TARGETS} ${TARGETS_BROKEN}"
elif [[ -n "${TARGETS_OPT}" ]] ; then
  TARGETS="${TARGETS_OPT}"
fi

# Set command
if [[ -z "${COMMAND}" ]]; then
  echo "Error: Build command missing."
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Set release number
if [[ -z "${RELEASE}" ]]; then
  echo "Error: Release suffix missing."
  usage
  exit ${E_ILLEGAL_ARGS}
fi

if [[ "${BRANCH}" == "experimental" ]]; then
  GLUON_TAG="${GLUON_EXP_TAG}"
elif [[ "${BRANCH}" == "stable" || "${BRANCH}" == "testing" ]]; then
  if ! GLUON_TAG=$(git --git-dir="${GLUON_DIR}/.git" describe --exact-match) ; then
    echo 'Error: The gluon tree is not checked out at a tag.'
    echo 'Please use `git checkout <tagname>` to use an official gluon release'
    echo 'or build it as experimental.'
    exit ${E_ILLEGAL_TAG}
  fi
  GLUON_TAG="${GLUON_TAG#v}"
fi

RELEASE="${GLUON_TAG}+${RELEASE}"

# Number of days that may pass between releasing an updating
PRIORITY=0

update() {
  make ${MAKEOPTS} \
       GLUON_SITEDIR="${SITE_DIR}" \
       update
}

build() {
  echo "--- Build Gluon ${GLUON_TAG} as ${RELEASE} ---"

  for TARGET in ${TARGETS}; do
    echo "--- Build Gluon Images for target: ${TARGET} ---"
    make ${MAKEOPTS} \
         GLUON_SITEDIR="${SITE_DIR}" \
         GLUON_RELEASE="${RELEASE}" \
         GLUON_BRANCH="${BRANCH}" \
         GLUON_TARGET="${TARGET}" \
         BROKEN="${BROKEN}" \
         all
  done
}

sign() {
  echo "--- Build Gluon Manifest ---"
  make ${MAKEOPTS} \
       GLUON_SITEDIR="${SITE_DIR}" \
       GLUON_RELEASE="${RELEASE}" \
       GLUON_BRANCH="${BRANCH}" \
       GLUON_PRIORITY="${PRIORITY}" \
       manifest

  echo "--- Sign Gluon Firmware Build ---"
  # Add the signature to the local manifest
  if [[ -e "${SIGN_KEY}" ]] ; then
    contrib/sign.sh \
        "${SIGN_KEY}" \
        "output/images/sysupgrade/${BRANCH}.manifest"
  else
    "${SIGN_KEY} not found!"
  fi
}

deploy() {
  # Create the deployment directory
  TARGET="${DEPLOYMENT_DIR}/${RELEASE}"
  if [[ -n ${BUILD} ]]; then
    TARGET="${TARGET}~${BUILD}"
  fi

  echo "--- Deploy Gluon Firmware ---"
  mkdir --parents --verbose "${TARGET}"

  # Check if target directory is empty
  if [[ "$(ls -A ${TARGET})" ]]; then
    echo "Error: Target directory not empty"
    exit ${E_DIR_NOT_EMPTY}
  fi

  # Copy images and modules to DEPLOYMENT_DIR
  CP_CMD="cp --verbose --recursive --no-dereference"
  $CP_CMD "output/images/factory"         "${TARGET}/factory"
  $CP_CMD "output/images/sysupgrade"      "${TARGET}/sysupgrade"
  $CP_CMD "output/modules/"*"${RELEASE}"  "${TARGET}/modules"

  # Set branch link to new release
  echo "--- Linking branch ${BRANCH} to $(basename ${TARGET}) ---"
  if [[ -e "${DEPLOYMENT_DIR}/../${BRANCH}" ]] ; then
    rm "${DEPLOYMENT_DIR}/../${BRANCH}"
  fi

  ln --relative --symbolic \
        "${TARGET}" \
        "${DEPLOYMENT_DIR}/../${BRANCH}"
}

clean(){
  echo "--- Clean ---"

  for TARGET in ${TARGETS}; do
    echo "--- Cleaning target: ${TARGET} ---"
    make ${MAKEOPTS} \
         GLUON_SITEDIR="${SITE_DIR}" \
         GLUON_RELEASE="${RELEASE}" \
         GLUON_TARGET="${TARGET}" \
         BROKEN="${BROKEN}" \
         clean
  done
}

dirclean(){
  echo "--- Cleaning working directory ---"
  make ${MAKEOPTS} \
       GLUON_SITEDIR="${SITE_DIR}" \
       BROKEN="${BROKEN}" \
       dirclean
}

(
  # Change working directory to gluon tree
  cd "${GLUON_DIR}"

  # Execute the selected command
  ${COMMAND}
)
