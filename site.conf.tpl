{
    hostname_prefix = '${hostname_prefix}',
    site_name = '${site_name}',
    site_code = '${site_code}',

    prefix4 = '10.${netnum}.0.0/18',
    prefix6 = 'fd${netnum}:b4dc:4b1e::/64',

    timezone = 'CET-1CEST,M3.5.0,M10.5.0/3', -- Europe/Berlin
    ntp_servers = {
${ntp_v6}${ntp_dns}    },

    regdom = 'DE',
    wifi24 = {
        ssid = '${ssid}',
        channel = 1,
        htmode = 'HT40+',
        mesh_ssid = '${mesh_ssid}',
        mesh_bssid = '${mesh_bssid}',
        mesh_mcast_rate = 12000,
    },
    wifi5 = {
        ssid = '${ssid}',
        channel = 44,
        htmode = 'HT40+',
        mesh_ssid = '${mesh_ssid}',
        mesh_bssid = '${mesh_bssid}',
        mesh_mcast_rate = 12000,
    },

    next_node = {
        ip4 = '10.${netnum}.0.1',
        ip6 = 'fd${netnum}:b4dc:4b1e::1',
        mac = '02:00:0a:${netnum_hex}:00:01',
    },

    fastd_mesh_vpn = {
        methods = {'salsa2012+gmac'},
        mtu = 1406,
        enabled = true,
        backbone = {
            limit = 2,
            peers = {
${gw_remotes}            },
        },
    },

    autoupdater = {
        branch = 'stable',
        branches = {
            stable = {
                name = 'stable',
                mirrors = {
${gw_mirrors_stable}                },
                good_signatures = 3,
                pubkeys = {
${signkeys}                },
            },
            beta = {
                name = 'beta',
                mirrors = {
${gw_mirrors_beta}                },
                good_signatures = 2,
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

    config_mode = {
        msg_welcome = [[
Willkommen zum Einrichtungsassistenten für deinen neuen Freifunk-Knoten.
Fülle das folgende Formular deinen Vorstellung entsprechend aus und sende es ab.
]],
        msg_pubkey = [[
Dies ist der öffentliche Schlüssel deines Freifunk-Knotens. Erst nachdem er auf
den Servern des Mainzer bzw. Wiesbadener Freifunk-Projektes eingetragen wurde
kann sich dein Knoten mit den Mesh-VPNs in Mainz und Wiesbaden verbinden.
Bitte schicke dazu diesen Schlüssel und den Namen deines Knotens (<em><%=hostname%></em>)
an <a href="mailto:${mail_keys}?&amp;subject=Neuer%20Freifunk-Knoten%3A%20<%=hostname%>&amp;body=Name%3A%20<%=hostname%>%0D%0AKey%3A%20<%=pubkey%>%0D%0AMAC%3A%20<%=sysconfig.primary_mac%>%0D%0A">${mail_keys}</a>.
<small>Ein Klick auf den E-Mail Link müsste&trade; dein E-Mail Programm
öffnen und alle benötigten Informationen in eine neue Mail einfügen.</small>
]],
        msg_reboot = [[
Dein Knoten startet gerade neu und wird anschließend versuchen, sich mit anderen
Freifunk-Knoten in seiner Nähe zu verbinden.<br />

Weitere Informationen zur Freifunk-Community findest du auf den Webseiten von
<a href="http://mainz.freifunk.net/">Freifunk Mainz</a>, <a href="http://wiesbaden.freifunk.net/">Freifunk Wiesbaden</a>, oder unter <a href="http://www.freifunk.net/">freifunk.net</a>.<br />

Viel Spaß mit deinem Knoten und bei der Erkundung von Freifunk!<br />

]],
    },
}
