use/drm:
	@$(call add_feature)
	@$(call add,DRM_KMODULES,drm)
	@$(call add,THE_KMODULES,$$(DRM_KMODULES))

use/drm/ancient: use/drm
	@$(call add,DRM_KMODULES,drm-ancient)

use/drm/radeon: use/drm
	@$(call add,DRM_KMODULES,drm-radeon)

use/drm/nouveau: use/drm
	@$(call try,NVIDIA_KMODULES,drm-nouveau)
	@$(call add,DRM_KMODULES,$$(NVIDIA_KMODULES))

use/drm/nvidia:: use/drm/nouveau; @:
use/drm/nvidia/optimus:: use/drm/nvidia; @:

ifeq (,$(filter-out i586 x86_64 aarch64,$(ARCH)))
use/drm/nvidia::
	@$(call set,NVIDIA_KMODULES,nvidia)

use/drm/nvidia/optimus::
	@$(call add,NVIDIA_KMODULES,bbswitch)
endif

use/drm/full: use/drm/ancient use/drm/radeon \
	use/drm/nouveau; @:

use/drm/stage2:
	@$(call add,STAGE1_DRM_KMODULES,drm)
	@$(call add,STAGE1_KMODULES,$$(STAGE1_DRM_KMODULES))

use/drm/stage2/ancient: use/drm/stage2
	@$(call add,STAGE1_DRM_KMODULES,drm-ancient)

use/drm/stage2/radeon: use/drm/stage2
	@$(call add,STAGE1_DRM_KMODULES,drm-radeon)

use/drm/stage2/nouveau: use/drm/stage2
	@$(call add,STAGE1_DRM_KMODULES,drm-nouveau)

use/drm/stage2/full: use/drm/stage2/ancient use/drm/stage2/radeon \
	use/drm/stage2/nouveau; @:
