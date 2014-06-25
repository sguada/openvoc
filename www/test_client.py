import socket
import sys
import yaml
import time

if len(sys.argv) < 4:
    print "Usage: ", sys.argv[0], " sender recipient subject"
    sys.exit(1)

HOST, PORT = "localhost", 9999
sender = sys.argv[1]
recipient = sys.argv[2]
id_string = "from: %s" % sender
to_string = "to: %s" % recipient
subject = " ".join(sys.argv[3:])

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

#WARNING: Protocol is: first 8 characters is the length of the
#message, then the message itself!!!

try:
    # Connect to server and send data
    sock.connect((HOST, PORT))
    print "Connected, sending id ", id_string
    data = id_string + "\n" + to_string + "\n"
    l = "%8d" % len(data)
    sock.sendall(l)
    sock.sendall(data)
    
    struct = {}
    struct["from"] = sender
    struct["to"] = recipient
    struct["subject"] = subject
    
    
    data = yaml.dump(struct)
    print "Id sent, sending message: ", data
    l = "%8d" % len(data)    
    sock.sendall(l)
    sock.sendall(data)
    
    
    print "Now listening for some stuff"
    while True:
        data = sock.recv(1024)
        time.sleep(0.1)
        print "data received: ", data
    
    print "Done"
    
except Exception, e:
    print "Error: ", e
finally:
    print "Closing connection"
    sock.close()


sys.exit(0)
