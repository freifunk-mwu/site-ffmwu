#!/bin/bash -e
# =====================================================================
# Build script for Freifunk MWU firmware
#
# Credits:
# - Freifunk Fulda for their build script
# - Freifunk Bremen for their version schema
# =====================================================================

# Get full path to script directory
SCRIPTPATH="$(dirname "$(readlink -e "$0")" )"

# Default make options
CORES=$(nproc)
MAKEOPTS="-j$((CORES+1)) V=s"

# Default to build all Gluon targets if parameter -t is not set
TARGETS="ar71xx-generic ar71xx-nand ar71xx-tiny mpc85xx-generic brcm2708-bcm2708 \
brcm2708-bcm2709 x86-generic x86-geode x86-64"

# Sites directory
SITES_DIR="${SCRIPTPATH}/sites"

# Gluon directory
GLUON_DIR="${SCRIPTPATH}/gluon"

# Deployment directory
DEPLOYMENT_DIR="/var/www/html/firmware/_library"

# Autosign key
SIGN_KEY="${HOME}/.ecdsakey"

# Build targets marked broken
BROKEN=false
TARGETS_BROKEN="ar71xx-mikrotik mvebu ramips-mt7621 ramips-rt305x sunxi"

# Branch used for building (autoupdater!)
BUILDBRANCH="stable"

# Error codes
E_ILLEGAL_ARGS=126

# Help function used in error messages and -h option
usage() {
  echo ""
  echo "Build script for Freifunk MWU Gluon firmware."
  echo ""
  echo "-a: Build targets marked as broken (optional)"
  echo "    Applied: ${BROKEN}"
  echo "-b: Firmware branch name (required: sign deploy)"
  echo "    Availible: stable testing experimental"
  echo "-c: Build command (required)"
  echo "    Availible: update build sign deploy clean dirclean"
  echo "-d: Enable bash debug output (optional)"
  echo "-h: Show this help"
  echo "-i: Build identifier (optional)"
  echo "    Will be applied to the deployment directory"
  echo "-m: Setting for make options (optional)"
  echo "    Applied: \"${MAKEOPTS}\""
  echo "-p: Priority used for autoupdater (optional)"
  echo "    Default: see site.mk"
  echo "-r: Release suffix (required: build sign deploy)"
  echo "-s: Site directory to use (required)"
  echo "    Availible: $(ls -m ${SITES_DIR})"
  echo "-t: Gluon target architectures to build (optional)"
  echo "    Applied: \"${TARGETS}\""
  echo "    Broken: \"${TARGETS_BROKEN}\""
}

# Evaluate arguments for build script.
if [[ "${#}" == 0 ]]; then
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Evaluate arguments for build script.
while getopts ab:c:dhm:p:i:t:r:s: flag; do
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
    p)
      MAKEOPTS="${MAKEOPTS} GLUON_PRIORITY=${OPTARG}"
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
        SITE="${OPTARG}"
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

# Set GLUON_OUTPUTDIR
GLUON_OUTPUTDIR="${SCRIPTPATH}/output/${SITE}"
MAKEOPTS="${MAKEOPTS} GLUON_OUTPUTDIR=${GLUON_OUTPUTDIR}"

# Generate target list
if [[ -z "${TARGETS_OPT}" && "${BROKEN}" == true ]]; then
  TARGETS="${TARGETS} ${TARGETS_BROKEN}"
  MAKEOPTS="${MAKEOPTS} BROKEN=true"
elif [[ -n "${TARGETS_OPT}" && "${BROKEN}" == true ]] ; then
  TARGETS="${TARGETS_OPT}"
  MAKEOPTS="${MAKEOPTS} BROKEN=true"
elif [[ -n "${TARGETS_OPT}" ]] ; then
  TARGETS="${TARGETS_OPT}"
fi

# Check if $COMMAND is set
if [[ -z "${COMMAND}" ]]; then
  echo "Error: Build command missing."
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Check if $RELEASE is set for commands that need it
if [[ -z "${RELEASE}" && " update clean dirclean build sign deploy " =~ " ${COMMAND} " ]]; then
  echo "Error: Release suffix missing."
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Check if $BRANCH is set for commands that need it
if [[ -z "${BRANCH}" && " sign deploy " =~ " ${COMMAND} " ]]; then
  echo "Error: Branch missing."
  usage
  exit ${E_ILLEGAL_ARGS}
