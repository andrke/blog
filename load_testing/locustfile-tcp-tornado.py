import time
import socket
import uuid
import json
import os
from tornado import gen
from tornado.ioloop import IOLoop
from tornado.tcpclient import TCPClient
from locust import User, TaskSet, events, task

DEBUG = True if os.environ.get("DEBUG", "false") == "true" else False


class TorandoClient(TCPClient):
    stream = None
    msg_separator = b'\r\n'

    @gen.coroutine
    def connect(self, host, port):
        start_time = time.time()
        try:
            self.stream = yield self.connect(host, port)
        except Exception as e:
            total_time = int((time.time() - start_time) * 1000)
            events.request_failure.fire(request_type="tcpsocket",
                                        name="connect",
                                        response_time=total_time,
                                        exception=e,
                                        response_length=0
                                        )
        else:
            total_time = int((time.time() - start_time) * 1000)
            events.request_success.fire(request_type="tcpsocket",
                                        name="connect",
                                        response_time=total_time,
                                        response_length=0)

    @gen.coroutine
    def send(self, msg):
        start_time = time.time()
        try:
            yield self.stream.write(msg)
        except Exception as e:
            total_time = int((time.time() - start_time) * 1000)
            events.request_failure.fire(request_type="tcpsocket",
                                        name="send",
                                        response_time=total_time,
                                        exception=e,
                                        response_length=len(msg)
                                        )
        else:
            total_time = int((time.time() - start_time) * 1000)
            events.request_success.fire(request_type="tcpsocket",
                                        name="send",
                                        response_time=total_time,
                                        response_length=len(msg),

                                        )

    @gen.coroutine
    def recv(self, bufsize):
        recv_data = ''
        start_time = time.time()
        try:
            recv_data = yield stream.read_until(self.msg_separator)
            body = recv_data.rstrip(self.msg_separator)
        except Exception as e:
            total_time = int((time.time() - start_time) * 1000)
            events.request_failure.fire(request_type="tcpsocket",
                                        name="recv",
                                        response_time=total_time,
                                        exception=e,
                                        response_length=len(recv_data)
                                        )
        else:
            total_time = int((time.time() - start_time) * 1000)
            events.request_success.fire(request_type="tcpsocket",
                                        name="recv",
                                        response_time=total_time,
                                        response_length=len(recv_data),
                                        )


class TcpSocketLocust(User):
    min_wait = 15 * 1000
    max_wait = 30 * 60 * 1000
    """
    This is the abstract Locust class which should be subclassed. It provides an TCP socket client
    that can be used to make TCP socket requests that will be tracked in Locust's statistics.
    author: Max.bai@2017
    """

    def __init__(self, *args, **kwargs):
        super(TcpSocketLocust, self).__init__(*args, **kwargs)
        self.client = TorandoClient()
        self.client.connect(*self._get_host_and_port())

    def _get_host_and_port(self):
        host = "localhost"
        port = 10080
        host_port = self.host.split(":")
        if len(host_port) == 2:
            host = host_port[0]
            port = int(host_port[1])
        return host, port

    @task
    class UserBehavior(TaskSet):
        def on_start(self):
            self.user_id = uuid.uuid4()

        @task
        def send_data(self):
            _send_data = json.dumps(dict(uuid=str(self.user_id), sleep=30)) + "\r\n"
            self.client.send(_send_data.encode())
            _recv_data = self.client.recv(2048).decode()
            if DEBUG:
                if _send_data == _recv_data:
                    print(_send_data)
                else:
                    print("Bad data received: {}".format(_recv_data))
