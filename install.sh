#!/usr/bin/env bash
set -e

# Root yetkisi kontrolü
if [[ $EUID -ne 0 ]]; then
    echo ">> Root yetkisi gerekiyor. Sudo ile yeniden başlatılıyor..."
    exec sudo -- "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
METHOD="${1:-default}"

echo "=========================================================="
echo "  GoodbyeDPI-Turkey (Linux) — Kurulum Başlatılıyor (yöntem: ${METHOD})"
echo "=========================================================="

# Otomatik bağımlılık kontrolü ve bildirimi
MISSING=""
for cmd in nft curl tar sha256sum; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING="$MISSING $cmd"
    fi
done

if [[ -n "$MISSING" ]]; then
    echo ">> Eksik paketler tespit edildi:$MISSING"
    echo ">> Otomatik kurulmaya çalışılıyor..."
    if command -v apt >/dev/null 2>&1; then
        apt update && apt install -y nftables curl tar coreutils
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y nftables curl tar coreutils
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm nftables curl tar coreutils
    elif command -v zypper >/dev/null 2>&1; then
        zypper install -y nftables curl tar coreutils
    else
        echo "[UYARI] Paket yöneticisi otomatik algılanamadı. Lütfen şu paketleri kurun:$MISSING"
    fi
fi

# Kurulumu gerçekleştir (systemd servisi olarak kurar ve açılışta otomatik başlatır)
bash "${SCRIPT_DIR}/linux/goodbyedpi-turkey.sh" install "${METHOD}"

echo ""
echo "=========================================================="
echo "  Kurulum Başarıyla Tamamlandı!"
echo "  - GoodbyeDPI arka planda çalışıyor."
echo "  - Bilgisayarınızı yeniden başlatsanız bile otomatik açılır."
echo "  - Kaldırmak istediğinizde: sudo ./remove.sh"
echo "=========================================================="
