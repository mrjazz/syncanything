from twisted.web import http
from twisted.internet import ssl
import os

def renderIndex(request):

    colors = 'red', 'blue', 'green'

    flavors = 'vanilla', 'chocolate', 'strawberry', 'coffee'

    request.write("""

    <html>

    <head>

      <title>Form Test</html>

    </head>

    <body>

      <form enctype="multipart/form-data"  action='/upload' method='post'>

        Your name:

        <p>

          <input type='text' name='name'>

        </p>

        What's your favorite color?

        <p>

    """)

    for color in colors:

        request.write(

            "<input type='radio' name='color' value='%s'>%s<br />" % (

            color, color.capitalize( )))

    request.write("""

        </p>

        What kinds of ice cream do you like?

        <p>

        """)

    for flavor in flavors:

        request.write(

            "<input type='checkbox' name='flavor' value='%s'>%s<br />" % (

            flavor, flavor.capitalize( )))

    request.write("""

        </p>

        <p>
            <input name="entity" type="file" />
        </p>

        <input type='submit' />

      </form>

    </body>

    </html>

    """)

    request.finish( )



def handlePost(request):

    request.write("""

    <html>

      <head>

        <title>Posted Form Datagg</title>

      </head>

      <body>

      <h1>Form Data</h1>

    """)



    for key, values in request.args.items( ):

        request.write("<h2>%s</h2>" % key)

        request.write("<ul>")

        for value in values:

            request.write("<li>%s</li>" % value)

        request.write("</ul>")



    request.write("""

       </body>

    </html>

    """)

    request.finish( )


def handleUpload(request):
    print 'handleUpload'
    #print request.args

    form = request.args
    if form.has_key('entity'):

        path = os.curdir + '/tmp/'
        f = open(path + 'file.bin', 'wb')

        values = form['entity']
        for value in values:
            f.write(value) 
            
        f.close()
    request.finish( )

def read_file_by_chunks(filename, chunksize=100):
    f = open(filename, 'rb')
    while True:
        chunk = f.read(chunksize)
        if not chunk:
            break
        yield chunk
    f.close()

def handleDownload(request):
    print 'handleDownload'
    #print request.args
    
    path = os.curdir + '/tmp/'
    f = open(path + 'test.txt', 'rb')
    try:
        while True:
            chunk = f.read(100)
            if not chunk:
                break

            print chunk
            request.write(chunk)
    finally:
        f.close( )
    
    request.finish()

def handleDelete(request):
    print 'handleDelete'
    pass

class SyncAnyHandledRequest(http.Request):

    pageHandlers = {
        '/': renderIndex,
        '/post': handlePost,
        '/upload': handleUpload,
        '/download': handleDownload,
        '/delete': handleDelete,
    }

    def process(self):
        self.setHeader('Content-Type', 'text/html')
        if self.pageHandlers.has_key(self.path):
            handler = self.pageHandlers[self.path]
            handler(self)
        else:
            self.setResponseCode(http.NOT_FOUND)
            self.write("<h1>Not Found</h1>Sorry, no such page.")
            self.finish( )

class SyncAnyHttp(http.HTTPChannel):

    requestFactory = SyncAnyHandledRequest

#    def connectionMade(self):
#        print 'connectionMade'
#
#    def lineReceived(self, line):
#        print 'lineReceived'
#        print line
    
#    def rawDataReceived(self, data):
#        print 'rawDataReceived'
#        print data
#    
#    def headerReceived(self, line):
#        print 'headerReceived'
#        print line
#        
#    def requestDone(self, request):
#        print 'requestDone'
#        print request
#
#    def timeoutConnection(self):
#        print 'timeoutConnection'
#
#    def connectionLost(self, reason):
#        print 'connectionLost'
#        print reason

class SyncAnyHttpFactory(http.HTTPFactory):

    protocol = SyncAnyHttp

    def startFactory(self):
        print 'startFactory'
        pass
    
    def stopFactory(self):
        print 'stopFactory'
        pass


if __name__ == "__main__":

    from twisted.internet import reactor

    factory = SyncAnyHttpFactory( )
    reactor.listenSSL(8880, factory, ssl.DefaultOpenSSLContextFactory('./config/keys/server.key', './config/keys/server.crt'))
    
    reactor.run( )
    
