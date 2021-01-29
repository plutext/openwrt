#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=sx05
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/sx05
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Router Specific
  DEPENDS:=+ath10k-firmware-qca9887 +ath9k-htc-firmware +kmod-ath10k \
	+kmod-ath9k-htc
  TITLE:=Install scripts for RD05A1
  PKGARCH:=all
endef

define Package/sx05/description
  Helper scripts to install scripts for RD05A1
endef


define Build/Compile
endef

define Package/sx05/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,sx05))
