
from service import read_yaml, read_file, kill_me
from string import Template

meta = read_yaml('meta.yaml')

class Gateway(object):
    def __init__(self, net, gw):

        self.net = net # number of network
        self.gw = gw   # number of gateway

        self.n = meta['networks'][net]
        self.netcode = meta['networks'][net]['short'] # short name of network
        self.g = meta['gateways'][gw]['name']
        self.r = meta['gateways'][gw]['fastd']
        self.f = meta['formats']

    def ntp(self, glob=False):
        return self.f['ntp'] %(self.gw, self.n['ext'] if glob else self.n['int'])

    def v4(self):
        return self.f['v4'] %(self.net, self.gw)

    def v6(self):
        return self.f['v6'] %(self.net, self.net, self.gw)

    def cdns(self, glob=True): # c: _c_ounted
        return self.f['cdns'] %(self.gw, self.n['ext'] if glob else self.n['int'])

    def ndns(self, glob=True): # n: _n_amed
        return self.f['ndns'] %(self.g, self.n['ext'] if glob else self.n['int'])

    def remote(self):
        return self.f['remote'] %(self.g, self.r[self.netcode], self.cdns(), self.net)

class SiteConf(object):
    def __init__(self, net):

        self.site = dict()
        netcode = meta['networks'][net]['short']

        for s in meta['site']:
            if netcode in meta['site'][s]:
                self.site.update({s: meta['site'][s][netcode]})
            else:
                kill_me('no valid data found for %s' %(s))

        self.site.update({
            'hostname_prefix': netcode,
            'netnum': net,
            'netnum_hex': '%x' %(net),
            'ntp_v6': str(),
            'ntp_dns': str(),
            'gw_remotes': str(),
            'pubkeys': str(),
        })

        for bb in meta['build']['branches']:
            self.site.update({'gw_mirrors_%s' %(bb): str()})

        for gw_num in meta['gateways'].keys():
            g = Gateway(net, gw_num)
            self.site['ntp_v6'] += '\'%s\', ' %(g.v6())
            self.site['ntp_dns'] += '\'%s\', ' %(g.ntp())
            self.site['gw_remotes'] += g.remote()
            for gb in meta['build']['branches']:
                self.site['gw_mirrors_%s' %(gb)] += '\'http://[%s]/gluon/%s/%s/sysupgrade/\', ' %(g.v6(), netcode, gb)
                self.site['gw_mirrors_%s' %(gb)] += '\'http://%s/gluon/%s/%s/sysupgrade/\', ' %(g.ndns(), netcode, gb)

        for pk in meta['build']['pubkeys'].keys():
            self.site['pubkeys'] += '\'%s\', -- %s\n' %(meta['build']['pubkeys'][pk], pk)


    def generate(self, sfile='templates/site.conf.template'):
        t = Template(read_file(sfile))

        siteconf = t.substitute(self.site)

        print(siteconf)


if __name__ == '__main__':
    s = SiteConf(56)
    s.generate()
