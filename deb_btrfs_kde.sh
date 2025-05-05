#!/bin/bash
# deb_btrfs_kde.sh
# Installazione automatica di Debian 12 su BTRFS non cifrato, con KDE Plasma, Snapper e GRUB-BTRFS
# Autore: Oscar
# Licenza: MIT
# Ultimo aggiornamento: 2025-05-05
set -e

# === Variabili personalizzabili ===
BTRFS_DEV="/dev/mapper/VGO-LGO"
EFI_DEV="/dev/nvme0n1p1"
HOSTNAME="Debian-IT12"
NEWUSER="oscar-it12"
NEWUSER_PW="it12"

# === Controllo comandi richiesti ===
for cmd in btrfs debootstrap grub-install snapper; do
  command -v $cmd >/dev/null 2>&1 || { echo "Comando richiesto mancante: $cmd"; exit 1; }
done

echo "Monto $BTRFS_DEV su /mnt (subvolid=5)..."
mount -t btrfs -o subvolid=5 "$BTRFS_DEV" /mnt

echo "Subvolumi presenti:"
btrfs subvolume list /mnt

echo -e "\n*** ATTENZIONE: verranno rimossi i subvolumi @, @home, @snapshots, @var, @tmp ***"
echo "Vuoi continuare?"
select ans in "Si" "No"; do
    case $ans in
        Si ) break;;
        No ) echo "Annullato"; umount /mnt; exit 1;;
    esac
done

for sub in @ @home @snapshots @var @tmp; do
  btrfs subvolume delete "/mnt/$sub" 2>/dev/null || true
done

echo "Creo subvolumi..."
for sub in @ @home @snapshots @var @tmp; do
  btrfs subvolume create "/mnt/$sub"
done
umount /mnt

echo -e "\nMonto subvolumi sotto /mnt..."
mount -t btrfs -o subvol=@ "$BTRFS_DEV" /mnt
mkdir -p /mnt/{home,.snapshots,var,tmp,boot/efi}
chmod 750 /mnt/.snapshots
chown root:root /mnt/.snapshots

mount -t btrfs -o subvol=@home "$BTRFS_DEV" /mnt/home
mount -t btrfs -o subvol=@snapshots "$BTRFS_DEV" /mnt/.snapshots
mount -t btrfs -o subvol=@var "$BTRFS_DEV" /mnt/var
mount -t btrfs -o subvol=@tmp "$BTRFS_DEV" /mnt/tmp

echo "Monto EFI ($EFI_DEV) su /mnt/boot/efi..."
mount "$EFI_DEV" /mnt/boot/efi

echo "Eseguire debootstrap Bookworm su /mnt?"
select ans in "Si" "No"; do
    case $ans in
        Si ) break;;
        No ) echo "Annullato"; exit 1;;
    esac
done

debootstrap bookworm /mnt http://deb.debian.org/debian/

echo "Configuro fstab e hostname..."
B_UUID=$(blkid -s UUID -o value "$BTRFS_DEV")
E_UUID=$(blkid -s UUID -o value "$EFI_DEV")

cat > /mnt/etc/fstab <<EOF
UUID=$B_UUID /            btrfs defaults,subvol=@            0 0
UUID=$B_UUID /home        btrfs defaults,subvol=@home        0 0
UUID=$B_UUID /var         btrfs defaults,subvol=@var         0 0
UUID=$B_UUID /tmp         btrfs defaults,subvol=@tmp         0 0
UUID=$B_UUID /.snapshots  btrfs defaults,subvol=@snapshots   0 0
UUID=$E_UUID /boot/efi    vfat    umask=0077                 0 2
EOF

echo "$HOSTNAME" > /mnt/etc/hostname

cat > /mnt/etc/hosts <<EOF
127.0.0.1 localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOF

cat > /mnt/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback
EOF

for fs in dev dev/pts proc sys; do
  mount --bind /$fs /mnt/$fs
done
cp -L /etc/resolv.conf /mnt/etc/resolv.conf

echo "Installare kernel, grub-efi, snapper e KDE Plasma?"
select ans in "Si" "No"; do
    case $ans in
        Si ) break;;
        No ) echo "Annullato"; exit 1;;
    esac
done

chroot /mnt /bin/bash <<'CHROOT'
set -e

echo "Europe/Rome" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
echo "it_IT.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
update-locale LANG=it_IT.UTF-8

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y   linux-image-amd64 grub-efi-amd64 btrfs-progs snapper sudo inotify-tools git make   build-essential kde-plasma-desktop sddm

if ! dpkg -s grub-btrfs >/dev/null 2>&1; then
  git clone https://github.com/Antynea/grub-btrfs.git /root/grub-btrfs-src
  cd /root/grub-btrfs-src && make install
fi

snapper -c root create-config /

umount /.snapshots 2>/dev/null || true
rm -rf /.snapshots/*
mkdir /.snapshots
mount -o subvol=@snapshots $BTRFS_DEV /.snapshots

systemctl enable grub-btrfsd
update-initramfs -u -k all
update-grub

if [ -d /sys/firmware/efi ]; then
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=debian --recheck
else
  grub-install /dev/sda
fi

useradd -m -G sudo -s /bin/bash oscar-it12
echo "oscar-it12:it12" | chpasswd
passwd -l root
CHROOT

echo "Smonto tutte le directory..."
umount --recursive /mnt || true

echo "=== Installazione completata! Riavvia il sistema. ==="
