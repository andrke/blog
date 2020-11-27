# -*- coding: utf-8 -*-
# Taken from https://gist.github.com/yamionp/9112dd6e54694d594306
# Updated by Andres Kepler
from __future__ import absolute_import
from __future__ import unicode_literals
from __future__ import print_function

from collections import defaultdict
import json
import os
import  time

from geventwebsocket.handler import WebSocketHandler
from gevent.pywsgi import WSGIServer
from flask import Flask, request
from werkzeug.exceptions import abort

DEFAULT_FLASK_PORT = 8080

FLASK_PORT = int(os.environ.get("FLASK_PORT", DEFAULT_FLASK_PORT))

app = Flask(__name__)

ctr = defaultdict(int)


@app.route('/echo')
def echo():
    ws = request.environ['wsgi.websocket']
    if not ws:
        abort(400)

    while True:
        message = ws.receive()
        if message is not None:
            r = json.loads(message)
            ctr[r['user_id']] += 1
            time.sleep(10)

        ws.send(message)


@app.route('/report')
def report():
    return '\n'.join(['{}:\t{}'.format(user_id, count) for user_id, count in ctr.items()])


socket_handlers = set()


@app.route('/chat')
def chat():
    ws = request.environ['wsgi.websocket']
    socket_handlers.add(ws)

    while True:
        message = ws.receive()
        for socket_handler in socket_handlers:
            try:
                socket_handler.send(message)
                time.sleep(10)
            except:
                socket_handlers.remove(socket_handler)


if __name__ == '__main__':
    http_server = WSGIServer(('', FLASK_PORT), app, handler_class=WebSocketHandler)
    http_server.serve_forever()