# Application logic #

Client application should be easy installed on local machine. Installer have to ask user about his email/password or provide him signup/forgot password links. The application will ask user about path to files that should be synchronized and ask whether he would like to install another plug-in or not. There will be several plug-ins available (Contact Plug-in, Wallet Plug-in, etc). The first plug-in will be provided in the first milestone is Contact Plug-in (Contact synchronization).
When something changes on client (actually we are not always can handle this, so it can be periodically checking changes when system idle). When client send changes to the server server overwrite old file with new and notify all connected clients about changes. In case if a few files was uploaded simultaneously (time start/end of two downloads are overlapped system store overwrite old file with latest revision and store conflicted version near, or maybe ask user to resolve conflict with client application in case Contact synchronization). During synchronization client application represent updating status or progressbar.
Types of data for Contact Plug-In


Files represented in Data Storage like path + name, system = false.
Contacts represented as person\_id + client\_id (the same person on different platforms has different ids) and list of fields/values:
  * First Name
  * Last Name
  * Job Title
  * Department
  * Company
  * Home Address
  * Work Address
  * Home Phone
  * Work Phone
  * Mobile Phone
  * Home email
  * Work email
  * Chat Address
  * Birthday
  * Homepage

Supported by local client fields will be synchronized.
Serverside functionality

Protocol API based on SSL over XML-RPC protocol.
Calls that should be supported with protocol:
  * Name	Description
  * login(email: String, password: String)	Authenticate the user
  * addEntity(path:String, file:String)	Send from client to server some data package.
  * removeEntity(path:String)
  * syncEntities(entities: Array)
  * sendLog(level: int, text: String)	logging client states
  * updateProfile(email:String, password:String)	update user’s profile

For serialization commands used JSON protocol.

**Serverside include three main modules:**
Socket server (communicate to clients, send commands, generate tickets)
Files service (send and receive files by ticket through https)
WebServer (web frontend that allow users be registered, restore passwords, look through stored information)


**Technical details:**
FileStorage based on file system and DataStorage based on mysql. Programming language for socket server is Python. For web frontend and fileservice language is PHP.
OS Platform: unix/linux

# Frontend website #

Site include pages:
homepage with login/password
create an account form with fields: First name, Last name, Email, Password
files tab for logged users
address book tab for logged users
static pages like: policies, prices, helps, etc

NOTE: Should we create multilingual site or only English?

# Files service #

Files service should decrease loading of socket server and main idea is provide alternative but secure way for uploading/downloading files. When server sends to client command download or upload file he sends only ticket (hash) with this hash client can download/upload file during 24h. In case if ticket expired, client ask syncing again for the file (and receive new ticket if necessary)

# Socket server #

Socket server process all interactions between client and server.
JSON API calls:
Login (from client to sever)

```
Send:
{
  call:”login”,   
  email:”test@test.com”,
  password:”passwd”,
  instance:”WinDesktop”,
  client_hash: “as334ff9221bba”
}
Return:
{command: “login”, session:”HASH_OF_SESSION”}
```
updateEntity (from server to client)
```
Send:
{
  call:”updateEntity”,
  fileInfo:{
    path:”files:folder/test.txt”, 
    modified:”01-01-2001 12:12”, 
    size:155444, 
    hash:”a1729bc110c”,
    ticket: “abb238cf”,
    action: “upload”
  }
}
Return:
{status:”ok|fail”}
```

removeEntity (from server to client)
```
Send:
{
  call:”removeEntity”,
  fileInfo:{
    path:”files:folder/test.txt”, 
    modified:”01-01-2001 12:12”, 
    size:155444, 
    hash:”a1729bc110c”
  }
}

Return:
{status:”ok|fail”}
```

syncEntities (from client to server)
```
Send:
{
  call:”syncEntities”,
  entities: [
    {
      path:”files:folder/test.txt”, 
      modified:”01-01-2001 12:12”, 
      size:155444, 
      removed:true,
      hash:”a1729bc110c”
    },
    {
      path:”files:folder/subfolder/test1.txt”, 
      modified:”12-01-2001 10:12”, 
      size:145654, 
      removed:false,
      hash:”1ffae110c”
    },
  ]
}

Return:
{
    “command”: “syncEntities”,
    [{
      path:”files:folder/test.txt”, 
      modified:”01-01-2001 12:12”, 
      size:155444, 
      hash:”a1729bc110c”,
      action: “upload”,
      ticket: “1affe36”
    },
    {
      path:”files:folder/subfolder/test1.txt”, 
      modified:”12-01-2001 10:12”, 
      size:145654, 
      hash:”1ffae110c”,
      action:”download”,
      ticket: “bb471ae”
    }]
}
```

sendLog (from client to server)
```
{
call: “sendLog”, 
level: 1, 
details: “some text”
}
Return:
Nothing
```

# Data Model #

**User**
  * id: int
  * email: String
  * password: String
  * quotaInfo: int


**Entity**
path: String (file:docs/help.pdf, contacts:customers/3845A174-EB30-11D1-9A23-00A0C879FE5F.vcf)


**Address book entity**
Most recommended store personal data from address book in excanhable vCard format (http://en.wikipedia.org/wiki/VCard, http://www.ietf.org/rfc/rfc2426.txt) it can be easily merged and stored for all exists information about profile (from different platforms)

# DB structure #

Users
  * id: int
  * firsrt\_name: string (256)
  * last\_name: string (256)
  * password (hash): string (32)
  * email (256)
  * plan: string (25)
  * created: datetime
  * modified: datetime


Entities
  * id: int
  * user\_id: int
  * transaction\_id: int
  * path: string (2000)
  * created: datetime
  * modified: datetime
  * hash: string (256)
  * stored: string (5000)
  * deleted: boolean = false


Transactions
  * id: int
  * user\_id: int
  * entity\_id: int
  * client\_id: int
  * ticket: string(64)
  * started: datetime
  * finished: datetime
  * action: int (0 - upload, 1 - download, 2 - delete)


Clients
  * id: int
  * user\_id: int
  * client\_hash: string (32)
  * client: string (256)
  * created: datetime


Logs
  * id: int
  * user\_id: int
  * client\_id: int
  * level: int
  * details: text
  * created: datetime


# Clients #

Client modules:
OS hooks for Address book, Files
SSL through sockets
Socket server protocol implementation
Latest version searching (with correct timezone shifting)
Posting/getting through HTTPS
QueueCommands (Finite State Machine implementation)
Build indexes over exists data


# Desktop application #

Client should be displayed in tray and change icon depends to application state (idle, synchronization). Context menu include items:
Open folder
Open site
Settings
Quit


Client has local storage for indexing entities. Index should be created when application started first time and updated always when files synchronized.