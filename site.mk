GLUON_SITE_PACKAGES := \
	gluon-alfred \
	gluon-autoupdater \
	gluon-config-mode \
	gluon-ebtables-filter-multicast \
	gluon-ebtables-filter-ra-dhcp \
	gluon-luci-admin \
	gluon-luci-autoupdater \
	gluon-luci-portconfig \
	gluon-next-node \
	gluon-mesh-batman-adv \
	gluon-mesh-vpn-fastd \
	gluon-radvd \
	gluon-status-page \
	iwinfo \
	iptables \
	haveged \
	ffctl-configurator \
	ffctl-nodewatcher


DEFAULT_GLUON_RELEASE := 0.1+0-$(shell date '+%Y.%m.%d-%H.%M')-g$(shell git -C $(GLUONDIR) log --pretty=format:'%h' -n 1)-s$(shell git -C $(GLUONDIR)/site log --pretty=format:'%h' -n 1)

# Allow overriding the release number from the command line
GLUON_RELEASE ?= $(DEFAULT_GLUON_RELEASE)

# Default priority for updates.
GLUON_PRIORITY ?= 0.1
