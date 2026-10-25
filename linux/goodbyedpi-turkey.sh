#!/usr/bin/env bash
# GoodbyeDPI-Turkey — Linux sürümü
#
# Windows'taki goodbyedpi.exe + .cmd dosyalarının Linux karşılığı. WinDivert
# yerine NFQUEUE ve zapret projesinin `nfqws` aracı kullanılır; böylece
# sistem genelinde çalışır, uygulama başına proxy ayarı gerekmez.
# DNS yönlendirmesi (Windows'taki --dns-addr/--dns-port) nftables DNAT ile
# yapılır: UDP 53 sorguları Yandex DNS'e (77.88.8.8:1253) gider.
#
# Kullanım:  ./goodbyedpi-turkey.sh [komut] [yöntem]
#   (komutsuz)  = start default
#   start       tek seferlik çalıştır (Ctrl-C ile durur, ayarlar geri alınır)
#   install     systemd hizmeti kur (açılışta otomatik başlar)
#   remove      hizmeti ve tüm kurulumu kaldır
#   stop        çalışan her şeyi durdur, nft tablosunu sil
#   status      durumu göster
#   methods     yöntem tablosunu göster
#   setup       nfqws'i indir ve doğrula
#   build       nfqws'i kaynak koddan derle (yedek yol)
#
# Lisans: Apache-2.0 (proje ile aynı).

set -u

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
ORIG_ARGS=("$@")

# ---- sabitler ---------------------------------------------------------------

BIN_DIR="${SCRIPT_DIR}/bin"
NFT_TABLE="goodbyedpi_turkey"
QNUM=200
MARK="0x40000000"

# Windows scriptlerindeki --dns-addr/--dns-port ve --dnsv6-addr/--dnsv6-port
DNS4="77.88.8.8"
DNS6="2a02:6b8::feed:0ff"
DNS_PORT=1253

ZAPRET_VERSION="v72.13"
ZAPRET_URL="https://github.com/bol-van/zapret/releases/download/${ZAPRET_VERSION}/zapret-${ZAPRET_VERSION}.tar.gz"
ZAPRET_SHA256="25c74e6c5f48963fa244c2955e76694a07c39447245a0457e2efdc74b3317e68"

INSTALL_DIR="/opt/goodbyedpi-turkey"
UNIT_NAME="goodbyedpi-turkey.service"
UNIT_PATH="/etc/systemd/system/${UNIT_NAME}"

# ---- günlükleme -------------------------------------------------------------

if [[ -t 1 ]]; then
    C_B=$'\033[1;34m'; C_Y=$'\033[1;33m'; C_R=$'\033[1;31m'; C_0=$'\033[0m'
else
    C_B=""; C_Y=""; C_R=""; C_0=""
