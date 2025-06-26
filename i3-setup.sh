#!/bin/bash
set -e

echo "=== Instalação do i3 com Polybar, PipeWire, Bluetooth e Tray ==="
read -p "Seu sistema é [a]rch ou [d]ebian? " distro

install_arch() {
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm i3 polybar lightdm lightdm-gtk-greeter \
    kitty feh scrot network-manager-applet networkmanager-openvpn \
    pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber \
    blueman bluez bluez-utils copyq gsimplecal \
    ttf-ubuntu-font-family xorg imagemagick
  sudo systemctl enable lightdm
  sudo systemctl enable NetworkManager
  sudo systemctl enable bluetooth
}

install_debian() {
  sudo apt update && sudo apt install -y \
    i3 polybar lightdm lightdm-gtk-greeter \
    kitty feh scrot network-manager-gnome network-manager-openvpn \
    pipewire pipewire-audio wireplumber \
    blueman bluetooth bluez clipit gsimplecal \
    fonts-ubuntu xorg imagemagick
  sudo systemctl enable lightdm
  sudo systemctl enable NetworkManager
  sudo systemctl enable bluetooth
}

setup_i3_config() {
  mkdir -p ~/.config/i3
  CLIP_CMD="copyq"
  [ "$distro" = "d" ] || [ "$distro" = "D" ] && CLIP_CMD="clipit"

  cat > ~/.config/i3/config <<EOF
set \$mod Mod4
font pango:Ubuntu 10

exec_always --no-startup-id nm-applet
exec_always --no-startup-id blueman-applet
exec_always --no-startup-id $CLIP_CMD
exec_always --no-startup-id pipewire &
exec_always --no-startup-id wireplumber &
exec_always --no-startup-id feh --bg-scale ~/Pictures/wallpaper.jpg
exec_always --no-startup-id gsimplecal &
exec_always --no-startup-id ~/.config/polybar/launch.sh

# Atalhos principais
bindsym \$mod+Return exec kitty
bindsym \$mod+d exec dmenu_run
bindsym \$mod+Shift+q kill
bindsym \$mod+Shift+s exec scrot -s -e 'mv \$f ~/Pictures/Screenshots/'

# Navegação
bindsym \$mod+Left focus left
bindsym \$mod+Right focus right
bindsym \$mod+Up focus up
bindsym \$mod+Down focus down

# Janela
bindsym \$mod+f fullscreen toggle
bindsym \$mod+Shift+space floating toggle

# Reiniciar/fechar i3
bindsym \$mod+Shift+r restart
bindsym \$mod+Shift+e exit

# Workspaces
bindsym \$mod+1 workspace 1
bindsym \$mod+2 workspace 2
bindsym \$mod+3 workspace 3
bindsym \$mod+4 workspace 4
bindsym \$mod+5 workspace 5
EOF
}

setup_polybar() {
  mkdir -p ~/.config/polybar

  # launch.sh
  cat > ~/.config/polybar/launch.sh <<'EOF'
#!/bin/bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
MONITOR=$(polybar --list-monitors | cut -d: -f1 | head -n1)
MONITOR=$MONITOR polybar mybar &
EOF
  chmod +x ~/.config/polybar/launch.sh

  # config.ini
  CLIP_CMD="copyq show"
  [ "$distro" = "d" ] || [ "$distro" = "D" ] && CLIP_CMD="clipit"

  cat > ~/.config/polybar/config.ini <<EOF
[bar/mybar]
width = 100%
height = 27
padding = 1
background = #222222
foreground = #ffffff
fixed-center = true

font-0 = "Ubuntu:size=10;2"
modules-left = i3
modules-center = clock
modules-right = pulseaudio bluetooth network clipboard tray

tray-position = right
tray-padding = 5
tray-background = #222222
tray-detached = false

[module/clock]
type = internal/date
format = %H:%M
click-left = gsimplecal &

[module/network]
type = internal/network
interface = wlan0
format-connected = " %signal%%"
format-disconnected = "⚠️"

[module/pulseaudio]
type = internal/pulseaudio
format-volume = " %volume%%"

[module/bluetooth]
type = custom/script
exec = echo ""
click-left = blueman-manager

[module/clipboard]
type = custom/script
exec = echo "📋"
click-left = $CLIP_CMD

[module/tray]
type = internal/tray
EOF
}

setup_wallpaper_placeholder() {
  mkdir -p ~/Pictures/Screenshots
  mkdir -p ~/Pictures
  if [ ! -f ~/Pictures/wallpaper.jpg ]; then
    convert -size 1920x1080 xc:#1d1f21 ~/Pictures/wallpaper.jpg
  fi
}

# Execução principal
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

setup_i3_config
setup_polybar
setup_wallpaper_placeholder

echo "[✓] Instalação concluída. Reinicie para iniciar i3 com Polybar, Bluetooth, PipeWire, Tray e mais!"
