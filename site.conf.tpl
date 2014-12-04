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
        ssid = '${ssid}',
        channel = 6,
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
        methods = {'salsa2012+umac'},
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
Willkommen zum Einrichtungsassistenten für deinen neuen Freifunk-Knoten.<br />
Fülle das folgende Formular deinen Vorstellung entsprechend aus und sende es ab.
]],
        msg_pubkey = [[
Dies ist der öffentliche Schlüssel deines Freifunk-Knotens. Erst nachdem er auf den Servern des ${city}er Freifunk-Projektes eingetragen wurde kann sich dein Knoten mit den Mesh-VPNs in ${city} verbinden.<br />
Bitte schicke dazu diesen Schlüssel und den Namen deines Knotens (<em><%=hostname%></em>)
an <a href="mailto:${descr_mailkeys}?&amp;subject=Neuer%20Freifunk-Knoten%3A%20<%=hostname%>&amp;body=Name%3A%20<%=hostname%>%0D%0AKey%3A%20<%=pubkey%>%0D%0AMAC%3A%20<%=sysconfig.primary_mac%>%0D%0A">${descr_mailkeys}</a>.<br />
<small>Ein Klick auf den E-Mail Link sollte&trade; dein E-Mail Programm öffnen und alle benötigten Informationen in eine neue Mail einfügen.</small><br />
Sei so nett, und schreib noch ein zwei Zeilen dazu - kommentarlos einen Key vor die Nase geknallt zu bekommen ist ein bisschen schade, und motiviert uns nicht unbedingt den Key auch sofort einzutragen. Schreib uns wie das Wetter gerade ist, was deine Katze so treibt, oder warum du Freifunker bist. Egal was, Hauptsache irgendwas, was uns motiviert deinen Key auch schnell einzutragen :)<br />
]],
        msg_reboot = [[
Dein Knoten startet gerade neu und wird anschließend versuchen, sich mit anderen Freifunk-Knoten in seiner Nähe zu verbinden.<br />
Weitere Informationen zur Freifunk-Community findest du auf der Webseite von <a href="http://www.${descr_url}/">${site_name}</a>, oder unter <a href="http://www.freifunk.net/">freifunk.net</a>.<br />
Viel Spaß mit deinem Knoten und bei der Erkundung von Freifunk!
]],
    },
}