fi
log()  { printf '%s[goodbyedpi-turkey]%s %s\n' "$C_B" "$C_0" "$*"; }
warn() { printf '%s[goodbyedpi-turkey]%s %s\n' "$C_Y" "$C_0" "$*" >&2; }
err()  { printf '%s[goodbyedpi-turkey]%s %s\n' "$C_R" "$C_0" "$*" >&2; }
die()  { err "$*"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# ---- yöntemler --------------------------------------------------------------
#
# Windows .cmd dosyalarıyla eşleşme:
#   default : -5 --set-ttl 5 + DNS       alt  : --set-ttl 3
#   alt2    : -5                         alt3 : --set-ttl 3 + DNS
#   alt4    : -5 + DNS                   alt5 : -9 + DNS
#   alt6    : -9
# (Windows'taki -9 ayrıca QUIC'i engeller; bu sürümde karşılığı yoktur.)

METHODS=(default alt alt2 alt3 alt4 alt5 alt6)

# Seçilen yöntemi M_ARGS (nfqws argümanları), M_DNS (0/1) ve M_WIN (açıklama)
# değişkenlerine yükler. Bilinmeyen yöntemde 1 döner.
load_method() {
    M_NAME="$1"
    case "$1" in
        default)
            M_ARGS=('--dpi-desync=fake,multidisorder' --dpi-desync-split-pos=2 --dpi-desync-ttl=5)
            M_DNS=1; M_WIN="-5 --set-ttl 5 + DNS" ;;
        alt)
            M_ARGS=(--dpi-desync=fake --dpi-desync-ttl=3)
            M_DNS=0; M_WIN="--set-ttl 3" ;;
        alt2)
            M_ARGS=('--dpi-desync=fake,multidisorder' --dpi-desync-split-pos=2 --dpi-desync-autottl --dpi-desync-ttl=5)
            M_DNS=0; M_WIN="-5" ;;
        alt3)
            M_ARGS=(--dpi-desync=fake --dpi-desync-ttl=3)
            M_DNS=1; M_WIN="--set-ttl 3 + DNS" ;;
        alt4)
            M_ARGS=('--dpi-desync=fake,multidisorder' --dpi-desync-split-pos=2 --dpi-desync-autottl --dpi-desync-ttl=5)
            M_DNS=1; M_WIN="-5 + DNS" ;;
        alt5)
            M_ARGS=('--dpi-desync=fake,multidisorder' --dpi-desync-split-pos=2 '--dpi-desync-fooling=badsum,badseq')
            M_DNS=1; M_WIN="-9 + DNS" ;;
        alt6)
            M_ARGS=('--dpi-desync=fake,multidisorder' --dpi-desync-split-pos=2 '--dpi-desync-fooling=badsum,badseq')
            M_DNS=0; M_WIN="-9" ;;
        *)
            return 1 ;;
    esac
    return 0
}

require_method() {
    load_method "$1" || die "Bilinmeyen yöntem: '$1'. Geçerli yöntemler: ${METHODS[*]}"
}

# ---- yetki ------------------------------------------------------------------

need_root() {
    [[ $EUID -eq 0 ]] && return 0
    have sudo || die "Root yetkisi gerekiyor ve sudo bulunamadı. Betiği root olarak çalıştırın."
    log "Root yetkisi gerekiyor — sudo ile yeniden başlatılıyor..."
    exec sudo -- "$SCRIPT_PATH" ${ORIG_ARGS[@]+"${ORIG_ARGS[@]}"}
}

# ---- nfqws ikilisi ----------------------------------------------------------

NFQWS=""

resolve_nfqws() {
    if [[ -x "${BIN_DIR}/nfqws" ]]; then
        NFQWS="${BIN_DIR}/nfqws"
    elif have nfqws; then
        NFQWS="$(command -v nfqws)"
    else
        log "nfqws bulunamadı; zapret ${ZAPRET_VERSION} indiriliyor..."
        do_setup || die "nfqws kurulamadı. Yedek yol: sudo $0 build"
        NFQWS="${BIN_DIR}/nfqws"
    fi
}

