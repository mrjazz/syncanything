//
//  FileStorage.h
//  SyncAnyApp
//
//  Created by Corbie on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCEventListenerProtocol.h"
#import "StorageProtocol.h"

@class Config, FileEntity;

@interface FileStorage : NSObject <SCEventListenerProtocol, StorageProtocol> {
	
	SEL hook;
	NSObject *appController;
	Config *config;

	NSFileManager *fm;
	NSString *workFolder;
	NSMutableDictionary	*savedStructure;
	NSMutableDictionary *currentStructure;

}

- (id) initWithConfig: (id) _config;

- (void) changeWorkFolder: (NSString *) path;
- (void) setupEventListener;
- (void) registerDefaults;
- (void) buildDiff;
- (void) dispatchHook: (NSMutableArray *) entities;
- (FileEntity *) onFileModified: (NSString *) file withInfo: (NSDictionary *) fileInfo;
- (FileEntity *) onFileRemoved: (NSString *) file withInfo: (NSDictionary *) fileInfo;

- (NSDictionary *) getFileInfo: (NSString *) path;

@end
