GLUON_SITE_PACKAGES := \
#	ffpb-debug \
	gluon-alfred \
	gluon-autoupdater \
	gluon-batman-on-wan \
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
	haveged

DEFAULT_GLUON_RELEASE := 0.1+1-$(shell date '+%Y.%m.%d-%H.%M')-$(shell git -C $(GLUONDIR) log --pretty=format:'%h' -n 1)-$(shell git -C $(GLUONDIR)/site log --pretty=format:'%h' -n 1)

# Allow overriding the release number from the command line
GLUON_RELEASE ?= $(DEFAULT_GLUON_RELEASE)
