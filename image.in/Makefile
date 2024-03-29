# step 4: dive into mkimage

GLOBAL_BUILDDIR ?= $(shell pwd)
CURRENT_LINK := mkimage-profiles
OUT_LINK := out

# there were mkimage fixes induced by mkimage-profile development
# - minimal version is bumped for critical bugfixes/features
# - optimal one relates to the less universally relevant bits
MKI_VER_MINIMAL = 0.1.7
MKI_VER_OPTIMAL = 0.2.6

include distcfg.mk
include functions.mk

# check the build environment
ifeq (,$(realpath $(MKIMAGE_PREFIX)/config.mk))
$(error please apt-get install mkimage and have a look at QUICKSTART as well)
endif

include $(MKIMAGE_PREFIX)/config.mk

ifeq (-,$(shell rpmvercmp $(MKI_VERSION) $(MKI_VER_MINIMAL) | tr -d [0-9]))
$(info error: mkimage-$(MKI_VERSION) is too old, please upgrade)
$(error mkimage is too old, $(MKI_VER_MINIMAL) is minimal supported version)
endif
ifeq (-,$(shell rpmvercmp $(MKI_VERSION) $(MKI_VER_OPTIMAL) | tr -d [0-9]))
$(info warning: mkimage-$(MKI_VERSION) is suboptimal, consider upgrading)
$(warning consider upgrading mkimage to $(MKI_VER_OPTIMAL) or better)
endif

# glob it just in case
IMAGEDIR := $(wildcard $(IMAGEDIR))

# additional means to reduce havoc in IMAGEDIR
IMAGE_SORTDIR := $(wildcard $(SORTDIR))

# use distro version in image name if defined
ifdef DISTRO_VERSION
IMAGE_VERSION := -$(DISTRO_VERSION)
IMAGE_VER_LINK := $(IMAGE_NAME)$(IMAGE_VERSION)-latest-$(ARCH).$(IMAGE_TYPE)
endif

IMAGE_OUTNAME  := $(IMAGE_NAME)$(IMAGE_VERSION)-$(STATUS)$(DATE)-$(ARCH)
IMAGE_OUTFILE  := $(IMAGE_OUTNAME).$(IMAGE_TYPE)
IMAGE_OUTDIR   := $(IMAGEDIR)$(IMAGE_SORTDIR:%=/%)
IMAGE_OUTPATH  := $(IMAGE_OUTDIR)/$(IMAGE_OUTFILE)
IMAGE_RELPATH  := $(IMAGE_SORTDIR:%=%/)$(IMAGE_OUTFILE)
IMAGE_RELDIR   := $(IMAGE_OUTDIR:$(GLOBAL_BUILDDIR)/%=%)
IMAGE_LINK     := $(IMAGE_NAME)-latest-$(ARCH).$(IMAGE_TYPE)
IMAGE_LINKPATH := $(IMAGEDIR)/$(IMAGE_LINK)

### multi-pack can be useful (think netinst iso/tree)
MKI_PACK_RESULTS = $(IMAGE_PACKTYPE):$(IMAGE_OUTFILE)

# these get copied over as is
COPY_TREE = ./files

# outdir shouldn't be wiped clean before use
CLEANUP_OUTDIR ?=

GLOBAL_TARGET := $(ARCH)
GLOBAL_HSH_LANGS := $(INSTALL_LANGS)
GLOBAL_HSH_APT_CONFIG := $(wildcard $(APTCONF))

# take the latter part for complex-specified subprofiles like stage2@live;
# care to exclude non-directories holding no makefiles like rootfs
SUBDIRS = $(dir $(wildcard $(addsuffix /Makefile,$(SUBPROFILE_DIRS))))

# the lib/build-*.mk comes from features.in/build-*/lib
include $(sort $(wildcard lib/*.mk))
include $(MKIMAGE_PREFIX)/targets.mk

# specified only for the final image (target-specific)
pack-image: OUTDIR = $(IMAGE_OUTDIR)
pack-image: imagedir

copy-tree: $(SAVE_PROFILE:%=save-profile)

save-profile:
	@mkdir -p files/.disk; \
	git archive --prefix=mkimage-profile/ HEAD ":!.work" \
	| gzip -9 > files/.disk/profile.tgz

.PHONY: imagedir postprocess debug

prep: imagedir

imagedir:
	@mkdir -p "$(IMAGE_OUTDIR)"

postprocess: | $(addprefix postprocess-,$(sort $(POSTPROCESS_TARGETS)))
	@OUTSIZE="`ls -lh "$(IMAGE_OUTPATH)" | cut -f5 -d' '`"; \
	if [ ! -n "$$OUTSIZE" ]; then \
		echo "** error: $(IMAGE_OUTPATH) missing" >&2; \
		exit 1; \
	fi; \
	if [ -n "$(VM_SAVE_TARBALL)" ]; then \
		echo "** tarball saved: $(IMAGE_OUTPATH)/$(IMAGE_OUTNAME).$(VM_SAVE_TARBALL)" >&2; \
	fi; \
	echo "** image: $(IMAGE_OUTPATH) [$$OUTSIZE]" >&2 && \
	echo "IMAGE_OUTPATH = $(IMAGE_OUTPATH)" && \
	echo "IMAGE_OUTFILE = $(IMAGE_OUTFILE)" && \
	if [ ! -n "$(NO_SYMLINK)" ]; then \
		ln -sf "$(IMAGE_RELPATH)" "$(IMAGE_LINKPATH)" && \
		ln -sf "$(IMAGE_RELDIR)" "$(OUT_LINK)" && \
		ln -sf "$(IMAGE_LINK)" "$(IMAGEDIR)/$(CURRENT_LINK).$(IMAGE_TYPE)"; \
		if [ -n "$(IMAGE_VER_LINK)" ]; then \
			ln -sf "$(IMAGE_RELPATH)" "$(IMAGEDIR)/$(IMAGE_VER_LINK)"; \
		fi; \
	fi; \
	if [ -n "$(GLOBAL_DEBUG)" ]; then \
		mkdir -p "$(LOGDIR)"; \
		cp -a build.log "$(LOGDIR)/$(IMAGE_OUTFILE).log"; \
		cp -a distcfg.mk "$(LOGDIR)/$(IMAGE_OUTFILE).cfg"; \
	fi

debug::
	@echo "TOPDIR=$(TOPDIR)"
	@echo "IMAGEDIR=$(IMAGEDIR)"
	@echo "ARCH=$(ARCH)"
	@echo "GLOBAL_TARGET=$(GLOBAL_TARGET)"
	@echo "GLOBAL_HSH_LANGS=$(GLOBAL_HSH_LANGS)"
	@echo "GLOBAL_HSH_APT_CONFIG=$(GLOBAL_HSH_APT_CONFIG)"
	@echo "GLOBAL_HSH_USE_QEMU=$(GLOBAL_HSH_USE_QEMU)"
