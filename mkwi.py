
## mkwi.py
# generates a site.conf for Freifunk Wiesbaden
#
# start it with any argument to replace the entire siteconf
# (use git to restore the original)

from os import path
from sys import argv
BASEDIR = path.abspath(path.dirname(__file__))
SITECONF = path.join(BASEDIR, 'site.conf')

REPLACEMENTS = {
    "hostname_prefix = 'mz'": "hostname_prefix = 'wi'",
    "site_name = 'Freifunk Mainz'": "site_name = 'Freifunk Wiesbaden'",
    "site_code = 'ffmz'": "site_code = 'ffwi'",
    "prefix4 = '10.37.0.0/16'": "prefix4 = '10.56.0.0/16'",
    "prefix6 = 'fd37:b4dc:4b1e::/64'": "prefix6 = 'fd56:b4dc:4b1e::/64'",
    "ssid = 'mainz.freifunk.net'": "ssid = 'wiesbaden.freifunk.net'",
    "ssid = 'mainz.freifunk.net 5GHz'": "ssid = 'wiesbaden.freifunk.net 5GHz'",
    "ip4 = '10.37.0.1'": "ip4 = '10.56.0.1'",
    "ip6 = 'fd37:b4dc:4b1e::1'": "ip6 = 'fd56:b4dc:4b1e::1'",
    "mac = '02:00:0a:25:00:01'": "mac = '02:00:0a:38:00:01'",
    "Hinterschinken = {\n                                        key = 'f885d213b8f61f33d501a366ce36bc0a1baeb48da83294f41a63248cdc0ace36'": "Hinterschinken = {\n                                        key = '2c181049a40be2f7bd9306cd02e4eefc9c19fd1c9a60d202ab95fa60a4a53c56'",
    "'ipv4 \"gate05.ffmz.org\" port 10037'": "'ipv4 \"gate05.ffmz.org\" port 10056'",
    "'ipv6 \"gate05.ffmz.org\" port 10037'": "'ipv6 \"gate05.ffmz.org\" port 10056'",
    "Spinat = {\n                                        key = '7ebe0b5e6d15b1f8a525ba40f8289cbe60d99b54d15a2f89c5cf7448d25f2df1'": "Spinat = {\n                                        key = '2c181049a40be2f7bd9306cd02e4eefc9c19fd1c9a60d202ab95fa60a4a53c56'",
    "'ipv4 \"gate07.ffmz.org\" port 10037'": "'ipv4 \"gate07.ffmz.org\" port 10056'",
    "'ipv6 \"gate07.ffmz.org\" port 10037'": "'ipv6 \"gate07.ffmz.org\" port 10056'",
    "'http://images.freifunk-mainz.de/gluon/mz/": "'http://images.freifunk-mainz.de/gluon/wi/",
    "'http://mirror.freifunk-wiesbaden.de/gluon/mz/": "'http://mirror.freifunk-wiesbaden.de/gluon/wi/",
    "'http://mirror.crazyhaze.de/ffmz/gluon/mz/": "'http://mirror.crazyhaze.de/ffmz/gluon/wi/",
    "Mainzer Freifunk-Community findest du auf": "Freifunk-Community in Mainz und Wiesbaden findest du auf",
    "<a href=\"http://mainz.freifunk.net/\">unserer Webseite</a>.": "der <a href=\"http://mainz.freifunk.net/\">Mainzer</a> oder <a href=\"http://www.freifunk-wiesbaden.de/\">Wiesbadener</a> Webseite."
}


def readfile(filename):
    if path.exists(filename):
        with open(filename, 'r') as f:
            return f.read()

def writefile(filename, content):
    with open(filename, 'w') as f:
        f.write(content)

if __name__ == '__main__':

    sitemz = readfile(SITECONF)
    sitewi = sitemz

    for mz, wi in REPLACEMENTS.items():
        sitewi = sitewi.replace(mz, wi)

    if len(argv) > 1:
        writefile(SITECONF, sitewi)
    else:
        print(sitewi)


