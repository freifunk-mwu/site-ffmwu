#!/usr/bin/env python3
# -.- coding: utf-8 -.-

## mkwi.py
# generates a site.conf for Freifunk Wiesbaden
#
# start it with any argument to replace the entire siteconf
# (use git checkout -- site.conf to restore the original site.conf)

from os import path
from sys import argv
BASEDIR = path.abspath(path.dirname(__file__))
sfile = 'site.conf'
mfile = 'modules'
SITECONF = path.join(BASEDIR, sfile)
MODULES = path.join(BASEDIR, mfile)

SITEREPLACEMENTS = {
    ## common
    "hostname_prefix = 'mz'": "hostname_prefix = 'wi'",
    "site_name = 'Freifunk Mainz'": "site_name = 'Freifunk Wiesbaden'",
    "site_code = 'ffmz'": "site_code = 'ffwi'",

    "prefix4 = '10.37.0.0/18'": "prefix4 = '10.56.0.0/18'",
    "prefix6 = 'fd37:b4dc:4b1e::/64'": "prefix6 = 'fd56:b4dc:4b1e::/64'",


    ## ntp_servers
    "'5.ntp.ffmz.org', 'fd37:b4dc:4b1e::a25:5',": "'5.ntp.ffwi.org', 'fd56:b4dc:4b1e::a38:5',",
    "'7.ntp.ffmz.org', 'fd37:b4dc:4b1e::a25:7',": "'7.ntp.ffwi.org', 'fd56:b4dc:4b1e::a38:7',",
    "'23.ntp.ffmz.org', 'fd37:b4dc:4b1e::a25:17',": "'23.ntp.ffwi.org', 'fd56:b4dc:4b1e::a38:17',",


    ## wifi
    "ssid = 'mainz.freifunk.net'": "ssid = 'wiesbaden.freifunk.net'",
    "mesh_ssid = '02:04:08:16:32:64'": "mesh_ssid = '64:32:16:08:04:02'",
    "mesh_bssid = '02:04:08:16:32:64'": "mesh_bssid = '64:32:16:08:04:02'",


    ## next_node
    "ip4 = '10.37.0.1'": "ip4 = '10.56.0.1'",
    "ip6 = 'fd37:b4dc:4b1e::1'": "ip6 = 'fd56:b4dc:4b1e::1'",
    "mac = '02:00:0a:25:00:01'": "mac = '02:00:0a:38:00:01'",


    ## gateways
    # Hinterschinken
    "key = 'f885d213b8f61f33d501a366ce36bc0a1baeb48da83294f41a63248cdc0ace36'": "key = 'f222d6fd564b959708a69e0525abf9c41d1add22419d8eeb7faf95b2a5900a63'",
    "'ipv4 \"gate05.ffmz.org\" port 10037'": "'ipv4 \"gate05.ffwi.org\" port 10056'",
    "'ipv6 \"gate05.ffmz.org\" port 10037'": "'ipv6 \"gate05.ffwi.org\" port 10056'",

    # Spinat
    "key = '7ebe0b5e6d15b1f8a525ba40f8289cbe60d99b54d15a2f89c5cf7448d25f2df1'": "key = '5c7aeb92ffc61c77564191eca7838f875fb4e75164c48bcc506b27e0a24696df'",
    "'ipv4 \"gate07.ffmz.org\" port 10037'": "'ipv4 \"gate07.ffwi.org\" port 10056'",
    "'ipv6 \"gate07.ffmz.org\" port 10037'": "'ipv6 \"gate07.ffmz.org\" port 10056'",

    # Lotuswurzel
    "key = '660d502abd1eb73822b942f8ca86554197f95fa55cb92cde943ef8b8d3a57ebf'": "key = '1112e095beea32ecd0ca32f8b88803d4cb9ed1867c3859a20eb1b5c2927cea64'",
    "'ipv4 \"gate23.ffmz.org\" port 10037'": "'ipv4 \"gate23.ffwi.org\" port 10056'",
    "'ipv6 \"gate23.ffmz.org\" port 10037'": "'ipv6 \"gate23.ffwi.org\" port 10056'",


    ## mirrors
    # Hinterschinken
    "'http://[fd37:b4dc:4b1e::a25:5]/": "'http://[fd56:b4dc:4b1e::a38:5]/",
    "'http://gate05.ffmz.org/": "'http://gate05.ffwi.org/",
    # Spinat
    "'http://[fd37:b4dc:4b1e::a25:7]/": "'http://[fd56:b4dc:4b1e::a38:7]/",
    "'http://gate07.ffmz.org/": "'http://gate07.ffwi.org/",
    # Lotuswurzel
    "'http://[fd37:b4dc:4b1e::a25:17]/": "'http://[fd56:b4dc:4b1e::a38:17]/",
    "'http://gate23.ffmz.org/": "'http://gate23.ffwi.org/",

    "/mz/stable/": "/wi/stable/",
    "/mz/beta/": "/wi/beta/",
    "/mz/nightly/": "/wi/nightly/",

    ## config_mode
    "keys@freifunk-mainz.de": "keys@freifunk-mainz.de", # TODO: Liste od. forwarding aufsetzen

}

MODULEREPLACEMENTS = {
    "PACKAGES_PLUS_BRANCH=mz": "PACKAGES_PLUS_BRANCH=wi",
    "PACKAGES_PLUS_COMMIT=e2f80149ed432e410e7214727dad616d5cf0ba44": "PACKAGES_PLUS_COMMIT=e2f80149ed432e410e7214727dad616d5cf0ba44"
}

def readfile(filename):
    if path.exists(filename):
        with open(filename, 'r') as f:
            return f.read()

def writefile(filename, content):
    with open(filename, 'w') as f:
        f.write(content)
    print('#written: %s' %(filename))

if __name__ == '__main__':

    sitemz = readfile(SITECONF)
    sitewi = sitemz

    modulesmz = readfile(MODULES)
    moduleswi = modulesmz

    for mz, wi in SITEREPLACEMENTS.items():
        sitewi = sitewi.replace(mz, wi)

    for mz, wi in MODULEREPLACEMENTS.items():
        moduleswi = moduleswi.replace(mz, wi)

    if len(argv) > 1:
        writefile(SITECONF, sitewi)

        writefile(MODULES, moduleswi)

    print(
        '''
%s\n%s\n\n%s\n\n
%s\n%s\n\n%s\n\n
        ''' %(
            sfile, '=' * len(sfile), sitewi,
            mfile, '=' * len(mfile), moduleswi)
        )

