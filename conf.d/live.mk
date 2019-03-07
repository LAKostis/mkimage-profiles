# live images
ifeq (distro,$(IMAGE_CLASS))

distro/dos: distro/.boot use/dos use/syslinux/ui/menu
	@$(call set,RELNAME,ALT FreeDOS)

distro/rescue: distro/.base use/rescue use/syslinux/ui/menu use/stage2/cifs \
	use/efi/signed use/efi/refind use/efi/shell; @:

distro/rescue-remote: distro/.base use/rescue/base use/stage2/net-eth
	@$(call set,SYSLINUX_CFG,rescue_remote)
	@$(call set,SYSLINUX_DIRECT,1)
	@$(call add,RESCUE_PACKAGES,livecd-net-eth)

distro/syslinux: distro/.boot \
	use/syslinux/localboot.cfg use/syslinux/ui/vesamenu use/hdt; @:

distro/.live-base: distro/.base use/live/base use/power/acpi/button; @:
distro/.live-x11: distro/.live-base use/live/x11; @:

distro/.live-desktop: distro/.base +live use/live/install use/stage2/net-eth \
	use/plymouth/live; @:
distro/.live-desktop-ru: distro/.live-desktop use/live/ru; @:

distro/.live-kiosk: distro/.base use/live/base use/live/autologin \
	use/syslinux/timeout/1 use/cleanup use/stage2/net-eth \
	use/fonts/otf/adobe +power
	@$(call add,CLEANUP_PACKAGES,'alterator*' 'guile*' 'vim-common')
	@$(call set,SYSLINUX_UI,none)
	@$(call set,SYSLINUX_CFG,live)
	@$(call add,STAGE2_BOOTARGS,quiet)
	@$(call add,DEFAULT_SERVICES_DISABLE,rpcbind klogd syslogd)
	@$(call add,DEFAULT_SERVICES_DISABLE,consolesaver fbsetfont keytable)

distro/live-builder-mini: distro/.live-base use/dev/builder/base \
	use/syslinux/timeout/30 use/isohybrid \
	use/stage2/net-eth use/net-eth/dhcp; @:

distro/live-builder: distro/live-builder-mini \
	use/dev/builder/full use/live/rw +efi; @:

distro/live-install: distro/.live-base use/live/textinstall; @:
distro/.livecd-install: distro/.live-base use/live/install; @:

distro/live-icewm: distro/.live-desktop use/x11/lightdm/gtk +icewm; @:
distro/live-razorqt: distro/.live-desktop +razorqt; @:
distro/live-tde: distro/.live-desktop-ru use/live/install +tde; @:
distro/live-fvwm: distro/.live-desktop-ru use/x11/lightdm/gtk use/x11/fvwm; @:

distro/live-lakostis: distro/.live-desktop use/docs/license \
	use/x11/vulkan use/x11/nvidia use/x11/lightdm/gtk use/x11/lxde +efi \
	+wireless +systemd use/fonts/ttf/google use/browser/chromium use/net/nm/nodelay use/net-ssh \
	use/firmware/laptop use/x11-neatterm use/x11/gtk/nm +power +vmguest
	@$(call set,KFLAVOURS,lks-wks)
	@$(call add,THE_PACKAGES,pam-limits-desktop)
	@$(call add,THE_PACKAGES,disable-usb-autosuspend)
	@$(call add,THE_PACKAGES,vconsole-setup-kludge) #28805
	@$(call add,THE_PACKAGES,installer-feature-desktop-other-fs-stage2)
	@$(call add,LIVE_LISTS,$(call tags,(base || desktop) && regular))
	@$(call add,LIVE_LISTS,$(call tags,base rescue))
	@$(call add,LIVE_LISTS,$(call tags,desktop lakostis))
	@$(call add,DEFAULT_SERVICES_DISABLE,gpm powertop lvm2-lvmpolld)
	@$(call add,DEFAULT_SERVICES_ENABLE,bluetoothd)

distro/live-lakostis-elogind: distro/.live-x11 use/docs/license \
	use/x11/vulkan use/x11/lightdm/gtk use/x11/lxde +efi \
	+wireless +sysvinit use/init/sysv/polkit use/fonts/ttf/google \
	use/browser/chromium use/net-ssh \
	use/firmware/laptop use/x11-neatterm use/x11/gtk/nm +power
	@$(call set,KFLAVOURS,lks-wks)
	@$(call add,THE_PACKAGES,pam-limits-desktop)
	@$(call add,LIVE_LISTS,$(call tags,live desktop))
	@$(call add,LIVE_LISTS,$(call tags,desktop lakostis))
	@$(call add,DEFAULT_SERVICES_DISABLE,gpm powertop lvm2-lvmpolld)
	@$(call add,DEFAULT_SERVICES_ENABLE,bluetoothd)


distro/live-lakostis-oldmac: distro/.live-x11 use/x11/lightdm/gtk use/x11/lxde +efi \
	+wireless +systemd use/fonts/ttf/google use/net/nm/nodelay use/net-ssh \
	use/firmware/laptop use/x11-neatterm use/x11/gtk/nm +power use/hw-quirks/apple
	@$(call set,KFLAVOURS,lks-wks)
	@$(call add,STAGE2_BOOTARGS,nomodeset video=vesa:off vga=normal)
	@$(call set,NVIDIA_KMODULES,nvidia_legacy_340.xx)
	@$(call set,NVIDIA_PACKAGES,nvidia_glx_legacy_340.xx nvidia-settings nvidia-xconfig)
	@$(call add,LIVE_PACKAGES,nvdock udev-extras kodi pavucontrol bluez \
	pulseaudio-bluez pommed gpomme xorg-conf-synaptics usbutils)

