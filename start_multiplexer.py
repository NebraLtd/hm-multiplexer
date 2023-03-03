#!/usr/bin/env python3
import os
import json


TTN_CONF_FILE = '/var/nebra/ttn_conf.json'


def read_ttn_config():
    try:
        with open(TTN_CONF_FILE) as file_:
            ttn_config = json.loads(file_.read())

        return ttn_config
    except FileNotFoundError:
        # Config file doesn't exist yet, assume TTN not enabled.
        return {
            'ttn_enabled': False,
            'ttn_cluster': 'eu'
        }


def main():
    bin = '/usr/local/bin/gwmp-mux'
    cmd = '%s --client helium-miner:1680 --client thix-forwarder:1680' % bin

    ttn_config = read_ttn_config()
    if ttn_config.get('ttn_enabled', False):
        ttn_cluster = ttn_config.get('ttn_cluster')
        cmd += ' --client %s:1700' % ttn_cluster

    os.system(cmd)


if __name__ == '__main__':
    main()
