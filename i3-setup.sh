#!/bin/bash

set -e

echo "=== i3 POS-INSTALAÇÃO ==="
echo "Este script instala um ambiente i3 com polybar, tray, clipboard, som e mais."
echo
read -p "Seu sistema é [a]rch ou [d]ebian? " distro

install_arch() {
  echo "[+] Instalando pacotes para Arch Linux..."
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm i3 polybar network-manager-applet pasystray clipit gsimplecal ttf-ubuntu-font-family xorg xterm
}

install_debian() {
  echo "[+] Instalando pacotes para Debian..."
  sudo apt update
  sudo apt install -y i3 polybar network-manager-gnome pasystray clipit gsimplecal fonts-ubuntu xorg xterm
}

setup_autostart() {
  echo "[+] Criando autostart no i3..."
  mkdir -p ~/.config/i3
  cat > ~/.config/i3/config <<EOF
exec_always --no-startup-id nm-applet
exec_always --no-startup-id pasystray
exec_always --no-startup-id clipit
exec_always --no-startup-id gsimplecal
exec_always --no-startup-id ~/.config/polybar/launch.sh
EOF
}

setup_polybar() {
  echo "[+] Configurando Polybar..."
  mkdir -p ~/.config/polybar
  cat > ~/.config/polybar/launch.sh <<EOF
#!/bin/bash
killall -q polybar
while pgrep -u \$UID -x polybar >/dev/null; do sleep 1; done
polybar mybar &
EOF
  chmod +x ~/.config/polybar/launch.sh

  cat > ~/.config/polybar/config.ini <<EOF
[bar/mybar]
width = 100%
height = 25
font-0 = "Ubuntu:size=10;2"
modules-left = i3
modules-center = clock
modules-right = pulseaudio network clipboard tray

[module/clock]
type = internal/date
format = %H:%M
click-left = gsimplecal

[module/network]
type = internal/network
interface = wlan0
format-connected = " %signal%%"
format-disconnected = "⚠️"

[module/pulseaudio]
type = internal/pulseaudio
format-volume = " %volume%%"

[module/clipboard]
type = custom/script
exec = echo "📋"
click-left = clipit

[module/tray]
type = internal/tray
EOF
}

# --- Execução
case "$distro" in
  a|A)
    install_arch
    ;;
  d|D)
    install_debian
    ;;
  *)
    echo "Opção inválida. Use 'a' para Arch ou 'd' para Debian."
    exit 1
    ;;
esac

setup_autostart
setup_polybar

echo "[✓] Instalação concluída. Reinicie a sessão para carregar o i3 com polybar."
