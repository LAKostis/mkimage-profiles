ifeq (ve,$(IMAGE_CLASS))

# no "vzctl enter"
ve/bare: ve/.base +sysvinit; @:

# /dev/pty and friends start here
ve/base: ve/bare use/net-dns/level3
	@$(call add,BASE_PACKAGES,interactivesystem)

# a particular package list
ve/ldv: ve/bare use/control/server/ldv
	@$(call add,BASE_PACKAGES,xz bzip2 glibc hostinfo less)
	@$(call add,BASE_PACKAGES,vim-console netlist rsync time)
	@$(call add,BASE_PACKAGES,openssh-blacklist openssh-server)
	@$(call add,BASE_PACKAGES,shadow-edit shadow-groups)

ve/docker: ve/.base use/repo; @:

# build environment
ve/builder: ve/base use/repo
	@$(call add,BASE_PACKAGES,vim-console git-core bash-completion zsh)
	@$(call add,BASE_PACKAGES,su hasher mkimage-profiles rpm-build)
	@$(call add,BASE_PACKAGES,rsync screen parallel pv)
	@$(call add,BASE_PACKAGES,fdisk e2fsprogs iproute2 net-tools)
	@$(call add,BASE_LISTS,openssh)

# this should be more or less convenient
ve/generic: ve/base use/repo
	@$(call add,BASE_PACKAGES,vim-console etckeeper)
	@$(call add,BASE_LISTS,openssh \
		$(call tags,base && (server || network || security || pkg)))

# example of service-specific template
ve/openvpn: ve/bare
	@$(call add,BASE_LISTS,$(call tags,server openvpn))

ve/pgsql94: ve/generic
	@$(call add,BASE_PACKAGES,postgresql9.4-server)

ve/samba-DC: ve/generic
	@$(call add,BASE_PACKAGES,task-samba-dc glibc-locales net-tools)

ve/systemd-bare: ve/.base use/control/sudo-su use/repo use/net/networkd +systemd
	@$(call add,BASE_PACKAGES,interactivesystem su)
	@$(call add,BASE_LISTS,openssh)

endif
