GLUON_SITE_PACKAGES := \
	${batman_pkg} \
	gluon-alfred \
	gluon-announced \
	gluon-autoupdater \
	gluon-config-mode-hostname \
	gluon-config-mode-autoupdater \
	gluon-config-mode-mesh-vpn \
	gluon-config-mode-geo-location \
	gluon-config-mode-contact-info \
	gluon-ebtables-filter-multicast \
	gluon-ebtables-filter-ra-dhcp \
	gluon-luci-admin \
	gluon-luci-autoupdater \
	gluon-luci-portconfig \
	gluon-luci-private-wifi \
	gluon-mesh-vpn-fastd \
	gluon-next-node \
	gluon-radvd \
	gluon-status-page \
	iwinfo \
	iptables \
	haveged

DEFAULT_GLUON_RELEASE := ${gluon_release_num}-$$(shell date '+%Y%m%d')

# Allow overriding the release number from the command line
GLUON_RELEASE ?= $$(DEFAULT_GLUON_RELEASE)

# Default priority for updates.
GLUON_PRIORITY ?= ${gluon_priority}
