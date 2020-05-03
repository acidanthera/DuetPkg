/*++

Copyright (c) 2005 - 2007, Intel Corporation. All rights reserved.<BR>
This program and the accompanying materials                          
are licensed and made available under the terms and conditions of the BSD License         
which accompanies this distribution.  The full text of the license may be found at        
http://opensource.org/licenses/bsd-license.php                                            
                                                                                          
THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,                     
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.             

Module Name:

  PciDriverOverride.c
  
Abstract:

  PCI Bus Driver

Revision History

--*/

#include "PciBus.h"

EFI_STATUS
EFIAPI
GetDriver(
  IN     EFI_BUS_SPECIFIC_DRIVER_OVERRIDE_PROTOCOL          *This,
  IN OUT EFI_HANDLE                                         *DriverImageHandle
  );



EFI_STATUS
InitializePciDriverOverrideInstance (
  PCI_IO_DEVICE  *PciIoDevice
  )
/*++

Routine Description:

  Initializes a PCI Driver Override Instance

Arguments:
  
Returns:

  None

--*/

{
  PciIoDevice->PciDriverOverride.GetDriver = GetDriver;
  return EFI_SUCCESS;
}

EFI_STATUS
EFIAPI
GetDriver (
  IN EFI_BUS_SPECIFIC_DRIVER_OVERRIDE_PROTOCOL              *This,
  IN OUT EFI_HANDLE                                         *DriverImageHandle
  )
/*++

Routine Description:

  Get a overriding driver image

Arguments:
  
Returns:

  None

--*/
{
  PCI_IO_DEVICE             *PciIoDevice;
  LIST_ENTRY            *CurrentLink;
  PCI_DRIVER_OVERRIDE_LIST  *Node;

  PciIoDevice = PCI_IO_DEVICE_FROM_PCI_DRIVER_OVERRIDE_THIS (This);

  CurrentLink = PciIoDevice->OptionRomDriverList.ForwardLink;

  while (CurrentLink && CurrentLink != &PciIoDevice->OptionRomDriverList) {

    Node = DRIVER_OVERRIDE_FROM_LINK (CurrentLink);

    if (*DriverImageHandle == NULL) {

      *DriverImageHandle = Node->DriverImageHandle;
      return EFI_SUCCESS;
    }

    if (*DriverImageHandle == Node->DriverImageHandle) {

      if (CurrentLink->ForwardLink == &PciIoDevice->OptionRomDriverList ||
          CurrentLink->ForwardLink == NULL) {
        return EFI_NOT_FOUND;
      }

      //
      // Get next node
      //
      Node                = DRIVER_OVERRIDE_FROM_LINK (CurrentLink->ForwardLink);
      *DriverImageHandle  = Node->DriverImageHandle;
      return EFI_SUCCESS;
    }

    CurrentLink = CurrentLink->ForwardLink;
  }

  return EFI_INVALID_PARAMETER;
}
