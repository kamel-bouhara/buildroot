################################################################################
#
## usbguard
#
################################################################################

USBGUARD_VERSION = 1.0.0
USBGUARD_SITE = https://github.com/USBGuard/usbguard/releases/download/usbguard-$(USBGUARD_VERSION)
USBGUARD_LICENSE = GPL-2.0+
USBGUARD_LICENSE_FILES = LICENSE
USBGUARD_CONF_OPTS= --with-bundled-catch --with-bundled-pegtl \
		    --disable-debug-build --without-dbus --without-polkit \
		    --disable-seccomp --disable-umockdev --enable-systemd

USBGUARD_DEPENDENCIES += systemd libqb protobuf

ifeq ($(BR2_PACKAGE_LIBOPENSSL),y)
USBGUARD_CONF_OPTS += --with-crypto-library=openssl
USBGUARD_DEPENDENCIES += libopenssl
endif
ifeq ($(BR2_PACKAGE_LIBOPENSSL),y)
USBGUARD_CONF_OPTS += --with-crypto-library=gcrypt
USBGUARD_DEPENDENCIES += libgcrypt
endif
ifeq ($(BR2_PACKAGE_LIBSODIUM),y)
USBGUARD_CONF_OPTS += --with-crypto-library=sodium
USBGUARD_DEPENDENCIES += libsodium
endif

ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
USBGUARD_CONF_OPTS += --enable-seccomp
USBGUARD_DEPENDENCIES += libseccomp
endif

ifeq ($(BR2_PACKAGE_LIBCAP_NG),y)
USBGUARD_CONF_OPTS += --enable-libcapng
USBGUARD_DEPENDENCIES += libcap-ng
endif

$(eval $(autotools-package))
