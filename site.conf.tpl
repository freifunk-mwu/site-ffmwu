{
    hostname_prefix = '${hostname_prefix}',
    site_name = '${site_name}',
    site_code = '${site_code}',
    opkg_repo = '${opkg_repo}',

    prefix4 = '10.${netnum}.0.0/18',
    prefix6 = 'fd${netnum}:b4dc:4b1e::/64',

    timezone = 'CET-1CEST,M3.5.0,M10.5.0/3', -- Europe/Berlin
    ntp_servers = {
${ntp_dns}    },

    regdom = 'DE',
    wifi24 = {
        channel = 6,
        htmode = 'HT40+',
        ap = {
                ssid = '${ssid}',
        },
        ibss = {
                ssid = '${ibss_ssid}',
                bssid = '${ibss_bssid}',
                mcast_rate = '${mcast_rate}',
        },
--        mesh = {
--                id = '${mesh_id}',
--                mcast_rate = '${mcast_rate}',
--        },
    },
    wifi5 = {
        channel = 44,
        htmode = 'HT40+',
        ap = {
                ssid = '${ssid}',
        },
        ibss = {
                ssid = '${ibss_ssid}',
                bssid = '${ibss_bssid}',
                mcast_rate = '${mcast_rate}',
        },
--        mesh = {
--                id = '${mesh_id}',
--                mcast_rate = '${mcast_rate}',
--        },
    },

    next_node = {
        ip4 = '10.${netnum}.0.1',
        ip6 = 'fd${netnum}:b4dc:4b1e::1',
        mac = '02:00:0a:${netnum_hex}:00:01',
    },

    fastd_mesh_vpn = {
        methods = {'salsa2012+umac'},
        mtu = 1406,
        enabled = true,
        groups = {
            backbone = {
                limit = 2,
                peers = {
${gw_remotes}                },
            },
        },
    },

    autoupdater = {
        branch = 'stable',
        branches = {
            stable = {
                name = 'stable',
                mirrors = {
${gw_mirrors_stable}                },
                good_signatures = 4,
                pubkeys = {
${signkeys}                },
            },
            beta = {
                name = 'beta',
                mirrors = {
${gw_mirrors_beta}                },
                good_signatures = 3,
                pubkeys = {
${signkeys}                },
            },
            experimental = {
                name = 'experimental',
                mirrors = {
${gw_mirrors_experimental}                },
                good_signatures = 1,
                pubkeys = {
${signkeys}                },
            },
        },
    },

    roles = {
        default = 'node',
        list = {
            'node',
            'backbone',
        },
    },

    simple_tc = {
        mesh_vpn = {
            ifname = 'mesh-vpn',
            enabled = false,
            limit_egress = 400,
            limit_ingress = 6000,
        },
    },

    -- enable BATMAN on WAN interface by default (see gluon-luci-portconfig for webinterface)
    mesh_on_wan = false,
}