fi

update() {
  make ${MAKEOPTS} \
       GLUON_SITEDIR="${SITE_DIR}" \
       GLUON_RELEASE="${RELEASE}" \
       update
}

build() {
  echo "--- Cleaning output directory ---"
  rm -rf "${GLUON_OUTPUTDIR}"

  echo "--- Building Gluon as ${RELEASE} ---"
  for TARGET in ${TARGETS}; do
    echo "--- Building Gluon Images for target: ${TARGET} ---"
    make ${MAKEOPTS} \
         GLUON_SITEDIR="${SITE_DIR}" \
         GLUON_RELEASE="${RELEASE}" \
         GLUON_BRANCH="${BUILDBRANCH}" \
         GLUON_TARGET="${TARGET}"
  done
}

sign() {
  echo "--- Building Gluon Manifest ---"
  make ${MAKEOPTS} \
       GLUON_SITEDIR="${SITE_DIR}" \
       GLUON_RELEASE="${RELEASE}" \
       GLUON_BRANCH="${BRANCH}" \
       manifest

  echo "--- Signing Gluon Firmware Build ---"
  # Add the signature to the local manifest
  if [[ -e "${SIGN_KEY}" ]] ; then
    contrib/sign.sh \
        "${SIGN_KEY}" \
        "${GLUON_OUTPUTDIR}/images/sysupgrade/${BRANCH}.manifest"
  else
    "${SIGN_KEY} not found!"
  fi
}

deploy() {
  # Create the deployment directory
  TARGET="${DEPLOYMENT_DIR}/${RELEASE}/${SITE}"
  if [[ -n ${BUILD} ]]; then
    TARGET="${TARGET}~${BUILD}"
  fi

  echo "--- Deploying Gluon Firmware ---"
  mkdir --parents --verbose "${TARGET}"

  # Check if target directory is empty
  if [[ "$(ls -A ${TARGET})" ]]; then
    echo "Error: Target directory not empty; skipping!"
    return
  fi

  # Copy images and modules to DEPLOYMENT_DIR
  CP_CMD="cp --verbose --recursive --no-dereference"
  $CP_CMD "${GLUON_OUTPUTDIR}/images/factory"         "${TARGET}/factory"
  $CP_CMD "${GLUON_OUTPUTDIR}/images/sysupgrade"      "${TARGET}/sysupgrade"
  $CP_CMD "${GLUON_OUTPUTDIR}/packages/"*"${RELEASE}" "${TARGET}/modules"

  # Set branch link to new release
  echo "--- Linking branch ${BRANCH} to $(basename ${TARGET}) ---"
  if [[ ! -d "${DEPLOYMENT_DIR}/../${SITE}" ]]; then
    echo "No directory to link to."
  fi

  if [[ -L "${DEPLOYMENT_DIR}/../${SITE}/${BRANCH}" ]] ; then
    unlink "${DEPLOYMENT_DIR}/../${SITE}/${BRANCH}"
  fi

  ln --relative --symbolic \
        "${TARGET}" \
        "${DEPLOYMENT_DIR}/../${SITE}/${BRANCH}"
}

clean(){
  echo "--- Cleaning build directories ---"

  for TARGET in ${TARGETS}; do
    echo "--- Cleaning target: ${TARGET} ---"
    make ${MAKEOPTS} \
         GLUON_SITEDIR="${SITE_DIR}" \
         GLUON_RELEASE="${RELEASE}" \
         GLUON_TARGET="${TARGET}" \
         clean
  done
}

dirclean(){
  echo "--- Cleaning entire working directory ---"
  make ${MAKEOPTS} \
       GLUON_SITEDIR="${SITE_DIR}" \
       GLUON_RELEASE="${RELEASE}" \
       dirclean
}

(
  # Change working directory to gluon tree
  cd "${GLUON_DIR}"

  # Execute the selected command
  ${COMMAND}
)
