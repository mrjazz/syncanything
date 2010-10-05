from time import sleep
import uuid

import threading

from config.loggger import Logger
log = Logger.get("Dispatcher")

class Singleton(type):
    def __init__(cls, name, bases, dict):
        super(Singleton, cls).__init__(name, bases, dict)
        cls.instance = None

    def __call__(cls, *args, **kw):
        if cls.instance is None:
            cls.instance = super(Singleton, cls).__call__(*args, **kw)
        return cls.instance


class Event:

    def __init__(self, type, data = None):
        self.__type = type
        self.__data = data
        self.target = None

    def getType(self):
        return self.__type

    def getData(self):
        return self.__data


class Dispatcher:

    def __init__(self):
        self.__listeners = {}

    def addListener(self, event_type, handler):
        log.info("Dispatcher::addListener(%s, %s)" % (event_type, handler))

        if not self.__listeners.has_key(event_type):
            self.__listeners[event_type] = []
        if not handler in self.__listeners[event_type]:
            self.__listeners[event_type].append(handler)

        log.info("Listeners: %s" % (self.__listeners))

    def removeListener(self, event_type, handler):
        log.info("Dispatcher::removeListener(%s, %s)" % (event_type, handler))
        if self.hasListener(event_type, handler):
            self.__listeners[event_type].remove(handler)

        log.info("Listeners: %s" % (self.__listeners))

    def hasListener(self, event_type, handler):
        log.info("Dispatcher::hasListener(%s, %s)" % (event_type, handler))

        if event_type in self.__listeners and handler in self.__listeners[event_type]:
            log.info("Dispatcher has listener")
            return True
        else:
            log.info("Dispatcher hasn\'t listener")
            return False

    def dispatch(self, event):
        log.info("Dispatcher::dispatch(%s, %s, %s)" % (event.getType(), ObjectsManager().getGUIDByObj(self), self))
        log.info("Listeners: %s" % (self.__listeners))
        event.target = self
        if self.__listeners.has_key(event.getType()):
            log.info("Found listener type is %s" % (event.getType()))
            for i in self.__listeners[event.getType()]:
                if callable(i):
                    CallProcessor().add(i, [event])

class ServerObject(Dispatcher):

    def __init__(self):
        Dispatcher.__init__(self)
        self.GUID = str(uuid.uuid4())

    def info(self):
        attrs = vars(self)

        props = {}
        for key in attrs:
            if key[0] != '_': props[key] = attrs[key]

        return props


class ObjectsManager:
    __metaclass__ = Singleton

    def __init__(self):
        self._objects = {}

    def __checkObj(self, object):
        if not isinstance(object, ServerObject):
            raise Exception("Object manager support only inherited from ServerObject types")
        return True

    def addObject(self, object):
        if (self.__checkObj(object)):
            self._objects.setdefault(object.GUID, object)
            return object
        else:
            return None

    def getGUIDByObj(self, obj):
        for i in self._objects:
            if self._objects.get(i) == obj:
                return i
        return None

    def getObjByGUID(self, guid):
        return self._objects.get(guid)

    def delObjByGUID(self, guid):
        del self._objects[guid]

    def delObj(self, object):
        if (self.__checkObj(object)):
            self.delObjByGUID(object.GUID)

    def delAll(self):
        self._objects = {}

    def getAll(self):
        return self._objects

class CallProcessor:

    __metaclass__ = Singleton

    def __init__(self):
        self.__commands = []
        self.proc = threading.Thread(target=self.process, name="processing")
        self.proc.start()

    def add(self, func, args):
        print 'CallProcessor::addCall', repr(func)
        self.__commands.append([func, args])

    def process(self):
        while True:
            if len(self.__commands) > 0:
                call = self.__commands.pop(0)
                if callable(call[0]):
                    print 'CallProcessor::process', repr(call)
                    call[0](*call[1])
            sleep(0.05)

