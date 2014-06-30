from util import Connection
import gflags

import sys

gflags.DEFINE_string('img', 'check.png', 'The image to respond with always')
FLAGS = gflags.FLAGS

def loop():
    conn = Connection('matlab')
    conn.open()
    while True:
        data = conn.recv()
        print data
        # ignore the data and send back a fixed message
        data = {}
        data['from'] = 'matlab'
        data['to'] = 'web'
        data['subject'] = 'display'
        data['display'] = FLAGS.img
        conn.send(data)

if __name__ == '__main__':
    gflags.FLAGS(sys.argv)

    loop()
