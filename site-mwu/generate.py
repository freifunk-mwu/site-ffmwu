
from yaml import load
from string import Template

###
# service functions

def read_file(filename):
    with open(filename, 'r') as f:
        return f.read()

def read_yaml(filename):
    content = read_file(filename)
    if content: return load(content)

meta = read_yaml('meta.yaml')

###
# gateways

class Gateway(object):
    def __init__(self, netnum, gwnum):

        self.netnum = netnum # number of network
        self.gwnum = gwnum   # number of gateway

        self.netname = meta['networks'][netnum]['name'] # name of network
        self.inturl = meta['networks'][netnum]['int']
        self.exturl = meta['networks'][netnum]['ext']
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

def populate(netnum):
    site = dict()

    netname = meta['networks'][netnum]['name']

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
        'pubkeys': str(),
    })

    for bb in meta['build']['branches']:
        site.update({'gw_mirrors_%s' %(bb): str()})

    for gwnum in meta['gateways'].keys():
        g = Gateway(netnum, gwnum)
        site['ntp_v6'] += '\'%s\', ' %(g.v6())
        site['ntp_dns'] += '\'%s\', ' %(g.ntp())
        site['gw_remotes'] += g.remote()
        for gb in meta['build']['branches']:
            site['gw_mirrors_%s' %(gb)] += '\'http://[%s]/gluon/%s/%s/sysupgrade/\', ' %(g.v6(), netname, gb)
            site['gw_mirrors_%s' %(gb)] += '\'http://%s/gluon/%s/%s/sysupgrade/\', ' %(g.ndns(), netname, gb)

    for pk in meta['build']['pubkeys'].keys():
        site['pubkeys'] += '\'%s\', -- %s\n' %(meta['build']['pubkeys'][pk], pk)

    return site


def generate(netname, sfile='templates/site.conf.template'):
    netnum = next((num for num, net in meta['networks'].items() if net['name'] == netname), None)
    site = populate(netnum)
    if site:
        siteconf = Template(read_file(sfile)).substitute(site)
        print(siteconf)

if __name__ == '__main__':
    generate('wi')
