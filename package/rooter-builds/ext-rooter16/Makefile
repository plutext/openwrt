#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rooter16
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-rooter16
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +luci-app-sqm +luci-app-mwan3 +luci-app-dnsmasq-ipset \
		+luci-app-ddns +ddns-scripts +ddns-scripts_no-ip_com \
		+luci-app-rootervpn +ext-yamon3 \
		+luci-theme-argon +argon-config \
		+ca-bundle +ca-certificates +libustream-openssl \
		+ext-rooter-basic +ext-p910nd +ext-samba +ext-update \
		+ext-umount +ext-command +kmod-sched-cake +speedtest \
		+openvpn-easy-rsa +openvpn-openssl +wget +ext-extra +wpad \
		+usbmuxd +libusbmuxd-utils +libimobiledevice-utils +kmod-usb-net-ipheth \
		+nano +picocom +bwmon +luci-app-hotspot +luci-app-wol
  TITLE:=ROOter support for 16meg and larger routers
  PKGARCH:=all
endef

define Package/ext-rooter16/description
  Helper scripts to enable ROOter on 16meg and larger routers
endef


define Build/Compile
endef

define Package/ext-rooter16/install
	$(CP) ./files/* $(1)/


endef

$(eval $(call BuildPackage,ext-rooter16))
