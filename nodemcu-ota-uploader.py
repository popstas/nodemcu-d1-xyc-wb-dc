#!/usr/bin/env python

import argparse
import ConfigParser
import math
import os
import requests
import StringIO
import sys

parser = argparse.ArgumentParser(description='nodemcu-ota-uploader')
parser.add_argument('file_path', help='File path to upload or \'restart\' command')
parser.add_argument('-r', '--restart', help='Restart after upload', action='store_true')
parser.add_argument('-d', '--dofile', help='dofile() after upload', action='store_true')
parser.add_argument('--host', help='NodeMCU host')
parser.add_argument('-p', '--port', help='NodeMCU port', default=80)
parser.add_argument('-t', '--timeout', help='Request timeout', default=10)
parser.add_argument('-c', '--chunk-size', help='Chunk size', default=1024)
args = parser.parse_args()


def upload(file_path):
	with open(file_path, 'r') as f:
		file_content = f.read()

	filename = os.path.basename(file_path)
	send_url  = 'http://%s:%d/ota' % (args.host, args.port)
	file_length = len(file_content)

	print 'Upload file %s, size %d, with chunks by %d:' % (filename, file_length, args.chunk_size)
	if file_length > args.chunk_size:
		chunk_num = 0
		chunks_total = math.ceil(file_length / (args.chunk_size + 0.0))
		for i in range(0, file_length, args.chunk_size):
			chunk_num = chunk_num + 1
			chunk = file_content[i:i+args.chunk_size]
			print('Chunk %d / %d...') % (chunk_num, chunks_total)
			r = requests.post(send_url, data={'filename': filename, 'content': chunk, 'chunk': chunk_num }, timeout=args.timeout)
	else:
		r = requests.post(send_url, data={'filename': filename, 'content': file_content}, timeout=args.timeout)

	print 'Upload finished.'

	if args.dofile:
		dofile(filename)

	if args.restart:
		restart()


def dofile(filename):
	dofile_url = 'http://%s:%d/dofile' % (args.host, args.port)
	r = requests.post(dofile_url, data={'filename': filename}, timeout=args.timeout)
	print 'dofile(%s)' % filename


def restart():
	restart_url = 'http://%s:%d/restart' % (args.host, args.port)
	r = requests.post(restart_url, timeout=args.timeout)
	print 'Restarted.'


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

	if args.file_path == 'restart':
		restart()
	else:
		upload(args.file_path)


main()
