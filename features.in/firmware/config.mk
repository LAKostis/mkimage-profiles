# NB: if the firmware is needed in installer,
#     it should be installed to stage1's *instrumental* chroot
#     for mkmodpack to use

use/firmware:
	@$(call add_feature)
	@$(call add,SYSTEM_PACKAGES,firmware-linux)
ifeq (,$(filter-out aarch64 armh,$(ARCH)))
	@$(call add,THE_PACKAGES,firmware-bcm4345)
endif

use/firmware/full: use/firmware/server use/firmware/laptop; @:

ifeq (,$(filter-out i586 x86_64,$(ARCH)))
use/firmware/cpu: use/firmware
	@$(call add,THE_PACKAGES,firmware-intel-ucode iucode_tool)
else
use/firmware/cpu: use/firmware; @:
endif

use/firmware/server: use/firmware
	@$(call add,SYSTEM_PACKAGES,firmware-aic94xx-seq)
	@$(call add,THE_PACKAGES_REGEXP,firmware-ql.*)

use/firmware/qlogic: use/firmware
	@$(call add,SYSTEM_PACKAGES,firmware-ql6312)

# stub
use/firmware/wireless: use/firmware; @:

use/firmware/laptop: use/firmware/cpu
	@$(call add,THE_KMODULES,acpi_call)
ifeq (,$(filter-out x86_64,$(ARCH)))
	@$(call add,THE_PACKAGES,firmware-alsa-sof)
endif
