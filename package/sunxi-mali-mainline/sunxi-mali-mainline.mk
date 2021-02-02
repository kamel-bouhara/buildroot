################################################################################
#
# sunxi-mali-mainline
#
################################################################################

SUNXI_MALI_MAINLINE_VERSION = 418f55585e76f375792dbebb3e97532f0c1c556d
SUNXI_MALI_MAINLINE_SITE = $(call github,bootlin,mali-blobs,$(SUNXI_MALI_MAINLINE_VERSION))
SUNXI_MALI_MAINLINE_INSTALL_STAGING = YES
SUNXI_MALI_MAINLINE_PROVIDES = libegl libgles
SUNXI_MALI_MAINLINE_LICENSE = Allwinner End User Licence Agreement
SUNXI_MALI_MAINLINE_EULA_ORIGINAL = EULA\ for\ Mali\ 400MP\ _AW.pdf
SUNXI_MALI_MAINLINE_EULA_NO_SPACES = EULA_for_Mali_400MP_AW.pdf
SUNXI_MALI_MAINLINE_LICENSE_FILES = $(SUNXI_MALI_MAINLINE_EULA_NO_SPACES)

SUNXI_MALI_MAINLINE_REV = $(call qstrip,$(BR2_PACKAGE_SUNXI_MALI_MAINLINE_REVISION))

ifeq ($(BR2_arm),y)
SUNXI_MALI_MAINLINE_ARCH=arm
else ifeq ($(BR2_aarch64),y)
SUNXI_MALI_MAINLINE_ARCH=arm64
endif

SUNXI_MALI_MAINLINE_OUTPUT = $(call qstrip,$(BR2_PACKAGE_SUNXI_MALI_MAINLINE_OUTPUT))
SUNXI_MALI_MAINLINE_LIB_SUBDIR = \
	$(SUNXI_MALI_MAINLINE_REV)/$(SUNXI_MALI_MAINLINE_ARCH)/$(SUNXI_MALI_MAINLINE_OUTPUT)

ifeq ($(BR2_PACKAGE_SUNXI_MALI_MAINLINE_OUTPUT_X11_DMABUF)$(BR2_PACKAGE_SUNXI_MALI_MAINLINE_OUTPUT_X11_UMP),y)
SUNXI_MALI_MAINLINE_INCLUDE_SUBDIR = include/x11
else
SUNXI_MALI_MAINLINE_INCLUDE_SUBDIR = \
	include/$(SUNXI_MALI_MAINLINE_OUTPUT)
define SUNXI_MALI_MAINLINE_FIXUP_EGL_PC
	$(SED) "s/Cflags: /Cflags: -DMESA_EGL_NO_X11_HEADERS /" \
		$(STAGING_DIR)/usr/lib/pkgconfig/egl.pc
endef
endif

ifeq ($(BR2_PACKAGE_SUNXI_MALI_MAINLINE_OUTPUT_WAYLAND),y)
SUNXI_MALI_MAINLINE_DEPENDENCIES += wayland
SUNXI_MALI_MAINLINE_PROVIDES += libgbm
endif

# FIXME: install gbm.pc conditionally
define SUNXI_MALI_MAINLINE_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/lib $(STAGING_DIR)/usr/include

	cp -rf $(@D)/$(SUNXI_MALI_MAINLINE_LIB_SUBDIR)/*.so* \
		$(STAGING_DIR)/usr/lib/
	cp -rf $(@D)/$(SUNXI_MALI_MAINLINE_INCLUDE_SUBDIR)/* \
		$(STAGING_DIR)/usr/include/

	$(INSTALL) -D -m 0644 package/sunxi-mali-mainline/egl.pc \
		$(STAGING_DIR)/usr/lib/pkgconfig/egl.pc
	$(INSTALL) -D -m 0644 package/sunxi-mali-mainline/glesv2.pc \
		$(STAGING_DIR)/usr/lib/pkgconfig/glesv2.pc
	$(INSTALL) -D -m 0644 package/sunxi-mali-mainline/gbm.pc \
		$(STAGING_DIR)/usr/lib/pkgconfig/gbm.pc
	$(SUNXI_MALI_MAINLINE_FIXUP_EGL_PC)
endef

define SUNXI_MALI_MAINLINE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/lib
	cp -rf $(@D)/$(SUNXI_MALI_MAINLINE_LIB_SUBDIR)/*.so* \
		$(TARGET_DIR)/usr/lib/
endef

define SUNXI_MALI_MAINLINE_FIXUP_LICENSE_FILE
	mv $(@D)/$(SUNXI_MALI_MAINLINE_EULA_ORIGINAL) $(@D)/$(SUNXI_MALI_MAINLINE_EULA_NO_SPACES)
endef

SUNXI_MALI_MAINLINE_POST_PATCH_HOOKS += SUNXI_MALI_MAINLINE_FIXUP_LICENSE_FILE

$(eval $(generic-package))
