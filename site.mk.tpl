GLUON_SITE_PACKAGES := \
	${batman_pkg} \
	gluon-alfred \
	gluon-autoupdater \
	gluon-config-mode-autoupdater \
	gluon-config-mode-contact-info \
	gluon-config-mode-core \
	gluon-config-mode-geo-location \
	gluon-config-mode-hostname \
	gluon-config-mode-mesh-vpn \
	gluon-ebtables-filter-multicast \
	gluon-ebtables-filter-ra-dhcp \
	gluon-luci-admin \
	gluon-luci-autoupdater \
	gluon-luci-node-role \
	gluon-luci-portconfig \
	gluon-luci-private-wifi \
	gluon-mesh-vpn-fastd \
	gluon-next-node \
	gluon-radvd \
	gluon-respondd \
	gluon-setup-mode \
	gluon-status-page \
	iwinfo \
	iptables \
	haveged

DEFAULT_GLUON_RELEASE := ${gluon_release_num}-$$(shell date '+%Y%m%d')

# Allow overriding the release number from the command line
GLUON_RELEASE ?= $$(DEFAULT_GLUON_RELEASE)

# Default priority for updates.
GLUON_PRIORITY ?= ${gluon_priority}

# i18n langs
GLUON_LANGS ?= en de
