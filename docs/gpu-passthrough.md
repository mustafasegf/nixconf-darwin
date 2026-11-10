# GPU Passthrough (mustafa-pc -> win11 VM)

Status as of this writing: configured for **single-GPU passthrough**. The Linux host uses the RX
7900 XTX normally, then the `win11` libvirt hook tears down the graphical stack, unloads AMD DRM
drivers, loads VFIO, and lets libvirt attach the GPU to the VM.

## Goal

Boot the existing bare-metal Windows install on its own NVMe inside the `win11` libvirt/QEMU VM and
pass through the RX 7900 XTX, GPU audio, and Logitech receiver.

## Hardware inventory

| Component | Detail |
|-----------|--------|
| CPU | AMD Ryzen 7 7700X |
| GPU | Sapphire NITRO+ Radeon RX 7900 XTX (Navi 31, RDNA3) |
| Kernel | 7.0.3, `linuxPackages_latest` |

### PCI addresses / IDs

| Device | PCI addr | PCI ID | Host driver before VM | IOMMU group |
|--------|----------|--------|-----------------------|-------------|
| RX 7900 XTX video | `0000:03:00.0` | `1002:744c` | `amdgpu` | 14 |
| RX 7900 XTX HDMI/DP audio | `0000:03:00.1` | `1002:ab30` | `snd_hda_intel` | 15 |
| Raphael iGPU video | `0000:7f:00.0` | `1002:164e` | unused for passthrough | 26 |
| Raphael iGPU audio | `0000:7f:00.1` | `1002:1640` | unused for passthrough | 27 |

The discrete GPU and audio function are isolated, so no ACS override is needed.

### Disks and input

| Device | Detail |
|--------|--------|
| NixOS disk | `nvme0n1` |
| Windows disk | `/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S6P1NS0W100451H` |
| Home disk | `nvme2n1` |
| USB input | Logitech Bolt receiver `046d:c548` |

Do not mount the Windows NTFS filesystem on the host while the VM owns the whole disk.

## NixOS configuration

`machines/mustafa-pc.nix` keeps normal host GPU ownership:

- `amd_iommu=on`
- `iommu=pt`
- `video=efifb:off`
- no `vfio-pci.ids=...`
- `amdgpu` remains in the initrd modules before the VFIO modules

`modules/nixos/desktop.nix` defines the `win11` qemu hook declaratively. It follows the
stele95/RisingPrism model:

- start `libvirt-nosleep@win11`
- save CPU governors and switch writable governors to `performance`
- stop `display-manager.service`
- isolate `multi-user.target`
- unbind framebuffer VT consoles
- unbind EFI/simple framebuffers if present
- unload `drm_kms_helper`, `amdgpu`, `radeon`, and `drm`
- load `vfio`, `vfio_pci`, and `vfio_iommu_type1`
- run a short `rtcwake -m mem -s 3` reset assist
- reverse the sequence on VM release and restore the saved governors

## Required libvirt XML shape

The `win11` domain XML must match the stele95 approach:

- PCI GPU and GPU-audio hostdevs use `managed="yes"`, so libvirt performs the VFIO attach/detach.
- The old `managed="no"` setup should not be used with this hook.
- The 7900 XTX PCI functions should include `<rom bar="off"/>`.
- If a known-good VBIOS is exported later, use `<rom bar="off" file="/var/lib/libvirt/vgabios/gpu.rom"/>`.
- The domain should keep Q35, OVMF, host-passthrough CPU, hidden KVM, Hyper-V enlightenments,
  disabled memballoon, and the `-overcommit cpu-pm=on` QEMU arguments where possible.

Hostdev snippet for this machine:

```xml
<hostdev mode="subsystem" type="pci" managed="yes">
  <source>
    <address domain="0x0000" bus="0x03" slot="0x00" function="0x0"/>
  </source>
  <rom bar="off"/>
</hostdev>
<hostdev mode="subsystem" type="pci" managed="yes">
  <source>
    <address domain="0x0000" bus="0x03" slot="0x00" function="0x1"/>
  </source>
  <rom bar="off"/>
</hostdev>
<hostdev mode="subsystem" type="usb" managed="yes">
  <source>
    <vendor id="0x046d"/>
    <product id="0xc548"/>
  </source>
</hostdev>
```

Use `virsh edit win11` or virt-manager to apply this. On this NixOS system, the inactive domain
file is stored at `/var/lib/libvirt/qemu/win11.xml`, but it is root-owned and should be changed
through libvirt when the daemon is responsive.

## Previous failure mode

The previous hook manually set `driver_override=vfio-pci`, unbound `03:00.0` and `03:00.1`, and
then explicitly bound them to `vfio-pci`. That path wedged in a kernel PCIe reset:

```text
/var/lib/libvirt/hooks/qemu.d/win11 win11 prepare begin
State: D (uninterruptible sleep)
```

The current stele95-style approach avoids that manual bind step. It fully drops the graphical
stack and AMD DRM modules first, then lets libvirt manage the hostdev attach because the XML uses
`managed="yes"`.

## Current recovery note

If `virsh -c qemu:///system ...` hangs, check for an old stuck hook:

```bash
systemctl status libvirtd --no-pager -l
ps -o pid,ppid,stat,wchan:32,cmd -p <hook-pid>
```

If the hook process is in `D` state, reboot. If normal reboot hangs, force a safe SysRq reboot:

```bash
echo 1 | sudo tee /proc/sys/kernel/sysrq
echo s | sudo tee /proc/sysrq-trigger
echo b | sudo tee /proc/sysrq-trigger
```

After reboot and rebuild, confirm the host starts with normal GPU ownership:

```bash
basename "$(readlink -f /sys/bus/pci/devices/0000:03:00.0/driver)"
basename "$(readlink -f /sys/bus/pci/devices/0000:03:00.1/driver)"
```

Expected before starting the VM: `amdgpu` and `snd_hda_intel`.