distro/live-rescue: distro/live-icewm +efi
	@$(call add,LIVE_LISTS,$(call tags,rescue && (fs || live || x11)))
	@$(call add,LIVE_LISTS,openssh \
		$(call tags,(base || extra) && (archive || rescue || network)))

# NB: this one doesn't include the browser, needs to be chosen downstream
distro/.live-webkiosk: distro/.live-kiosk \
	use/isohybrid use/live/hooks use/live/ru use/sound \
	use/stage2/kms use/x11/xorg
	@$(call add,LIVE_LISTS,$(call tags,live desktop))

distro/.live-webkiosk-gtk: distro/.live-webkiosk
	@$(call add,CLEANUP_PACKAGES,'libqt4*' 'qt4*')

# kiosk users rather prefer stability to latest bling
distro/live-webkiosk-mini: distro/.live-webkiosk-gtk \
	use/browser/firefox use/browser/firefox/esr use/fonts/otf/mozilla
	@$(call add,LIVE_PACKAGES,livecd-webkiosk-firefox)

# NB: flash/java plugins are predictable security holes
distro/live-webkiosk-flash: distro/live-webkiosk-mini use/plymouth/live \
	use/browser/plugin/flash use/browser/plugin/java +vmguest; @:

distro/live-webkiosk: distro/live-webkiosk-mini use/live/desktop; @:

distro/live-webkiosk-chromium: distro/.live-webkiosk use/fonts/ttf/google +efi
	@$(call add,LIVE_PACKAGES,livecd-webkiosk-chromium)

distro/live-webkiosk-seamonkey: distro/.live-webkiosk use/fonts/ttf/google
	@$(call add,LIVE_PACKAGES,livecd-webkiosk-seamonkey)

distro/live-webkiosk-qupzilla: distro/.live-webkiosk use/fonts/otf/mozilla
	@$(call add,LIVE_PACKAGES,livecd-webkiosk-qupzilla)

distro/.live-3d: distro/.live-x11 use/x11/3d \
	use/x11/lightdm/gtk +icewm +sysvinit
	@$(call add,LIVE_PACKAGES,glxgears glxinfo)

distro/live-glxgears: distro/.live-3d; @:

distro/.live-games: distro/.live-kiosk use/x11/3d use/sound \
	use/stage2/net-eth use/net-eth/dhcp use/services +efi +sysvinit
	@$(call set,KFLAVOURS,un-def)
	@$(call add,LIVE_LISTS,$(call tags,xorg misc))
	@$(call add,LIVE_PACKAGES,pciutils input-utils glxgears glxinfo)
	@$(call add,DEFAULT_SERVICES_DISABLE,rpcbind alteratord messagebus)
	@$(call add,SERVICES_DISABLE,livecd-net-eth)

distro/live-flightgear: distro/.live-games
	@$(call add,LIVE_PACKAGES,FlightGear)
	@$(call add,LIVE_PACKAGES,fgo livecd-fgfs)
	@$(call try,HOMEPAGE,http://www.4p8.com/eric.brasseur/flight_simulator_tutorial.html)

distro/live-flightgear-tu154: distro/.live-games
	@$(call add,LIVE_PACKAGES,FlightGear-tu154b)

distro/live-0ad: distro/.live-games
	@$(call add,STAGE2_BOOTARGS,quiet)
	@$(call add,LIVE_PACKAGES,0ad livecd-0ad)
	@$(call try,HOMEPAGE,http://play0ad.com/)

distro/live-gimp: distro/live-icewm use/live/ru
	@$(call add,LIVE_LISTS,$(call tags,desktop sane))
	@$(call add,LIVE_PACKAGES,gimp tintii immix fim)
	@$(call add,LIVE_PACKAGES,darktable geeqie rawstudio ufraw)
	@$(call add,LIVE_PACKAGES,macrofusion python-module-pygtk-libglade)
	@$(call add,LIVE_PACKAGES,qtfm openssh-clients rsync usbutils)
	@$(call add,LIVE_PACKAGES,design-graphics-sisyphus2)

# NB: use/browser won't do as it provides a *single* browser ATM
distro/live-privacy: distro/.base +power +efi +systemd +vmguest \
	use/live/base use/live/privacy use/live/ru \
	use/x11/xorg use/x11/lightdm/gtk use/x11/mate use/x11-autologin \
	use/browser/firefox/esr use/browser/firefox/i18n use/sound \
	use/fonts/otf/adobe use/fonts/otf/mozilla \
	use/fonts/ttf/google use/fonts/ttf/redhat
	@$(call set,KFLAVOURS,un-def)
	@$(call add,LIVE_LISTS,$(call tags,base l10n))
	@$(call add,LIVE_LISTS,$(call tags,archive extra))
	@$(call add,LIVE_PACKAGES,chromium gedit mc-full pinta xchm livecd-ru)
	@$(call add,LIVE_PACKAGES,LibreOffice-langpack-ru java-1.8.0-openjdk)
	@$(call add,LIVE_PACKAGES,mate-document-viewer-caja)
	@$(call add,LIVE_PACKAGES,mate-document-viewer-djvu)
	@$(call add,LIVE_PACKAGES,cups system-config-printer livecd-admin-cups)
	@$(call add,LIVE_KMODULES,staging)
	@$(call add,DEFAULT_SERVICES_ENABLE,cups)
	@$(call add,EFI_BOOTARGS,live_rw)

distro/live-privacy-dev: distro/live-privacy use/live/rw use/live/repo \
	use/dev/repo use/dev/mkimage use/dev use/control/sudo-su
	@$(call add,LIVE_LISTS,$(call tags,(base || live) && builder))
	@$(call add,MAIN_LISTS,$(call tags,live builder))
	@$(call add,MAIN_PACKAGES,syslinux mkisofs)

endif
