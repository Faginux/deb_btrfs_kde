# deb_btrfs_kde.sh

Script Bash per l'installazione automatica di Debian 12 su filesystem BTRFS (non cifrato) con KDE Plasma, Snapper e GRUB-BTRFS.

## Funzionalità

- Creazione automatica dei subvolumi BTRFS: `@`, `@home`, `@var`, `@tmp`, `@snapshots`
- Installazione base con `debootstrap`
- Configurazione automatica di `/etc/fstab`, `hostname`, `/etc/hosts` e rete
- Installazione di kernel Linux, KDE Plasma, Snapper e `grub-btrfs`
- Supporto per boot EFI e fallback BIOS
- Smontaggio automatico delle directory al termine

## Requisiti

- Un volume BTRFS già preparato (es: `/dev/mapper/VGO-LGO`)
- Partizione EFI già esistente (es: `/dev/nvme0n1p1`)
- Connessione a internet attiva durante l'installazione
- Esecuzione come utente **root**

## Clonazione del repository ed esecuzione

Puoi clonare questo repository utilizzando **GitHub CLI**:

gh repo clone Faginux/deb_btrfs_kde

Oppure usando **Git classico**:

git clone https://github.com/Faginux/deb_btrfs_kde.git

Dopo la clonazione, entra nella cartella del progetto:

cd deb_btrfs_kde

Rendi eseguibile lo script e avvialo con permessi root:

chmod +x deb_btrfs_kde.sh
sudo ./deb_btrfs_kde.sh

> Link repository GitHub: https://tinyurl.com/deb-btkde



Esecuzione diretta dello script da internet (opzionale)

Puoi anche eseguire direttamente lo script (a tuo rischio) tramite:

bash <(curl -s https://tinyurl.com/deb-btkde)

Oppure scaricarlo manualmente:

curl -O https://tinyurl.com/deb-btkde
chmod +x deb_btrfs_kde.sh
sudo ./deb_btrfs_kde.sh

Licenza

Questo progetto è distribuito sotto licenza MIT. Consulta il file LICENSE per i dettagli.


---

Autore: Oscar
