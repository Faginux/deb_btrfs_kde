# deb_btrfs_kde.sh

Script Bash per l'installazione automatica di Debian 12 su filesystem BTRFS (non cifrato) con KDE Plasma, Snapper e GRUB-BTRFS.

## Contenuto
- Creazione subvolumi BTRFS
- Installazione base con debootstrap
- Configurazione automatica fstab, hostname, rete
- Installazione KDE Plasma, Snapper, grub-btrfs
- Supporto EFI e BIOS fallback

## Uso
1. Prepara il volume BTRFS su /dev/mapper/VGO-LGO
2. Monta la partizione EFI su /dev/nvme0n1p1
3. Esegui:
   ```bash
   sudo bash deb_btrfs_kde.sh
   ```

## Licenza
MIT
