
from argparse import ArgumentParser
from yaml import load
from string import Template

METAFILE = 'meta.yaml'
SITETEMPLATE = 'site.conf.tpl'
SITECONF = 'site.conf'

###
# service functions

def read_file(filename):
    with open(filename, 'r') as f:
        return f.read()

def write_file(filename, content):
    with open(filename, 'w') as f:
        return f.write(content)

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
        self.inturl = meta['networks'][netname]['int']
        self.exturl = meta['networks'][netname]['ext']
        self.gatename = meta['gateways'][gwnum]['name']
        self.pubkey = meta['gateways'][gwnum]['pubkey']
        self.f = meta['formats']

    def ntp(self, glob=False):
        return self.f['ntp'] %(self.gwnum, self.exturl if glob else self.inturl)

    def v4(self):
        return self.f['v4'] %(self.netnum, self.gwnum)

    def v6(self):
        return self.f['v6'] %(self.netnum, self.netnum, self.gwnum)

    def cdns(self, glob=True): # c: _c_ounted
        return self.f['cdns'] %(self.gwnum, self.exturl if glob else self.inturl)

    def ndns(self, glob=True): # n: _n_amed
        return self.f['ndns'] %(self.gatename, self.exturl if glob else self.inturl)

    def remote(self):
        return self.f['remote'] %(self.gatename, self.pubkey[self.netname], self.cdns(), self.netnum)

    def name(self):
        return str.capitalize(self.gatename)

def populate(netname):
    site = dict()

    netnum = meta['networks'][netname]['num']

    for s in meta['site']:
        if netname in meta['site'][s]:
            site.update({s: meta['site'][s][netname]})
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
    })

    for bb in meta['build']['branches']:
        site.update({'gw_mirrors_%s' %(bb): str()})

    for gwnum in meta['gateways'].keys():
        g = Gateway(netname, gwnum)
        site['ntp_v6'] += lua_listelem(g.v6(), comment='%s (IPv6)' %(g.name()), indent=2)
        site['ntp_dns'] += lua_listelem(g.ntp(), comment='%s (DNS)' %(g.name()), indent=2)
        site['gw_remotes'] += prepend_witespace(g.remote(), 4)
        for gb in meta['build']['branches']:
            site['gw_mirrors_%s' %(gb)] += lua_listelem('http://[%s]/gluon/%s/%s/sysupgrade/' %(g.v6(), netname, gb), comment='%s (IPv6)' %(g.name()), indent=5)
            site['gw_mirrors_%s' %(gb)] += lua_listelem('http://%s/gluon/%s/%s/sysupgrade/' %(g.ndns(), netname, gb), comment='%s (DNS)' %(g.name()), indent=5)

    for pk in meta['build']['signkeys'].keys():
        site['signkeys'] += lua_listelem(meta['build']['signkeys'][pk], comment=pk, indent=5)

    return site

def generate(netname):
    site = populate(netname)
    if site:
        return Template(read_file(SITETEMPLATE)).substitute(site)


if __name__ == '__main__':
    parser = ArgumentParser()
    for net in meta['networks'].keys():
        parser.add_argument('-%s' %(net[0]), '--%s' %(net), action='store_true', help='generate site for %s' %(meta['site']['site_name'][net]))

    res = parser.parse_args()
    print(generate('wi'))
