#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rooterbcm16
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-rooterbcm16
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +luci-app-sqm +luci-app-rootervpn +luci-app-mwan3 +luci-app-dnsmasq-ipset \
		+luci-app-ddns +ddns-scripts +ddns-scripts_no-ip_com \
		+luci-theme-argon +argon-config \
		+ca-bundle +ca-certificates +libustream-openssl \
		+ext-rooter-basic +ext-p910nd +ext-samba +ext-update \
		+ext-umount +ext-command +kmod-sched-cake +speedtest \
		+openvpn-easy-rsa +openvpn-openssl +wget +ext-extra +wpad \
		+nano +picocom +bwmon +luci-app-wol
  TITLE:=ROOter support for 16meg and larger Broadcom routers w/o Hotspot Manager
  PKGARCH:=all
endef

define Package/ext-rooterbcm16/description
  Helper scripts to enable ROOter on 16meg and larger Broadcom routers w/o Hotspot Manager
endef


define Build/Compile
endef

define Package/ext-rooterbcm16/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,ext-rooterbcm16))
