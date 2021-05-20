### various mixins with their origin

### desktop.mk
mixin/desktop-installer: +net-eth +vmguest \
	use/bootloader/os-prober use/x11-autostart use/fonts/install2 use/sound
	@$(call add,BASE_LISTS, \
		$(call tags,(base || desktop) && (l10n || network)))
	@$(call add,INSTALL2_PACKAGES,ntfs-3g)

### e2k.mk
mixin/e2k-base: use/tty/S0 use/net-eth/dhcp; @:

mixin/e2k-desktop: use/e2k/x11 use/l10n/default/ru_RU \
	use/browser/firefox/esr use/browser/firefox/i18n \
	use/fonts/otf/adobe use/fonts/otf/mozilla
	@$(call add,THE_PACKAGES,xinit xterm mc)
	@$(call add,THE_PACKAGES,fonts-bitmap-terminus)

mixin/e2k-livecd-install: use/e2k/x11
	@$(call add,THE_PACKAGES,livecd-install alterator-notes)
	@$(call add,THE_PACKAGES,fdisk hdparm rsync openssh vim-console)
	@$(call add,THE_PACKAGES,apt-repo)

mixin/e2k-mate: use/e2k/x11 use/x11/xorg use/fonts/install2 \
	use/deflogin/live use/deflogin/xgrp \
	use/x11/mate use/x11/lightdm/slick \
	use/fonts/otf/adobe use/fonts/otf/mozilla \
	use/fonts/ttf/google use/fonts/ttf/redhat
	@$(call set,INSTALLER,altlinux-desktop)
	@$(call add,THE_BRANDING,mate-settings)
	@$(call add,THE_BRANDING,alterator)
	@$(call add,THE_BRANDING,graphics)
	@$(call add,THE_PACKAGES,setup-mate-terminal)
	@$(call add,THE_PACKAGES,setup-mate-nocomposite)
	@$(call add,THE_PACKAGES,alterator-standalone)
	@$(call add,THE_PACKAGES,terminfo-extra)
	@$(call add,THE_PACKAGES,ethtool net-tools ifplugd)
	@$(call add,THE_PACKAGES,zsh bash-completion)

### regular.mk
mixin/regular-x11: use/luks use/volumes/regular \
	use/browser/firefox/i18n use/browser/firefox/h264 \
	use/branding use/ntp/chrony use/services/lvm2-disable
	@$(call add,THE_LISTS,$(call tags,(base || desktop) && regular))
	@$(call add,THE_PACKAGES,disable-usb-autosuspend)
	@$(call add,THE_PACKAGES,btrfs-progs)
	@$(call add,THE_PACKAGES,gpm)
	@$(call add,DEFAULT_SERVICES_DISABLE,gpm powertop)

# common WM live/installer bits
mixin/regular-desktop: use/x11/xorg +alsa use/xdg-user-dirs \
	use/fonts/otf/adobe use/fonts/otf/mozilla
	@$(call add,THE_PACKAGES,pam-limits-desktop beesu polkit)
	@$(call add,THE_PACKAGES,alterator-notes dvd+rw-tools)
	@$(call add,THE_BRANDING,alterator graphics indexhtml notes)
	@$(call add,THE_PACKAGES,$$(THE_IMAGEWRITER))
	@$(call set,THE_IMAGEWRITER,imagewriter)
	@$(call add,THE_PACKAGES,upower bluez)
	@$(call add,DEFAULT_SERVICES_DISABLE,gssd idmapd krb5kdc rpcbind)
	@$(call add,DEFAULT_SERVICES_ENABLE,bluetoothd)
	@$(call add,DEFAULT_SERVICES_ENABLE,cups)

mixin/desktop-extra:
	@$(call add,BASE_LISTS,$(call tags,(archive || base) && extra))

mixin/regular-wmaker: use/efi/refind use/syslinux/ui/gfxboot \
	use/fonts/ttf/redhat use/x11/wmaker
	@$(call add,LIVE_PACKAGES,livecd-install-wmaker)
	@$(call add,LIVE_PACKAGES,installer-feature-no-xconsole-stage3)
	@$(call add,MAIN_PACKAGES,wmgtemp wmhdaps wmpomme wmxkbru xxkb)

