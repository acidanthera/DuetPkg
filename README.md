DuetPkg
=======

[![Build Status](https://travis-ci.com/acidanthera/DuetPkg.svg?branch=master)](https://travis-ci.com/acidanthera/DuetPkg)

Acidanthera variant of DuetPkg. Specialties:

- Significantly improved boot performance.
- BDS is simplified to load `EFI/OC/OpenCore.efi`.
- EDID support removed for performance and compatibility.
- PCI option ROM support removed for security and performance.
- Setup and graphical interface removed.
- Resolved PCIe device path instead of PCI.
- Increased variable storage size to 64 KB.
- Always loads from bootstrapped volume first.
- Some changes inherited from Clover EFI bootloader.

## Error codes

- `BOOT MISMATCH!` - Bootstrap partition signature identification failed.
    BDS code will try to lookup `EFI/OC/OpenCore.efi` on any partition in 3 seconds.
- `BOOT FAIL!` - No bootable `EFI/OC/OpenCore.efi` file found on any partition.
    BDS code will dead-loop CPU in 3 seconds.

## Compilation

By default [ocbuild](https://github.com/acidanthera/ocbuild)-like compilation is used via `macbuild.tool`.
As an alternative it is possible to perform in-tree compilation by using `INTREE=1` environment variable:

```
TARGETARCH=X64 TARGET=RELEASE INTREE=1 DuetPkg/macbuild.tool
```

*Note*: 32-bit version may not work properly when compiled with older Xcode version (tested 11.4.1).

## Configuration

Builtin available drivers are set in `DuetPkg.fdf` (included drivers) and `DuetPkg.dsc`
(compiled drivers, may not be included). Adding more drivers may result in the need to
change firmware volume size. To do this update `NumBlocks` in `DuetPkg.fdf`
(number of 64 KB blocks in the firmware).

*Note*: OHCI driver is not bundled with DuetPkg (and EDK II) and can be found in
`edk2-platforms/Silicon/Intel/QuarkSocPkg/QuarkSouthCluster/Usb/Ohci/Dxe`.
