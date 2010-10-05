from zope.interface import Interface, implements

class IUser(Interface):
    "should have attributes username and fullname"

class User:

    implements(IUser)

    def __init__(self, id, first_name, last_name, password, email, plan):
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.fullname = self.first_name + ' ' + self.last_name
        self.password = password
        self.email = email
        self.plan = plan