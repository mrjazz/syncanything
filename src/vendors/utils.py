import os
import datetime

class Datetime:
    @staticmethod
    def str_to_utc(dt_str, format = "%Y-%m-%dT%H:%M:%S"):
        dt, _, us = dt_str.partition(".")
        dt = datetime.datetime.strptime(dt, format)
        #us = int(us.rstrip("Z"), 10)
        us = 0
        return dt + datetime.timedelta(microseconds = us)
    
    @staticmethod
    def format_datetime(dt, format = "%Y-%m-%d %H:%M:%S"):
        #dt = datetime.datetime.strptime(dt, format)
        return str(dt.strftime(format))
    
    @staticmethod
    def utcformat_datetime(dt, format = "%Y-%m-%dT%H:%M:%S"):
        #dt = datetime.datetime.strptime(dt, format)
        return str(dt.strftime(format))
    
class File:

    @staticmethod
    def create(path, data):
        folders = path.replace('\\', '/').split('/')
        
        file = folders.pop()
        dirname = '/'.join(folders)
        
        exists = None
        try:
            os.makedirs(dirname)
            exists = True
        except OSError:
            if os.path.exists(dirname):
                # We are nearly safe
                print 'already exists'
                exists = True
            else:
                print 'not created'
#                for folder in folders:
#                    if not os.path.exists(folder):
#                        #create                
                exists = None
                # There was an error on creation, so make sure we know about it
                #raise

        if exists is True:
            open(path, 'w').write(data)

        return exists