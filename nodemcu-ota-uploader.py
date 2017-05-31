#!/usr/bin/env python

import argparse
import math
import os.path
import requests

parser = argparse.ArgumentParser(description='nodemcu-ota-uploader')
parser.add_argument('file_path', help='File path to upload or \'restart\' command')
parser.add_argument('-r', '--restart', help='Restart after upload', action='store_true')
parser.add_argument('--host', help='NodeMCU host', required=True)
parser.add_argument('-p', '--port', help='NodeMCU port', default=80)
parser.add_argument('-t', '--timeout', help='Request timeout', default=10)
parser.add_argument('-c', '--chunk-size', help='Chunk size', default=1024)
args = parser.parse_args()


def upload(file_path):
	with open(file_path, 'r') as f:
		file_content = f.read()

	file_name = os.path.basename(file_path)
	send_url  = 'http://%s:%d/ota' % (args.host, args.port)
	file_length = len(file_content)

	print 'Upload file %s, size %d, with chunks by %d:' % (file_name, file_length, args.chunk_size)
	if file_length > args.chunk_size:
		chunk_num = 0
		chunks_total = math.ceil(file_length / (args.chunk_size + 0.0))
		for i in range(0, file_length, args.chunk_size):
			chunk_num = chunk_num + 1
			chunk = file_content[i:i+args.chunk_size]
			print('Chunk %d / %d...') % (chunk_num, chunks_total)
			r = requests.post(send_url, data={'filename': file_name, 'content': chunk, 'chunk': chunk_num }, timeout=args.timeout)
	else:
		r = requests.post(send_url, data={'filename': file_name, 'content': file_content }, timeout=args.timeout)

	print 'Upload finished.'

	if args.restart:
		restart()


def restart():
	restart_url = 'http://%s:%d/restart' % (args.host, args.port)
	r = requests.post(restart_url, timeout=args.timeout)
	print 'Restarted.'


def main():
	if args.file_path == 'restart':
		restart()
	else:
		upload(args.file_path)


main()
