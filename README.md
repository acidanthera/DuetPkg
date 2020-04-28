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
- Some changes inherited from Clover EFI bootloader.

## Compilation

By default [ocbuild](https://github.com/acidanthera/ocbuild)-like compilation is used via `macbuild.tool`.
As an alternative it is possible to perform in-tree compilation by using `INTREE=1` environment variable:

```
TARGETARCH=X64 TARGET=RELEASE INTREE=1 DuetPkg/macbuild.tool
```

*Note*: 32-bit version may not work properly when compiled with older Xcode version (tested 11.4.1).

## Configuration

Builtin available drivers are set in `DuetPkg.fdf` (included drivers) and `DuetPkg.dsc`
(compiled drivers, may not be included).

Changing resulting firmware size is done in three places:

- `NumBlocks` in `DuetPkg.fdf` (number of 64 KB blocks in the firmware).
- `PAGE_TABLE` 64-bit PT address limiting firmware size (`macbuild.tool` and `start.nasm`).
