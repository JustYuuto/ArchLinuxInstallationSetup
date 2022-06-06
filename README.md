# Arch Linux Installation Script

A script for installing Arch Linux

## Using

On an Arch Linux machine booted on the Arch ISO, run this command:

```bash
curl -sL https://bit.ly/ArchSetup -o install.sh # name the file whatever you want
chmod +x ./install.sh
./install.sh
```

## Things setup install on your machine

* [`base`](https://archlinux.org/packages/core/any/base/), [`linux`](https://archlinux.org/packages/core/x86_64/linux/), [`linux-firmware`](https://archlinux.org/packages/core/any/linux-firmware/), [`dhcpcd`](https://archlinux.org/packages/core/x86_64/dhcpcd/), [`man-db`](https://archlinux.org/packages/core/x86_64/man-db/)
* Bootloader: [`grub`](https://archlinux.org/packages/core/x86_64/grub/), [`os-prober`](https://archlinux.org/packages/community/x86_64/os-prober/)