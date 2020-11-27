import os

from tornado import gen
from tornado.ioloop import IOLoop
from tornado.iostream import StreamClosedError
from tornado.tcpserver import TCPServer
import logging

logging.basicConfig(level=logging.DEBUG)

DEFAULT_SRV_PORT = 8080

SRV_PORT = int(os.environ.get("SRV_PORT", DEFAULT_SRV_PORT))


class Server(TCPServer):
    """
    This is a simple echo TCP Server
    https://github.com/Databrawl/real_time_tcp
    """
    message_separator = b'\r\n'

    def __init__(self, *args, **kwargs):
        self._connections = []
        super(Server, self).__init__(*args, **kwargs)

    @gen.coroutine
    def handle_stream(self, stream, address):
        """
        Main connection loop. Launches listen on given channel and keeps
        reading data from socket until it is closed.
        """
        try:
            print('New request has come from our {} buddy...'.format(address))
            while True:
                try:
                    request = yield stream.read_until(self.message_separator)
                    logging.debug(request)
                except StreamClosedError:
                    stream.close(exc_info=True)
                    logging.exception("Stream closed for {}".format(address))
                    return
                else:
                    try:
                        yield stream.write(request)
                    except StreamClosedError:
                        stream.close(exc_info=True)
                        logging.exception("Stream closed for {}".format(address))
                        return
        except Exception as e:
            if not isinstance(e, gen.Return):
                logging.exception("Connection loop has experienced an error.")

if __name__ == '__main__':
    logging.debug('Starting the server...')
    server = Server()
    server.bind(SRV_PORT)
    server.start(200)  # Forks multiple sub-processes
    IOLoop.current().start()

    logging.debug('Server has shut down.')