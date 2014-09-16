
from service import read_yaml, validate_keys, kill_me

class Gateway(object):
    def __init__(self, net, gw, mfile='gateway.yaml'):
        meta = read_yaml(mfile)

        if not validate_keys(meta, ['networks', 'gateways', 'formats']) or not validate_keys(meta['networks']) or not validate_keys(meta['gateways']) or not validate_keys(meta['formats']):
            kill_me('insufficient yaml file')

        self.net = net
        self.gw = gw

        self.n = meta['networks'][net]
        self.g = meta['gateways'][gw]
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

if __name__ == '__main__':
    hinterschinken = Gateway(37, 5)

    print('ntp', hinterschinken.ntp())
    print('v4', hinterschinken.v4())
    print('v6', hinterschinken.v6())
    print('cdns', hinterschinken.cdns())
    print('ndns', hinterschinken.ndns())



