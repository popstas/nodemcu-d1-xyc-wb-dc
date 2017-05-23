#!/usr/bin/env python

import argparse
import os.path
import requests

parser = argparse.ArgumentParser(description='nodemcu-ota-uploader')
parser.add_argument('file_path')
args = parser.parse_args()

host = '192.168.1.13'
port = 80

with open(args.file_path, 'r') as f:
    file_content=f.read()

file_name = os.path.basename(args.file_path)
send_url  = 'http://%s:%d/ota' % (host, port)
reset_url = 'http://%s:%d/reset' % (host, port)

r = requests.post(send_url, data={'filename': file_name, 'content': file_content })
#r = requests.post(reset_url)
