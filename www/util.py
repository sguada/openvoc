import socket
import time
import yaml

class Connection(object):

    def __init__(self, id, hostname='localhost', port=9999):
        self.hostname = hostname
        self.port = port
        self.id = id

    def _send_msg(self, msg):
        '''Sends a message, prepending the length as required by the
        protocol.'''
        length = '{:8d}'.format(len(msg))
        self.sock.sendall(length)
        self.sock.sendall(msg)

    def open(self):
        '''Opens the connection and registers with the server.'''
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect((self.hostname, self.port))
        reg_str = 'from: {0}\nto: {0}\n'.format(self.id)
        self._send_msg(reg_str)
        #print self.recv()

    def send(self, data_dict):
        '''Encodes the dictionary into YAML and sends it over the socket.'''
        data = yaml.dump(data_dict)
        self._send_msg(data)

    def recv(self):
        '''Receives a message over the socket by blocking.'''
        length = ''
        while len(length) < 8:
            length += self.sock.recv(8 - len(length))
            time.sleep(0.1)
        length = int(length)
        msg = ''
        while len(msg) < length:
            msg += self.sock.recv(length - len(msg))
            time.sleep(0.1)
        data = yaml.load(msg)
        return data
