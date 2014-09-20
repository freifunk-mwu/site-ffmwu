
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

def kill_me(reason=None):
    r = '' if not reason else '\n - %s' %(reason)
    print('ERROR!!1!%s' %(r))
    exit(23)
