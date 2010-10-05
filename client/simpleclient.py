from twisted.protocols import basic

# Copyright (c) 2001-2004 Twisted Matrix Laboratories.
# See LICENSE for details.


"""
An example client. Run simpleserv.py first before running this.
"""

from twisted.internet import reactor, protocol, ssl
from twisted.internet.protocol import ClientFactory, Protocol

import json
# a client protocol

#class EchoClient(protocol.Protocol):
class EchoClient(basic.LineReceiver):
    """Once connected, send a message, then print the result."""
    
    def connectionMade(self):
        self.transport.write("hello, world!\r\n")
        pass
    
    def lineReceived(self, data):
        "As soon as any data is received, write it back."
        print "Server said:", data
        
        if (data == 'authenticate'):
            
            command = {
                'call': 'login',  
                'email': 'cloony@mail.hollywood.com',
                'password': 'hash_password',
                'instance': 'WinDesktop'
            }

            #self.transport.write(json.dumps(command) + "\r\n");
            self.sendLine(json.dumps(command));
        else:
            d = json.loads(data)
            if d.has_key('ticket'):
                print d.get('ticket')
                self.transport.loseConnection()
                
            print 'call: addEntity'
            
            command2 = {
                'call': 'addEntity',  
                'fileInfo': {
                    'path': 'files:folder/test.txt',
                    'modified': '01-01-2001 12:12:12', 
                    'size': 155444, 
                    'hash': 'a1729bc110c'
                }
            }
            self.sendLine(json.dumps(command2));
            
##            self.transport.loseConnection()
#            pass
    
#    def dataReceived(self, data):
#        "As soon as any data is received, write it back."
#        print "Server said:", data
#        
#        if (data == 'authenticate\r\n'):
#            
#            command = {
#                'call': 'login',  
#                'email': 'user@test.com',
#                'password': 'password',
#                'instance': 'WinDesktop'
#            }
#
#            self.transport.write(json.dumps(command) + "\r\n");
#        else:
#            self.transport.loseConnection()
    
    def connectionLost(self, reason):
        print "connection lost"

class EchoFactory(protocol.ClientFactory):
    protocol = EchoClient

    def clientConnectionFailed(self, connector, reason):
        print "Connection failed - goodbye!"
        reactor.stop()
    
    def clientConnectionLost(self, connector, reason):
        print "Connection lost - goodbye!"
        reactor.stop()


# this connects the protocol to a server runing on port 8000
def main():
    factory = EchoFactory()
    reactor.connectSSL('localhost', 843, factory, ssl.ClientContextFactory())
    reactor.run()

# this only runs if the module was *not* imported
if __name__ == '__main__':
    main()
