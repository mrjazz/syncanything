//
//  AppController.m
//  SyncAnyApp
//
//  Created by Corbie on 9/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <YAJL/YAJL.h>

#import "AppController.h"
#import "AsyncSocket.h"
#import "FileStorage.h"
#import "Config.h"
#import "EntityProtocol.h"
#import "SyncServerActions.h"
#import "FileEntity.h"



@implementation AppController



- (id) init {
	self = [super init];
    if (self != nil) {
		asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
		config = [[Config alloc] init];
    }
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc");
    [statusItem release];
	[super dealloc];
}


- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
	NSLog(@"applicationDidFinishLaunching");
	
	NSError *err = nil;
	if (![asyncSocket connectToHost:SYNCHOST
							 onPort:SYNCPORT
							  error:&err]) {
		NSLog(@"Error: %@", err);
	}
	if ([config checkUserSettings] == NO) {
		[self actionSettings:nil];
	}
	//[self initStorages];
	[self buildMenu];
}

- (void) awakeFromNib {
	NSLog(@"awakeFromNib");
}

- (void) initStorages {
	NSLog(@"initStorages");
	
	fileStorage = [[FileStorage alloc] initWithConfig:config];
	[fileStorage addHook:@selector(onHook:) controller:self]; 
}

- (void) disposeStorages {
	NSLog(@"disposeStorages");
	
	[fileStorage dispose];
}

- (NSApplicationTerminateReply) applicationShouldTerminate: (NSApplication *) app {
	NSLog(@"applicationShouldTerminate");
	
	[asyncSocket disconnect];
	[self disposeStorages];
    return NSTerminateNow;
}


- (void) onHook: (NSMutableArray *) entities {
	int i = 1;
	for (id <EntityProtocol> entity in entities) {
		NSLog(@"onHook [%i]: %@", i, [entity toJSON]);
		i++;
	}
}


#pragma mark Sockets

- (BOOL) onSocketWillConnect: (AsyncSocket *) sock {
	// Connecting to a secure server
	NSMutableDictionary * settings = [NSMutableDictionary dictionaryWithCapacity:2];
	
	// Use the highest possible security
	[settings setObject:(NSString *) kCFStreamSocketSecurityLevelNegotiatedSSL
				 forKey:(NSString *) kCFStreamSSLLevel];
	
	// Allow self-signed certificates
	[settings setObject:[NSNumber numberWithBool:YES]
				 forKey:(NSString *) kCFStreamSSLAllowsAnyRoot];
	
	CFReadStreamSetProperty([sock getCFReadStream],
							kCFStreamPropertySSLSettings, (CFDictionaryRef) settings);
	CFWriteStreamSetProperty([sock getCFWriteStream],
							 kCFStreamPropertySSLSettings, (CFDictionaryRef) settings);
	return YES;
}

- (void) onSocket: (AsyncSocket *) sock didConnectToHost: (NSString *) host port: (UInt16) port {
	NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	NSDictionary *loginInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		@"login", @"call",
		[config getParamValue:@"User:email"], @"email",
		[config getParamValue:@"User:password"], @"password",
		@"MacDesktop", @"instance",
		@"as334ff9221bba", @"client_hash",
	nil];
	
	NSData *loginJSONData = [[[loginInfo yajl_JSONString] stringByAppendingString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"call:login %@", [loginInfo yajl_JSONString]);
	[asyncSocket writeData:loginJSONData withTimeout:-1 tag:0];
	
}

- (void) onSocket: (AsyncSocket *) sock didWriteDataWithTag: (long) tag {
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void) onSocketDidSecure: (AsyncSocket *) sock {
	NSLog(@"onSocketDidSecure:%p", sock);
}

- (void) onSocket: (AsyncSocket *) sock willDisconnectWithError: (NSError *) err {
	NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void) onSocketDidDisconnect: (AsyncSocket *) sock {
	NSLog(@"onSocketDidDisconnect:%p", sock);
	[self disposeStorages];
}