mixin/regular-icewm: use/fonts/ttf/redhat +icewm +nm-gtk
	@$(call add,THE_LISTS,$(call tags,regular icewm))
	@$(call add,THE_LISTS,$(call tags,desktop nm))
	@$(call add,THE_PACKAGES,icewm-startup-networkmanager)
	@$(call add,THE_PACKAGES,mnt)

# gdm2.20 can reboot/halt with both sysvinit and systemd, and is slim
mixin/regular-gnustep: use/x11/gnustep use/x11/gdm2.20 use/mediacheck
	@$(call add,THE_BRANDING,graphics)

mixin/regular-cinnamon: use/x11/cinnamon +nm-gtk \
	use/fonts/ttf/google use/net/nm/mmgui use/im; @:

mixin/regular-kde5: use/x11/kde5 use/browser/falkon \
	use/fonts/ttf/google use/fonts/ttf/redhat use/fonts/zerg \
	+nm +pulse
	@$(call add,THE_PACKAGES,kde5-telepathy falkon-kde5)
	@$(call set,THE_IMAGEWRITER,rosa-imagewriter)

mixin/xfce-base: use/x11/xfce +nm-gtk \
	use/fonts/ttf/redhat use/fonts/ttf/google/extra
	@$(call add,THE_BRANDING,xfce-settings)

mixin/regular-xfce: mixin/xfce-base use/x11/xfce/full \
	use/domain-client; @:

mixin/regular-xfce-sysv: mixin/xfce-base \
	use/fonts/otf/adobe use/fonts/otf/mozilla
	@$(call add,THE_PACKAGES,pnmixer pm-utils elinks mpg123)
	@$(call add,THE_PACKAGES,alsa-oss ossp whdd wget cdrkit)
	@$(call add,THE_PACKAGES,qasmixer)
	@$(call add,THE_PACKAGES,xfce4-screensaver)
	@$(call add,THE_PACKAGES,sysstat leafpad)
	@$(call add,THE_PACKAGES,nload)
	@$(call add,THE_PACKAGES,NetworkManager-tui)

mixin/regular-lxde: use/x11/lxde use/im +nm-gtk
	@$(call add,THE_LISTS,$(call tags,desktop gvfs))
	@$(call add,THE_PACKAGES,qasmixer qpdfview)
	@$(call set,THE_IMAGEWRITER,rosa-imagewriter)

mixin/regular-lxqt: use/x11/lxqt +nm-gtk
	@$(call set,THE_IMAGEWRITER,rosa-imagewriter)

mixin/mate-base: use/x11/mate use/fonts/ttf/google +nm-gtk
	@$(call add,THE_LISTS,$(call tags,mobile mate))

mixin/regular-mate: mixin/mate-base use/domain-client
	@$(call add,THE_LISTS,$(call tags,base smartcard))

mixin/office: use/fonts/ttf/google use/fonts/ttf/xo
	@$(call add,THE_LISTS,$(call tags,desktop && (cups || office)))
	@$(call add,THE_PACKAGES,apt-indicator)

# NB: never ever use/syslinux/ui/gfxboot here as gfxboot mangles
#     kernel cmdline resulting in method:disk instead of method:cdrom
#     which will change propagator's behaviour to probe additional
#     filesystems (ro but no loop) thus potentially writing to
#     an unrecovered filesystem's journal
mixin/regular-rescue: use/rescue use/isohybrid use/luks use/branding \
	use/syslinux/ui/menu use/syslinux/timeout/600 \
	use/firmware/qlogic test/rescue/no-x11 +sysvinit; @:

mixin/regular-builder: use/dev/builder/base use/net-eth/dhcp
	@$(call add,THE_PACKAGES,bash-completion elinks gpm lftp openssh)
	@$(call add,THE_PACKAGES,rpm-utils screen tmux wget zsh)
	@$(call add,DEFAULT_SERVICES_ENABLE,gpm)

### vm.mk
mixin/cloud-init:
	@$(call add,BASE_PACKAGES,cloud-init)
	@$(call add,DEFAULT_SERVICES_ENABLE,cloud-config cloud-final)
	@$(call add,DEFAULT_SERVICES_ENABLE,cloud-init cloud-init-local)

mixin/opennebula-context:
	@$(call add,BASE_PACKAGES,opennebula-context)
	@$(call add,DEFAULT_SERVICES_ENABLE,one-context-local one-context)

mixin/icewm: use/x11/lightdm/gtk +icewm; @:
