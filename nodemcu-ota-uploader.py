#!/usr/bin/env python

import argparse
import ConfigParser
import math
import os
import requests
import StringIO
import sys
import telnetlib
import time

parser = argparse.ArgumentParser(description='nodemcu-ota-uploader')
parser.add_argument('command', help='Command')
parser.add_argument('file_path', help='File path to upload or \'restart\' command', nargs='?', default=False)
parser.add_argument('-r', '--restart', help='Restart after upload', action='store_true')
parser.add_argument('-d', '--dofile', help='dofile() after upload', action='store_true')
parser.add_argument('--host', help='NodeMCU host')
parser.add_argument('-p', '--port', help='NodeMCU port', default=80)
parser.add_argument('-t', '--timeout', help='Request timeout', default=10)
parser.add_argument('-c', '--chunk-size', help='Chunk size', default=1024)
args = parser.parse_args()

telnet_port = 2323


def upload(file_path):
    with open(file_path, 'r') as f:
        file_content = f.read()

    filename = os.path.basename(file_path)
    send_url = 'http://%s:%d/ota' % (args.host, args.port)
    file_length = len(file_content)

    print 'Upload file %s, size %d, with chunks by %d:' % (filename, file_length, args.chunk_size)
    if file_length > args.chunk_size:
        chunk_num = 0
        chunks_total = math.ceil(file_length / (args.chunk_size + 0.0))
        for i in range(0, file_length, args.chunk_size):
            chunk_num = chunk_num + 1
            chunk = file_content[i:i + args.chunk_size]
            print 'Chunk %d / %d...' % (chunk_num, chunks_total)
            r = requests.post(send_url, data={'filename': filename, 'content': chunk, 'chunk': chunk_num},
                              timeout=args.timeout)
    else:
        r = requests.post(send_url, data={'filename': filename, 'content': file_content}, timeout=args.timeout)

    print 'Upload finished.'

    if args.dofile:
        dofile(filename)

    if args.restart:
        restart()


def tn_write(tn, str, pause=0.1):
    tn.write(str)
    time.sleep(pause)


def tn_command(tn, command, command_args=False, body=''):
    tn_write(tn, '#!cmd:%s' % command)

    if command_args:
        for k, v in command_args.iteritems():
            tn_write(tn, '#!arg:%s=%s' % (k, v))

    tn_write(tn, '#!body')
    first_line = True
    for line in body.split('\n'):
        tn.write(('' if first_line else '\n') + line)
        first_line = False
    time.sleep(1)
    tn_write(tn, '#!endbody', 0)

    res = tn.expect(['OK', 'ERROR'], 1)
    return True if res[2] == 'OK' else False


def upload_v2(file_path, max_tries=3):
    print args.host, telnet_port
    tn = telnetlib.Telnet(args.host, telnet_port)

    with open(file_path, 'r') as f:
        file_content = f.read()

    filename = os.path.basename(file_path)
    file_length = len(file_content)

    success = False
    tries = 0
    while not success and tries < max_tries:
        success = tn_command(tn, 'upload', {'filename': filename, 'length': file_length}, file_content)
        tries += 1
    tn.close()

    if not success:
        print 'Upload failed'
        sys.exit(1)

    print 'Upload finished' + (' (tries: %d)' % tries if tries > 1 else '')

    if args.dofile:
        dofile_v2(filename)

    if args.restart:
        restart_v2()


def dofile(filename):
    dofile_url = 'http://%s:%d/dofile' % (args.host, args.port)
    r = requests.post(dofile_url, data={'filename': filename}, timeout=args.timeout)
    print 'dofile(%s)' % filename


def dofile_v2(filename):
    tn = telnetlib.Telnet(args.host, telnet_port)
    tn_command(tn, 'dofile', {'filename': filename})
    tn.close()


def restart():
    restart_url = 'http://%s:%d/restart' % (args.host, args.port)
    r = requests.post(restart_url, timeout=args.timeout)
    print 'Restarted.'


def restart_v2():
    tn = telnetlib.Telnet(args.host, telnet_port)
    tn_command(tn, 'restart')
    tn.close()


def telnet():
    telnet_url = 'http://%s:%d/telnet' % (args.host, args.port)
    r = requests.post(telnet_url, timeout=args.timeout)
    port = int(r.text.split(': ')[-1])
    print 'Connect to %s:%d' % (args.host, port)
    tn = telnetlib.Telnet(args.host, port)
    print tn.interact()


def main():
    config_path = os.getcwd() + '/.ota'
    if os.path.isfile(config_path):
        config_raw = '[ota]\n' + open(config_path, 'r').read()
        config_fp = StringIO.StringIO(config_raw)
        config = ConfigParser.RawConfigParser()
        config.readfp(config_fp)
        if not args.host:
            args.host = config.get('ota', 'host')

    if not args.host:
        print('host not defined')
        sys.exit(1)

    if args.command == 'restart':
        restart()
    elif args.command == 'restart2':
        restart_v2()
    elif args.command == 'telnet':
        telnet()
    elif args.command == 'upload':
        upload_v2(args.file_path)
    else:
        upload(args.command)


main()
