
from service import read_yaml, read_file, kill_me
from string import Template

class Gateway(object):
    def __init__(self, net, gw, mfile='meta.yaml'):
        meta = read_yaml(mfile)

        self.net = net
        self.gw = gw

        self.n = meta['networks'][net]
        self.s = meta['networks'][net]['short']
        self.g = meta['gateways'][gw]['name']
        self.r = meta['gateways'][gw]['fastd']
        self.f = meta['formats']

    def ntp(self, glob=False):
        return self.f['ntp'] %(self.gw, self.n['ext'] if glob else self.n['int'])

    def v4(self):
        return self.f['v4'] %(self.net, self.gw)

    def v6(self):
        return self.f['v6'] %(self.net, self.net, self.gw)

    def cdns(self, glob=True): # c = count
        return self.f['cdns'] %(self.gw, self.n['ext'] if glob else self.n['int'])

    def ndns(self, glob=True): # n = named
        return self.f['ndns'] %(self.g, self.n['ext'] if glob else self.n['int'])

    def remote(self):
        return self.f['remote'] %(self.g, self.r[self.s], self.cdns(), self.net)

class SiteConf(object):
    def __init__(self, net, mfile='meta.yaml'):
        meta = read_yaml(mfile)

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
            'netnum_hex': '%x' %(net)
        })

        self.site.update({
            'ntp_v6': str(),
            'ntp_dns': str(),
            'gw_remotes': str()
        })

        for gb in meta['build']['branches']:
            self.site.update({
                'gw_mirrors_%s' %(gb): str()
            })

        for gw_num in meta['gateways'].keys():
            g = Gateway(net, gw_num)
            self.site['ntp_v6'] += '\'%s\', ' %(g.v6())
            self.site['ntp_dns'] += '\'%s\', ' %(g.ntp())
            self.site['gw_remotes'] += g.remote()
            for gb in meta['build']['branches']:
                self.site['gw_mirrors_%s' %(gb)] += '\'http://[%s]/gluon/%s/%s/sysupgrade/\', ' %(g.v6(), netcode, gb)
                self.site['gw_mirrors_%s' %(gb)] += '\'http://%s/gluon/%s/%s/sysupgrade/\', ' %(g.ndns(), netcode, gb)

        self.site.update({
            'pubkeys': str()
        })

        for pk in meta['build']['pubkeys'].keys():
            self.site['pubkeys'] += '\'%s\', -- %s\n' %(meta['build']['pubkeys'][pk], pk)


    def generate(self, sfile='templates/site.conf.template'):
        t = Template(read_file(sfile))

        siteconf = t.substitute(self.site)

        print(siteconf)


if __name__ == '__main__':
    s = SiteConf(56)
    s.generate()