# İndir, SHA256 doğrula, mimariye uygun nfqws'i bin/ altına koy.
# Alt kabukta çalışır; kendi geçici klasörünü kendisi temizler.
do_setup() (
    local arch tmp actual member ver
    case "$(uname -m)" in
        x86_64|amd64)               arch="linux-x86_64" ;;
        i386|i486|i586|i686)        arch="linux-x86" ;;
        aarch64|arm64)              arch="linux-arm64" ;;
        armv6l|armv7l|armv8l|arm)   arch="linux-arm" ;;
        *)
            err "Bu mimari için hazır nfqws yok ($(uname -m)). Şunu deneyin: sudo $0 build"
            exit 1 ;;
    esac
    have tar        || { err "'tar' bulunamadı.";        exit 1; }
    have sha256sum  || { err "'sha256sum' bulunamadı.";  exit 1; }
    have curl || have wget || { err "İndirmek için curl veya wget gerekli."; exit 1; }

    tmp="$(mktemp -d)" || exit 1
    trap 'rm -rf "$tmp"' EXIT

    log "İndiriliyor: ${ZAPRET_URL}"
    if have curl; then
        curl -fsSL --retry 3 -o "${tmp}/zapret.tar.gz" "$ZAPRET_URL" || { err "İndirme başarısız."; exit 1; }
    else
        wget -q -O "${tmp}/zapret.tar.gz" "$ZAPRET_URL" || { err "İndirme başarısız."; exit 1; }
    fi

    actual="$(sha256sum "${tmp}/zapret.tar.gz" | awk '{print $1}')"
    if [[ "$actual" != "$ZAPRET_SHA256" ]]; then
        err "SHA256 uyuşmuyor, ikili KURULMADI."
        err "  beklenen: ${ZAPRET_SHA256}"
        err "  bulunan : ${actual}"
        exit 1
    fi
    log "SHA256 doğrulandı."

    member="zapret-${ZAPRET_VERSION}/binaries/${arch}/nfqws"
    tar -xzf "${tmp}/zapret.tar.gz" -C "$tmp" "$member" || { err "Arşivden nfqws çıkarılamadı (${member})."; exit 1; }

    install -d -m 0755 "$BIN_DIR" || exit 1
    install -m 0755 "${tmp}/${member}" "${BIN_DIR}/nfqws" || exit 1

    ver="$("${BIN_DIR}/nfqws" --version 2>&1 | head -n 1)"
    if [[ "$ver" != *"$ZAPRET_VERSION"* ]]; then
        err "Kurulan nfqws çalıştırılamadı veya sürümü beklenmedik: '${ver}'"
        rm -f "${BIN_DIR}/nfqws"
        exit 1
    fi
    log "nfqws kuruldu: ${BIN_DIR}/nfqws (${ver})"
)

# ---- nftables ---------------------------------------------------------------

table_exists() { nft list table inet "$NFT_TABLE" >/dev/null 2>&1; }

# Tabloyu siler ve gerçekten gittiğini doğrular. Başarısızlığı görünür kılar.
delete_table() {
    local out=""
    for _ in 1 2 3; do
        table_exists || return 0
        out="$(nft delete table inet "$NFT_TABLE" 2>&1)" || true
        table_exists || return 0
        sleep 0.3
    done
    err "nft tablosu SİLİNEMEDİ: ${out:-bilinmeyen hata}"
    err "Elle silmek için: sudo nft delete table inet ${NFT_TABLE}"
    return 1
}