- (void) onSocket: (AsyncSocket *) sock didReadData: (NSData *) data withTag: (long) tag {
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if (msg) {
		NSLog(@"onSocket:didReadData %@", msg);
		NSDictionary *response = [msg yajl_JSON];

		NSString *responseCommand = [response objectForKey:@"command"];
		NSLog(@"responseCommand %@, %@", responseCommand, [responseCommand class]);
		if ([responseCommand isEqualToString:@"login"]) {
			NSLog(@"responseCommand == @login");
			if ([SyncServerActions actionLogin:[response objectForKey:@"session"]]) {
				[self initStorages];
			}
		} else if ([responseCommand isEqualToString:@"error"]) {
			NSLog(@"responseCommand == @error");
			[SyncServerActions actionError];
		} else {
			NSLog(@"responseCommand == ???");
		}


		
	}
}


#pragma mark System Menu

- (void) buildMenu {
	NSMenu *menu = [self createMenu];
	
	statusItem = [[[NSStatusBar systemStatusBar]
				   statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setHighlightMode:YES];
	[statusItem setTitle:[NSString stringWithFormat:@"%C",0x2295]]; 
	[statusItem setEnabled:YES];
	[statusItem setToolTip:@"SyncAnyApp"];
	[statusItem setMenu:menu];

	[menu release];
}

- (NSMenu *) createMenu {
	NSZone *menuZone = [NSMenu menuZone];
	NSMenu *menu = [[NSMenu allocWithZone:menuZone] init];
	NSMenuItem *menuItem;
	
	menuItem = [menu addItemWithTitle:@"Launch Website"
							   action:@selector(actionWebsite:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	
	menuItem = [menu addItemWithTitle:@"Open SyncAny Folder"
							   action:@selector(actionOpenWorkFolder:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	
	menuItem = [menu addItemWithTitle:@"Settings..." action:@selector(actionSettings:) keyEquivalent:@""];
	[menuItem setTarget:self];

	[menu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [menu addItemWithTitle:@"Quit"
							   action:@selector(actionQuit:)
						keyEquivalent:@""];
	
	[menuItem setTarget:self];
	return menu;
}


#pragma mark Actions

- (IBAction) clickEcho: (id) sender {
	NSLog(@"Button clicked");
	NSData *wData = [@"EHLO SERVER" dataUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"%@", wData);
	[txtLog insertText:@"Send: EHLO SERVER"];
	[txtLog insertNewline:nil];
	[asyncSocket writeData:wData withTimeout:-1 tag:0];
}

- (void) actionWebsite: (id) sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.google.com/"]];
}

- (void) actionOpenWorkFolder: (id) sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[config getParamValue:@"User:folder"]]];
}

- (void) actionSettings: (id) sender {
	[txtEmail setStringValue:[config getParamValue:@"User:email"]];
	[txtPassword setStringValue:[config getParamValue:@"User:password"]];
	
	[txtWorkFolder setStringValue:[config getParamValue:@"User:folder"]];
	
	[wSettings makeKeyAndOrderFront:nil];
}

- (void) closeSettings: (id) sender {
	[wSettings orderOut:nil];
}

- (void) saveSettings: (id) sender {
	[config setParamValue:[txtEmail stringValue] forKey:@"User:email"];
	[config setParamValue:[txtPassword stringValue] forKey:@"User:password"];
	
	NSString *oldUserFolder = [config getParamValue:@"User:folder"];
	if (![oldUserFolder isEqualToString:[txtWorkFolder stringValue]]) {
		[config setParamValue:[txtWorkFolder stringValue] forKey:@"User:folder"];
		[fileStorage changeWorkFolder:[txtWorkFolder stringValue]];
	}
	
	[wSettings orderOut:nil];
}

- (void) setFolder: (id) sender {
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setCanCreateDirectories:YES];
	[openDlg setCanChooseDirectories:YES];
	[openDlg setCanChooseFiles:NO];
	[openDlg setAllowsMultipleSelection:NO];
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
		NSArray* urls = [openDlg URLs];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [urls objectAtIndex:0]]];
		[txtWorkFolder setStringValue:[url path]];
	}
}

- (void) actionQuit: (id) sender {
	[NSApp terminate:sender];
}

@end
