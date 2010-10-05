//
//  AppController.h
//  SyncAnyApp
//
//  Created by Corbie on 9/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AsyncSocket, Config, FileStorage, SyncServerActions;


@interface AppController : NSObject {
	
	Config *config;
	AsyncSocket *asyncSocket;
	SyncServerActions *syncServerActions;
	
	NSStatusItem *statusItem;
	
	IBOutlet NSWindow *wSettings;
	IBOutlet NSTextView *txtLog;
	IBOutlet NSTextField *txtEmail;
	IBOutlet NSSecureTextField * txtPassword;
	
	IBOutlet NSTextField *txtWorkFolder;
	
	FileStorage *fileStorage;

}

- (void) initStorages;
- (void) disposeStorages;
- (void) buildMenu;

- (NSMenu *) createMenu;

- (void) actionSettings: (id) sender;
- (IBAction) closeSettings: (id) sender;
- (IBAction) saveSettings: (id) sender;
- (IBAction) setFolder: (id) sender;


- (IBAction) clickEcho: (id) sender;

@end
