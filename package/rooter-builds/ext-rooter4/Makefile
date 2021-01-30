#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rooter4
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-rooter4
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+ext-rooter-basic +ext-extra +ext-update \
		+ca-bundle +ca-certificates +libustream-openssl \
		+luci-app-sqm +ext-command +kmod-sched-cake \
		+luci-app-ddns +ddns-scripts +ddns-scripts_no-ip_com \
		+picocom +luci-app-hotspot +wpad-mini +wget
  TITLE:=Basic ROOter support for 8meg routers
  PKGARCH:=all
endef

define Package/ext-rooter4/description
  Helper scripts to install Basic ROOter on 8meg routers
endef

define Build/Compile
endef

define Package/ext-rooter4/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ext-rooter4))
