# -*- coding:utf-8 -*-
# Taken from https://gist.github.com/yamionp/9112dd6e54694d594306
# Updated by Andres Kepler
import sys
print("This file is depricated")
sys.exit()

from __future__ import absolute_import
from __future__ import unicode_literals
from __future__ import print_function
import json
import uuid
import time
import gevent
import os

from websocket import create_connection
import six

from locust import HttpUser, TaskSet, task, events

WS_SERVER = os.environ.get("WS_SERVER", "127.0.0.1")
WS_SERVER_PORT = os.environ.get("WS_SERVER_PORT", "5000")
WS_ECHO_URL = os.environ.get("WS_ECHO_URL", "ws://{}:{}/echo".format(WS_SERVER, WS_SERVER_PORT))
WS_CHAT_URL = os.environ.get("WS_CHAT_URL", "ws://{}:{}/chat".format(WS_SERVER, WS_SERVER_PORT))

class EchoTaskSet(TaskSet):
    def on_start(self):
        self.user_id = six.text_type(uuid.uuid4())
        ws = create_connection(WS_ECHO_URL)
        self.ws = ws

        def _receive():
            while True:
                res = ws.recv()
                data = json.loads(res)
                end_at = time.time()
                response_time = int((end_at - data['start_at']) * 1000000)
                events.request_success.fire(
                    request_type='WebSocket Recv',
                    name='test/ws/echo',
                    response_time=response_time,
                    response_length=len(res),
                )

        gevent.spawn(_receive)

    def on_quit(self):
        self.ws.close()

    @task
    def sent(self):
        start_at = time.time()
        body = json.dumps({'message': 'hello, world', 'user_id': self.user_id, 'start_at': start_at})
        self.ws.send(body)
        events.request_success.fire(
            request_type='WebSocket Sent',
            name='test/ws/echo',
            response_time=int((time.time() - start_at) * 1000000),
            response_length=len(body),
        )


class ChatTaskSet(TaskSet):
    def on_start(self):
        self.user_id = six.text_type(uuid.uuid4())
        ws = create_connection(WS_CHAT_URL)
        self.ws = ws

        def _receive():
            while True:
                res = ws.recv()
                data = json.loads(res)
                end_at = time.time()
                response_time = int((end_at - data['start_at']) * 1000000)
                events.request_success.fire(
                    request_type='WebSocket Recv',
                    name='test/ws/chat',
                    response_time=response_time,
                    response_length=len(res),
                )

        gevent.spawn(_receive)

    def on_quit(self):
        self.ws.close()

    @task
    def sent(self):
        start_at = time.time()
        body = json.dumps({'message': 'hello, world', 'user_id': self.user_id, 'start_at': start_at})
        self.ws.send(body)
        events.request_success.fire(
            request_type='WebSocket Sent',
            name='test/ws/chat',
            response_time=int((time.time() - start_at) * 1000000),
            response_length=len(body),
        )


class EchoLocust(HttpUser):
    tasks = [EchoTaskSet]
    min_wait = 20000
    max_wait = 30000


class ChatLocust(HttpUser):
    tasks = [ChatTaskSet]
    min_wait = 20000
    max_wait = 30000