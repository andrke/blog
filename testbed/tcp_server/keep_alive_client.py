import sys
import socket
import traceback
import time

def do_work( forever = True):

    while True:

        # start with a socket at 5-second timeout
        print("Creating the socket")
        sock = socket.socket( socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5.0)

        # check and turn on TCP Keepalive
        x = sock.getsockopt( socket.SOL_SOCKET, socket.SO_KEEPALIVE)
        if( x == 0):
            print('Socket Keepalive off, turning on')
            x = sock.setsockopt( socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
            print('setsockopt=', x)
        else:
            print('Socket Keepalive already on')

        try:
            sock.connect(('192.168.88.215',8080))

        except socket.error:
            print('Socket connect failed! Loop up and try socket again')
            traceback.print_exc()
            time.sleep( 5.0)
            continue

        print('Socket connect worked!')

        while 1:
            try:
                msg = "Hello\r\n".encode()
                sock.send(msg)
                req = sock.recv(len(msg))

            except socket.timeout:
                print('Socket timeout, loop and try recv() again')
                time.sleep( 5.0)
                # traceback.print_exc()
                continue

            except:
                traceback.print_exc()
                print('Other Socket err, exit and try creating socket again')
                # break from loop
                break

            print('received', req)

        try:
            sock.close()
        except:
            pass

        # loop back up & restart

if __name__ == '__main__':

    do_work(True)