# Kural setini üretir. $1: DNS yönlendirmesi var mı (0/1).
rules_text() {
    local dns="$1"
    cat <<EOF
table inet ${NFT_TABLE} {
    chain post {
        type filter hook postrouting priority mangle; policy accept;
        meta mark and ${MARK} != 0 ct mark set ct mark or ${MARK}
        oifname != "lo" meta mark and ${MARK} == 0 tcp dport 443 ct original packets 1-6 queue num ${QNUM} bypass
        oifname != "lo" meta mark and ${MARK} == 0 tcp dport 80 queue num ${QNUM} bypass
    }
    chain pre {
        type filter hook prerouting priority filter; policy accept;
        icmp type time-exceeded ct mark and ${MARK} != 0 drop
        icmpv6 type time-exceeded ct mark and ${MARK} != 0 drop
        iifname != "lo" tcp sport { 80, 443 } ct reply packets 1-3 queue num ${QNUM} bypass
    }
EOF
    if [[ "$dns" == "1" ]]; then
        cat <<EOF
    chain dnsredir {
        type nat hook output priority dstnat; policy accept;
        ip daddr != 127.0.0.0/8 udp dport 53 dnat ip to ${DNS4}:${DNS_PORT}
        ip6 daddr != ::1 udp dport 53 dnat ip6 to [${DNS6}]:${DNS_PORT}
    }
EOF
    fi
    echo "}"
}

# Eski tabloyu siler, yenisini yükler. $1: DNS yönlendirmesi (0/1).
load_rules() {
    local dns="$1" out
    have nft || { err "nft (nftables) bulunamadı. Kurulum: Fedora 'sudo dnf install nftables', Debian/Ubuntu 'sudo apt install nftables', Arch 'sudo pacman -S nftables'"; return 1; }
    modprobe nfnetlink_queue 2>/dev/null || true
    delete_table || return 1
    if ! out="$(rules_text "$dns" | nft -f - 2>&1)"; then
        err "nft kuralları yüklenemedi: ${out}"
        err "Çekirdekte nfnetlink_queue / nft_queue desteği gerekir."
        delete_table || true
        return 1
    fi
    if [[ "$dns" == "1" ]] && have resolvectl; then
        resolvectl flush-caches >/dev/null 2>&1 || true
    fi
    return 0
}

# ---- süreç yardımcıları -----------------------------------------------------

# nfqws, kendi argv belleğini ayrıştırırken değiştirir (virgüller NUL olur);
# bu yüzden eşleşmeyi yalnızca değişmeyen "nfqws --qnum=N" kısmıyla yapıyoruz.
nfqws_pids() { pgrep -f -- "nfqws --qnum=${QNUM}" 2>/dev/null || true; }

stop_nfqws() {
    local pids
    pids="$(nfqws_pids)"
    [[ -z "$pids" ]] && return 0
    # shellcheck disable=SC2086
    kill -TERM $pids 2>/dev/null || true
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        sleep 0.3
        [[ -z "$(nfqws_pids)" ]] && return 0
    done
    warn "nfqws TERM'e yanıt vermedi, KILL gönderiliyor."
    pids="$(nfqws_pids)"
    # shellcheck disable=SC2086
    [[ -n "$pids" ]] && kill -KILL $pids 2>/dev/null || true
    sleep 0.3
    return 0
}

svc_installed() { [[ -f "$UNIT_PATH" ]]; }
svc_active()    { have systemctl && systemctl is-active --quiet "$UNIT_NAME" 2>/dev/null; }

# ---- start (tek seferlik) ---------------------------------------------------

CLEANED=0
NFQWS_PID=""

cleanup() {
    trap '' INT TERM HUP
    (( CLEANED )) && return 0
    CLEANED=1
    log "Durduruluyor ve temizleniyor..."
    if [[ -n "$NFQWS_PID" ]] && kill -0 "$NFQWS_PID" 2>/dev/null; then
        kill -TERM "$NFQWS_PID" 2>/dev/null || true
        for _ in 1 2 3 4 5 6 7 8 9 10; do
            kill -0 "$NFQWS_PID" 2>/dev/null || break
            sleep 0.3
        done
        kill -0 "$NFQWS_PID" 2>/dev/null && kill -KILL "$NFQWS_PID" 2>/dev/null
    fi
    [[ -n "$NFQWS_PID" ]] && wait "$NFQWS_PID" 2>/dev/null
    if delete_table; then
        log "nft tablosu silindi."
    else
        err "Temizlik tamamlanamadı; tablo hâlâ duruyor olabilir."
    fi
    return 0
}

check_not_running() {
    local pids
    if svc_active; then
        die "Hizmet zaten etkin. Durdurmak için: sudo $0 stop   (kaldırmak için: sudo $0 remove)"
    fi
    pids="$(nfqws_pids | tr '\n' ' ')"
    if [[ -n "${pids// /}" ]]; then
        die "nfqws zaten çalışıyor (PID: ${pids}). Durdurmak için: sudo $0 stop"
    fi
    if table_exists; then
        warn "Bayat nft tablosu bulundu (nfqws çalışmıyor); siliniyor..."
        delete_table || die "Bayat tablo silinemedi."
    fi
}

cmd_start() {
    need_root
    require_method "${1:-default}"
    resolve_nfqws
    check_not_running

    log "Yöntem: ${M_NAME} (Windows: ${M_WIN}; DNS yönlendirme: $([[ $M_DNS == 1 ]] && echo evet || echo hayır))"

    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP

    load_rules "$M_DNS" || exit 1

    log "nfqws başlatılıyor: ${NFQWS} --qnum=${QNUM} ${M_ARGS[*]}"
    "$NFQWS" --qnum="$QNUM" "${M_ARGS[@]}" &
    NFQWS_PID=$!

    sleep 1
    if ! kill -0 "$NFQWS_PID" 2>/dev/null; then
        local rc=0
        wait "$NFQWS_PID" || rc=$?
        die "nfqws başlayamadı (çıkış kodu ${rc}). Çekirdekte nfnetlink_queue yüklü mü? Ayrıntı için yukarıdaki nfqws çıktısına bakın."
    fi
    log "GoodbyeDPI-Turkey çalışıyor. Durdurmak için Ctrl-C."

    local rc=0
    wait "$NFQWS_PID" || rc=$?
    # Buraya yalnızca nfqws kendi kendine çıkarsa ulaşılır (sinyallerde trap exit eder).
    err "nfqws beklenmedik şekilde sonlandı (çıkış kodu ${rc})."
    exit $(( rc == 0 ? 1 : rc ))
}

# ---- stop / status ----------------------------------------------------------

cmd_stop() {
    need_root
    if svc_active; then
        log "Hizmet etkin, systemctl stop ile durduruluyor..."
        systemctl stop "$UNIT_NAME" || warn "systemctl stop başarısız oldu."
    fi
    stop_nfqws
    delete_table || exit 1
    log "Durduruldu: nfqws çalışmıyor, nft tablosu yok."
}

cmd_status() {
    need_root
    local pids stale=0
    echo "== Hizmet =="
    if svc_installed; then
        echo "kurulu: evet  etkin: $(systemctl is-enabled "$UNIT_NAME" 2>/dev/null || echo ?)  durum: $(systemctl is-active "$UNIT_NAME" 2>/dev/null || echo ?)"
    else
        echo "kurulu: hayır"
    fi
    echo "== nft tablosu =="
    pids="$(nfqws_pids | tr '\n' ' ')"
    if table_exists; then
        echo "inet ${NFT_TABLE}: VAR"
        nft list table inet "$NFT_TABLE"
        if [[ -z "${pids// /}" ]] && ! svc_active; then stale=1; fi
    else
        echo "inet ${NFT_TABLE}: yok"
    fi
    echo "== nfqws =="
    if [[ -n "${pids// /}" ]]; then
        # shellcheck disable=SC2086
        ps -o pid=,args= -p ${pids} 2>/dev/null || echo "PID: ${pids}"
    else
        echo "çalışmıyor"
    fi
    if [[ -x "${BIN_DIR}/nfqws" ]]; then
        echo "ikili: ${BIN_DIR}/nfqws ($("${BIN_DIR}/nfqws" --version 2>&1 | head -n 1))"
    fi
    if (( stale )); then
        warn "BAYAT: nft tablosu duruyor ama nfqws çalışmıyor. Temizlemek için: sudo $0 stop"
    fi
}

cmd_methods() {
    printf '%-8s %-22s %-6s %s\n' "YONTEM" "WINDOWS" "DNS" "NFQWS ARGUMANLARI"
    local m
    for m in "${METHODS[@]}"; do
        load_method "$m"
        printf '%-8s %-22s %-6s %s\n' "$m" "$M_WIN" "$([[ $M_DNS == 1 ]] && echo evet || echo hayir)" "${M_ARGS[*]}"
    done
}

# ---- systemd hizmeti --------------------------------------------------------

# Unit dosyasını üretir. $1: yöntem. Argümanlar systemd'in ayrıştırmasında
# bozulmasın diye güvenli karakter kümesiyle sınırlıdır.
render_unit() {
    local method="$1" a
    require_method "$method"
    for a in "${M_ARGS[@]}"; do
        [[ "$a" =~ ^[A-Za-z0-9=,._:+/@-]+$ ]] || die "Güvenli olmayan argüman unit'e yazılamaz: '$a'"
    done
    cat <<EOF
[Unit]
Description=GoodbyeDPI-Turkey (nfqws, yöntem: ${method})
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStartPre=${INSTALL_DIR}/goodbyedpi-turkey.sh _load ${method}
ExecStart=${INSTALL_DIR}/bin/nfqws --qnum=${QNUM} ${M_ARGS[*]}
ExecStopPost=${INSTALL_DIR}/goodbyedpi-turkey.sh _unload
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
}

cmd_install() {
    need_root
    have systemctl || die "systemd bulunamadı; hizmet kurulumu desteklenmiyor. Tek seferlik kullanım için: sudo $0 start"
    require_method "${1:-default}"
    local method="$M_NAME"
    resolve_nfqws

    # Terminalde 'start' ile çalışan bir kopya varsa hizmetle çakışmasın.
    if ! svc_active && [[ -n "$(nfqws_pids)" ]]; then
        die "Hizmet dışında bir nfqws çalışıyor (ör. 'start' ile). Önce durdurun: sudo $0 stop"
    fi

    systemctl stop "$UNIT_NAME" 2>/dev/null || true
    stop_nfqws
    delete_table || die "Eski nft tablosu silinemedi."

    # Hizmet root sahipli kopyadan çalışır: kullanıcı klasöründeki bir dosya
    # root olarak çalıştırılmasın.
    if [[ "$SCRIPT_DIR" != "$INSTALL_DIR" ]]; then
        log "Dosyalar ${INSTALL_DIR} altına kopyalanıyor (root:root)..."
        install -d -m 0755 -o root -g root "${INSTALL_DIR}" "${INSTALL_DIR}/bin" || die "Klasör oluşturulamadı."
        install -m 0755 -o root -g root "$SCRIPT_PATH" "${INSTALL_DIR}/goodbyedpi-turkey.sh" || die "Betik kopyalanamadı."
        install -m 0755 -o root -g root "$NFQWS" "${INSTALL_DIR}/bin/nfqws" || die "nfqws kopyalanamadı."
    fi

    log "Hizmet dosyası yazılıyor: ${UNIT_PATH}"
    render_unit "$method" > "$UNIT_PATH" || die "Unit yazılamadı."
    chmod 0644 "$UNIT_PATH"

    systemctl daemon-reload || die "systemctl daemon-reload başarısız."
    systemctl enable --now "$UNIT_NAME" || die "Hizmet etkinleştirilemedi. Ayrıntı: journalctl -u ${UNIT_NAME} -b"
    sleep 2
    if svc_active; then
        log "Hizmet kuruldu ve başlatıldı (yöntem: ${method})."
        log "Durum: sudo $0 status   |   Kaldırmak için: sudo $0 remove"
    else
        err "Hizmet kuruldu ama çalışmıyor. Ayrıntı: journalctl -u ${UNIT_NAME} -b"
        exit 1
    fi
}

cmd_remove() {
    need_root
    log "Hizmet durduruluyor ve kaldırılıyor..."
    if have systemctl; then
        systemctl disable --now "$UNIT_NAME" >/dev/null 2>&1 || true
    fi
    rm -f "$UNIT_PATH"
    if have systemctl; then
        systemctl daemon-reload >/dev/null 2>&1 || true
        systemctl reset-failed "$UNIT_NAME" >/dev/null 2>&1 || true
    fi
    stop_nfqws
    delete_table || warn "nft tablosu silinemedi (yukarıya bakın)."
    rm -rf -- "$INSTALL_DIR"
    log "Temizlendi: hizmet, ${INSTALL_DIR} ve nft tablosu."
}

# systemd'in çağırdığı iç komutlar.
internal_load() {
    [[ $EUID -eq 0 ]] || die "_load yalnızca root ile çalışır."
    require_method "${1:-default}"
    load_rules "$M_DNS"
}
internal_unload() {
    [[ $EUID -eq 0 ]] || exit 1
    delete_table
}

# ---- kurulum komutları ------------------------------------------------------

cmd_setup() {
    need_root
    if [[ -x "${BIN_DIR}/nfqws" ]]; then
        log "nfqws zaten kurulu: ${BIN_DIR}/nfqws ($("${BIN_DIR}/nfqws" --version 2>&1 | head -n 1))"
        return 0
    fi
    do_setup
}

cmd_build() {
    need_root
    local tool tmp
    for tool in git make cc; do
        have "$tool" || die "'${tool}' gerekli. Debian/Ubuntu: sudo apt install git make gcc | Fedora: sudo dnf install git make gcc | Arch: sudo pacman -S git base-devel"
    done
    tmp="$(mktemp -d)" || exit 1
    log "zapret ${ZAPRET_VERSION} kaynak kodu indiriliyor..."
    if ! git clone --depth 1 --branch "$ZAPRET_VERSION" https://github.com/bol-van/zapret.git "${tmp}/zapret"; then
        rm -rf "$tmp"; die "Klonlama başarısız."
    fi
    log "Derleniyor (make -C nfq)..."
    if ! make -C "${tmp}/zapret/nfq"; then
        rm -rf "$tmp"
        err "Derleme başarısız. Gerekli geliştirme paketleri:"
        err "  Debian/Ubuntu: sudo apt install make gcc zlib1g-dev libcap-dev libnetfilter-queue-dev libmnl-dev"
        err "  Fedora       : sudo dnf install make gcc zlib-devel libcap-devel libnetfilter_queue-devel libmnl-devel"
        err "  Arch         : sudo pacman -S base-devel zlib libcap libnetfilter_queue libmnl"
        exit 1
    fi
    install -d -m 0755 "$BIN_DIR" || { rm -rf "$tmp"; exit 1; }
    install -m 0755 "${tmp}/zapret/nfq/nfqws" "${BIN_DIR}/nfqws" || { rm -rf "$tmp"; exit 1; }
    rm -rf "$tmp"
    log "nfqws derlendi: ${BIN_DIR}/nfqws ($("${BIN_DIR}/nfqws" --version 2>&1 | head -n 1))"
}

usage() {
    cat <<EOF
GoodbyeDPI-Turkey — Linux sürümü

Kullanım: $0 [komut] [yöntem]

  (komutsuz)         'start default' ile aynı
  start [yöntem]     tek seferlik çalıştır; Ctrl-C ile durur, ayarlar geri alınır
  install [yöntem]   systemd hizmeti kur (açılışta otomatik başlar)
  remove             hizmeti ve tüm kurulumu kaldır
  stop               çalışan her şeyi durdur, nft tablosunu sil
  status             durumu göster
  methods            yöntem tablosunu göster
  setup              nfqws'i indir ve doğrula
  build              nfqws'i kaynak koddan derle (yedek yol)

Yöntemler: ${METHODS[*]}   (varsayılan: default)
EOF
}

main() {
    local cmd="${1:-start}"
    case "$cmd" in
        start)                              shift; cmd_start "${1:-default}" ;;
        default|alt|alt2|alt3|alt4|alt5|alt6) cmd_start "$cmd" ;;
        install)                            shift; cmd_install "${1:-default}" ;;
        remove|uninstall)                   cmd_remove ;;
        stop)                               cmd_stop ;;
        status)                             cmd_status ;;
        methods)                            cmd_methods ;;
        setup)                              cmd_setup ;;
        build)                              cmd_build ;;
        _load)                              shift; internal_load "${1:-default}" ;;
        _unload)                            internal_unload ;;
        _unit)                              shift; render_unit "${1:-default}" ;;
        _rules)                             shift; require_method "${1:-default}"; rules_text "$M_DNS" ;;
        -h|--help|help)                     usage ;;
        *)                                  err "Bilinmeyen komut: ${cmd}"; usage >&2; exit 2 ;;
    esac
}

main "$@"
