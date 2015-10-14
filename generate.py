#!/usr/bin/env python3

from argparse import ArgumentParser
from yaml import load
from string import Template

SETTINGSFILE = 'settings.yaml'
SITE = ('site.conf.tpl', 'site.conf')
MAKEFILE = ('site.mk.tpl', 'site.mk')
MODULES = ('modules.tpl', 'modules')
TRANSLATION = ('i18n/%s.po.tpl', 'i18n/%s.po')
LANGS = ['en', 'de']

###
# service functions


def read_file(filename):
    with open(filename, 'r') as f:
        return f.read()


def write_file(filename, content):
    with open(filename, 'w') as f:
        bytes = f.write(content)
        print('written: %s (%d bytes)' % (filename, bytes))


def read_yaml(filename):
    content = read_file(filename)
    if content:
        return load(content)


def prepend_witespace(content, indent, identwidth=4):
    res = list()
    for r in str.rstrip(content).split('\n'):
        res.append('%s%s' % (' ' * (indent * identwidth), r))
    return '\n'.join([r for r in res]) + '\n'


def lua_listelem(content, comment=None, indent=False):
    content = '\'%s\',%s' % (
        content, ' -- %s\n' % (comment) if comment else ' '
    )
    if indent and isinstance(indent, int):
        content = prepend_witespace(content, indent)
    return content

settings = read_yaml(SETTINGSFILE)

###
# gateways


class Gateway(object):
    def __init__(self, netname, gwnum):

        self.netname = netname
        self.gwnum = gwnum
        self.netnum = settings['networks'][netname]['num']
        self.srdurl = settings['networks'][netname]['srd']
        self.inturl = settings['networks'][netname]['int']
        self.gatename = settings['gateways'][gwnum]['name']
        self.pubkey = settings['gateways'][gwnum]['pubkey']
        self.f = settings['formats']

    def ntp(self):
        return self.f['ntp'] % (
            self.gwnum, self.inturl
        )

    def v4(self):
        return self.f['v4'] % (
            self.netnum, self.gwnum
        )

    def v6(self):
        return self.f['v6'] % (
            self.netnum, self.netnum, self.gwnum
        )

    def cdns(self, shared=True):  # c: _c_ounted
        return self.f['cdns'] % (
            self.gwnum, self.srdurl if shared else self.inturl
        )

    def ndns(self, shared=True):  # n: _n_amed
        return self.f['ndns'] % (
            self.gatename, self.srdurl if shared else self.inturl
        )

    def remote(self):
        return self.f['remote'] % (
            self.gatename, self.pubkey[self.netname], self.ndns(), self.netnum
        )

    def name(self):
        return str.capitalize(self.gatename)


def populate(netname, priority=None):
    site = dict()

    netnum = settings['networks'][netname]['num']
    netlng = settings['networks'][netname]['lng'].lower()
    opkg_url = 'http://openwrt.%s/%s/%s' % (
        settings['networks'][netname]['int'],
        settings['openwrt']['release_name'],
        settings['openwrt']['release_ver']
    )

    for elem in settings['site']:
        if netname in settings['site'][elem]:
            site.update({elem: settings['site'][elem][netname]})
        elif isinstance(settings['site'][elem], str):
            site.update({elem: settings['site'][elem]})
        else:
            print('wrong data for %s - %s not found' % (elem, netname))
            return False

    site.update({
        'opkg_repo': str(opkg_url + '/%S/packages'),
        'netnum': netnum,
        'netnum_hex': '%x' % (netnum),
        'ntp_v6': str(),
        'ntp_dns': str(),
        'gw_remotes': str(),
        'signkeys': str(),
        'modules_name_cap': str.upper(site['modules_name']),
        'city': str.capitalize(netlng)
    })

    if priority is not None:
        site.update({'gluon_priority': priority})

    for gluon_branch in settings['build']['branches']:
        site.update({'gw_mirrors_%s' % (gluon_branch): str()})

    for gwnum in settings['gateways'].keys():
        g = Gateway(netname, gwnum)
        site['ntp_v6'] += lua_listelem(
            g.v6(), comment='%s (IPv6)' % (g.name()), indent=2
        )
        site['ntp_dns'] += lua_listelem(
            g.ntp(), comment='%s (DNS)' % (g.name()), indent=2
        )
        site['gw_remotes'] += prepend_witespace(g.remote(), 5)
        for gluon_branch in sorted(settings['build']['branches']):
            combined = lua_listelem(
                'http://firmware.%s/%s/sysupgrade' % (
                    settings['networks'][netname]['int'],
                    gluon_branch
                ), comment='combined (DNS)', indent=5
            )
            site['gw_mirrors_%s' % (gluon_branch)] += (
                combined
                if combined not in site['gw_mirrors_%s' % (gluon_branch)]
                else ''
            )

    for pk in sorted(settings['build']['signkeys'].keys()):
        site['signkeys'] += lua_listelem(
            settings['build']['signkeys'][pk], comment=pk, indent=5
        )
    return site


def generate(netname, nomodules=False, priority=None):
    site = populate(netname, priority)
    if site:
        siteconf = Template(read_file(SITE[0])).substitute(site)
        write_file(SITE[-1], siteconf)

        makefile = Template(read_file(MAKEFILE[0])).substitute(site)
        write_file(MAKEFILE[-1], makefile)

        if not nomodules:
            modules = Template(read_file(MODULES[0])).substitute(site)
            write_file(MODULES[-1], modules)

        for lang in LANGS:
            translation = Template(
                read_file(TRANSLATION[0] % (lang))
            ).substitute(site)
            write_file(TRANSLATION[-1] % (lang), translation)


if __name__ == '__main__':
    parser = ArgumentParser(
        prog='site-generator',
        description='generate similar sites for similar gluon builds\
            for multi mesh gateways like those at freifunk-mwu',
        epilog='your ad here!',
        add_help=True
    )
    parser.add_argument(
        'community',
        action='store',
        choices=settings['networks'].keys(),
        help='generate site for community'
    )
    parser.add_argument(
        '--nomodules',
        action='store_true',
        help='prevent modules file generation'
    )
    parser.add_argument(
        '--priority',
        action='store',
        help='overwrite gluon priority'
    )

    args = parser.parse_args()
    generate(args.community, nomodules=args.nomodules, priority=args.priority)
