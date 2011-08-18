use/installer: use/stage1kernel sub/install2 use/syslinux/install2.cfg
	@$(call add,FEATURES,installer)
	@$(call set,INSTALL2_PACKAGES,installer-distro-$$(INSTALLER)-stage2)
	@$(call add,INSTALL2_PACKAGES,branding-$$(BRANDING)-alterator)
	@$(call add,MAIN_PACKAGES,branding-$$(BRANDING)-release)
	@$(call add,BASE_LISTS,$(call tags,basesystem))
