
from service import read_yaml, validate_keys, kill_me

class Gateway(object):
    def __init__(self, net, gw, mfile='meta.yaml'):
        meta = read_yaml(mfile)

        if not validate_keys(meta, ['networks', 'gateways', 'formats']) or not validate_keys(meta['networks']) or not validate_keys(meta['gateways']) or not validate_keys(meta['formats']):
            kill_me('insufficient yaml file')

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

if __name__ == '__main__':
    test = Gateway(56, 23)

    print('ntp', test.ntp())
    print('v4', test.v4())
    print('v6', test.v6())
    print('cdns', test.cdns())
    print('ndns', test.ndns())
    print('remote', test.remote())



