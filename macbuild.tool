#!/bin/bash

imgbuild() {
  echo "Compressing DUETEFIMainFv.FV..."
  LzmaCompress -e -o "${BUILD_DIR}/FV/DUETEFIMAINFV${TARGETARCH}.z" \
    "${BUILD_DIR}/FV/DUETEFIMAINFV${TARGETARCH}.Fv" || exit 1

  echo "Compressing DxeCore.efi..."
  LzmaCompress -e -o "${BUILD_DIR}/FV/DxeMain${TARGETARCH}.z" \
    "${BUILD_DIR_ARCH}/DxeCore.efi" || exit 1

  echo "Compressing DxeIpl.efi..."
  LzmaCompress -e -o "${BUILD_DIR}/FV/DxeIpl${TARGETARCH}.z" \
    "$BUILD_DIR_ARCH/DxeIpl.efi" || exit 1

  echo "Generating Loader Image..."

  GenFw --rebase 0x10000 -o "${BUILD_DIR_ARCH}/EfiLoader.efi" \
    "${BUILD_DIR_ARCH}/EfiLoader.efi" || exit 1
  "${FV_TOOLS}/EfiLdrImage" -o "${BUILD_DIR}/FV/Efildr${TARGETARCH}" \
    "${BUILD_DIR_ARCH}/EfiLoader.efi" "${BUILD_DIR}/FV/DxeIpl${TARGETARCH}.z" \
    "${BUILD_DIR}/FV/DxeMain${TARGETARCH}.z" "${BUILD_DIR}/FV/DUETEFIMAINFV${TARGETARCH}.z" || exit 1

  EL_SIZE=$(stat -f "%z" "${BUILD_DIR}/FV/Efildr${TARGETARCH}")
  if (( $((EL_SIZE)) > 319488 )); then
    echo "ERROR: boot file bigger than low-ebda permits!"
    exit 1
  fi

  cat "${BOOTSECTOR_BIN_DIR}/Start${TARGETARCH}.com" "${BOOTSECTOR_BIN_DIR}/Efi${TARGETARCH}.com" \
    "${BUILD_DIR}/FV/Efildr${TARGETARCH}" > "${BUILD_DIR}/FV/Efildr${TARGETARCH}Pure" || exit 1

  if [ "${TARGETARCH}" = "X64" ]; then
    "${FV_TOOLS}/GenPage" "${BUILD_DIR}/FV/Efildr${TARGETARCH}Pure" -b 0x70000 -f 0x50000 \
      -o "${BUILD_DIR}/FV/Efildr${TARGETARCH}Out" || exit 1

    dd if="${BUILD_DIR}/FV/Efildr${TARGETARCH}Out" of="${BUILD_DIR_ARCH}/boot" bs=512 skip=1 || exit 1
  else
    cp "${BUILD_DIR}/FV/Efildr${TARGETARCH}Pure" "${BUILD_DIR_ARCH}/boot" || exit 1
  fi
}

package() {
  if [ ! -d "$1" ] || [ ! -d "$1"/../FV ]; then
    echo "Missing package directory"
    exit 1
  fi

  pushd "$1" || exit 1
  cd -P . || exit 1
  BUILD_DIR_ARCH=$(pwd)
  cd -P .. || exit 1
  BUILD_DIR=$(pwd)
  popd || exit 1

  imgbuild
}

cd $(dirname "$0")

BOOTSECTOR_BIN_DIR="$(pwd)/BootSector/bin"
FV_TOOLS="$(pwd)/BaseTools/bin.$(uname)"

if [ ! -d "${FV_TOOLS}" ]; then
  echo "ERROR: You need to compile BaseTools for your platform!"
  exit 1
fi

if [ "${TARGETARCH}" = "" ]; then
  TARGETARCH="X64"
fi

if [ "${TARGET}" = "" ]; then
  TARGET="RELEASE"
fi

if [ "${INTREE}" != "" ]; then
  # In-tree compilation is merely for packing.
  cd .. || exit 1

  build -a "${TARGETARCH}" -b "${TARGET}" -t XCODE5 -p DuetPkg/DuetPkg.dsc || exit 1
  
  BUILD_DIR="${WORKSPACE}/Build/DuetPkg/${TARGET}_XCODE5"
  BUILD_DIR_ARCH="${BUILD_DIR}/${TARGETARCH}"
  imgbuild
else
  TARGETS=(DEBUG RELEASE)
  ARCHS=(IA32 X64)
  SELFPKG=DuetPkg
  DEPNAMES=('EfiPkg')
  DEPURLS=('https://github.com/acidanthera/EfiPkg')
  DEPBRANCHES=('master')
  src=$(/usr/bin/curl -Lfs https://raw.githubusercontent.com/acidanthera/ocbuild/master/efibuild.sh) && eval "$src" || exit 1
fi
