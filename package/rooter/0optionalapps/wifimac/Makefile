#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=wifimac
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/wifimac
  SECTION:=utils
  CATEGORY:=ROOter
  SUBMENU:=Optional Applications
  TITLE:=Install scripts for adding MAC to SSID
  PKGARCH:=all
endef

define Package/wifimac/description
  Helper scripts to install scripts for adding MAC to SSID
endef


define Build/Compile
endef

define Package/wifimac/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,wifimac))
