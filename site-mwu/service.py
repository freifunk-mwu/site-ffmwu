
from os import path
from yaml import load
from sys import exit

def exists_file(filename):
    return path.exists(filename)

def read_file(filename):
    if exists_file(filename):
        with open(filename, 'r') as f:
            return f.read()

def read_yaml(filename):
    content = read_file(filename)
    if content:
        return load(content)

def validate_keys(vdict, klist=None):
    if not klist and isinstance(vdict, dict):
        klist = list(vdict.keys())
    if isinstance(klist, str):
        klist = list(klist)
    if isinstance(vdict, dict) and isinstance(klist, list):
        return all([key in vdict and vdict[key] != None for key in klist])

def kill_me(reason=None):
    r = '' if not reason else '\n - %s' %(reason)
    print('ERROR!!1!%s' %(r))
    exit(23)
