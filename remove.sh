#!/usr/bin/env bash
set -e

# Root yetkisi kontrolü
if [[ $EUID -ne 0 ]]; then
    echo ">> Root yetkisi gerekiyor. Sudo ile yeniden başlatılıyor..."
    exec sudo -- "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "  GoodbyeDPI-Turkey (Linux) — Kaldırılıyor"
echo "=========================================================="

bash "${SCRIPT_DIR}/linux/goodbyedpi-turkey.sh" remove

echo ""
echo "=========================================================="
echo "  GoodbyeDPI-Turkey sistemden tamamen kaldırıldı!"
echo "  - Arka plan servisi durduruldu ve devre dışı bırakıldı."
echo "  - Güvenlik duvarı kuralları temizlendi."
echo "=========================================================="
