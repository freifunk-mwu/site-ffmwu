#!/usr/bin/env python3

from argparse import ArgumentParser
from yaml import load
from string import Template

METAFILE = 'meta.yaml'
SITE=('site.conf.tpl', 'site.conf')
MAKEFILE=('site.mk.tpl', 'site.mk')
MODULES=('modules.tpl', 'modules')

###
# service functions

def read_file(filename):
    with open(filename, 'r') as f:
        return f.read()

def write_file(filename, content):
    with open(filename, 'w') as f:
        bytes = f.write(content)
        print('written: %s (%d bytes)' %(filename, bytes))

def read_yaml(filename):
    content = read_file(filename)
    if content: return load(content)

def prepend_witespace(s, i, iwidth=4):
    res = list()
    for r in str.rstrip(s).split('\n'):
        res.append('%s%s' %(' ' * (i * iwidth), r))
    return '\n'.join([r for r in res]) + '\n'

def lua_listelem(s, comment=None, indent=False):
    s = '\'%s\',%s' %(s, ' -- %s\n' %(comment) if comment else ' ')
    if indent and isinstance(indent, int):
        s = prepend_witespace(s, indent)
    return s

meta = read_yaml(METAFILE)

###
# gateways

class Gateway(object):
    def __init__(self, netname, gwnum):

        self.netname = netname
        self.gwnum = gwnum
        self.netnum = meta['networks'][netname]['num']
        self.srdurl = meta['networks'][netname]['srd']
        self.exturl = meta['networks'][netname]['ext']
        self.gatename = meta['gateways'][gwnum]['name']
        self.pubkey = meta['gateways'][gwnum]['pubkey']
        self.f = meta['formats']

    def ntp(self, shared=False):
        return self.f['ntp'] %(self.gwnum, self.srdurl if shared else self.exturl)

    def v4(self):
        return self.f['v4'] %(self.netnum, self.gwnum)

    def v6(self):
        return self.f['v6'] %(self.netnum, self.netnum, self.gwnum)

    def cdns(self, shared=True): # c: _c_ounted
        return self.f['cdns'] %(self.gwnum, self.srdurl if shared else self.exturl)

    def ndns(self, shared=True): # n: _n_amed
        return self.f['ndns'] %(self.gatename, self.srdurl if shared else self.exturl)

    def remote(self):
        return self.f['remote'] %(self.gatename, self.pubkey[self.netname], self.cdns(), self.netnum)

    def name(self):
        return str.capitalize(self.gatename)

def populate(netname):
    site = dict()

    netnum = meta['networks'][netname]['num']
    netlng = meta['networks'][netname]['lng']

    for s in meta['site']:
        if netname in meta['site'][s]:
            site.update({s: meta['site'][s][netname]})
        elif isinstance(meta['site'][s], str):
            site.update({s: meta['site'][s]})
        else:
            print('wrong data for %s - %s not found' %(s, netname))
            return False

    site.update({
        'hostname_prefix': netname,
        'netnum': netnum,
        'netnum_hex': '%x' %(netnum),
        'ntp_v6': str(),
        'ntp_dns': str(),
        'gw_remotes': str(),
        'signkeys': str(),
        'modules_name_cap': str.upper(site['modules_name']),
    })

    for bb in meta['build']['branches']:
        site.update({'gw_mirrors_%s' %(bb): str()})

    for gwnum in meta['gateways'].keys():
        g = Gateway(netname, gwnum)
        site['ntp_v6'] += lua_listelem(g.v6(), comment='%s (IPv6)' %(g.name()), indent=2)
        site['ntp_dns'] += lua_listelem(g.ntp(), comment='%s (DNS)' %(g.name()), indent=2)
        site['gw_remotes'] += prepend_witespace(g.remote(), 4)
        for gb in meta['build']['branches']:
            site['gw_mirrors_%s' %(gb)] += lua_listelem('http://[%s]/firmware/%s/%s/sysupgrade' %(g.v6(), netlng, gb), comment='%s (IPv6)' %(g.name()), indent=5)
            site['gw_mirrors_%s' %(gb)] += lua_listelem('http://firmware.ff%s.org/%s/sysupgrade' %(g.netname, gb), comment='%s (DNS)' %(g.name()), indent=5)

    for pk in meta['build']['signkeys'].keys():
        site['signkeys'] += lua_listelem(meta['build']['signkeys'][pk], comment=pk, indent=5)

    return site

def generate(netname, nomodules=False):
    site = populate(netname)
    if site:
        siteconf = Template(read_file(SITE[0])).substitute(site)
        write_file(SITE[-1], siteconf)

        makefile = Template(read_file(MAKEFILE[0])).substitute(site)
        write_file(MAKEFILE[-1], makefile)

        modules = Template(read_file(MODULES[0])).substitute(site)
        if not nomodules: write_file(MODULES[-1], modules)

if __name__ == '__main__':
    parser = ArgumentParser(prog='site-generator', description='generate similar sites for similar gluon builds for multi mesh gateways like those at freifunk-mwu', epilog='your ad here!', add_help=True)
    parser.add_argument('community', action='store', choices=meta['networks'].keys(), help='generate site for community')
    parser.add_argument('--nomodules', action='store_true', help='prevent modules file generation')

    res = parser.parse_args()
    generate(res.community, nomodules=res.nomodules)
