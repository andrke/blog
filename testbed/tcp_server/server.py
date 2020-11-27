#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import time
from socket import socket, AF_INET, SOCK_STREAM
import threading
import os
import json
import logging

logging.basicConfig(level=logging.DEBUG)

DEFAULT_SRV_PORT = 8080

SRV_PORT = int(os.environ.get("SRV_PORT", DEFAULT_SRV_PORT))

buffsize = 2048


def tcplink(sock, addr):
    welcome_msg = json.dumps(dict(msg='Welcome!', addr=str(addr)))
    sock.send(welcome_msg.encode())
    while True:
        try:
            data = sock.recv(buffsize).decode()
            time.sleep(1)
            if data == 'exit' or not data:
                break
            logging.debug(data)
            sock.send(data.encode())
        except Exception as e:
            logging.exception(str(e))
            break
    sock.close()
    logging.debug('Connection from %s:%s closed.' % addr)


def main():
    host = '0.0.0.0'

    ADDR = (host, SRV_PORT)

    tctime = socket(AF_INET, SOCK_STREAM)
    tctime.bind(ADDR)
    tctime.listen(3)

    logging.debug('Wait for connection ...')
    while True:
        sock, addr = tctime.accept()
        logging.debug('Accept new connection from %s:%s...' % addr)

        t = threading.Thread(target=tcplink, args=(sock, addr))
        t.start()


if __name__ == "__main__":
    main()

