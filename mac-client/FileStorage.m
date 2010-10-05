//
//  FileStorage.m
//  SyncAnyApp
//
//  Created by Corbie on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileStorage.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "FileEntity.h"
#import "Config.h"


@implementation FileStorage


# pragma mark File Events

- (id) initWithConfig: (id) _config {
	config = _config;
	workFolder = [config getParamValue:@"User:folder"];
	return [self init];
}

- (void) dispose {
	SCEvents *events = [SCEvents sharedPathWatcher];
    [events stopWatchingPaths];
	[config setParamValue:currentStructure forKey:@"FileStorage:structure"];
	[fm release];
}

- (void) addHook: (SEL) _hook controller: (NSObject *) controller {
	NSLog(@"addHook");
	hook = _hook;
	appController = controller;
	fm = [[NSFileManager alloc] init];
	[self registerDefaults];
	savedStructure = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"FileStorage:structure"] mutableCopy];
	[self buildDiff];
	[self setupEventListener];
}

- (void) changeWorkFolder: (NSString *) path {
	workFolder = path;
	SCEvents *events = [SCEvents sharedPathWatcher];
    [events stopWatchingPaths];
	savedStructure = [[NSMutableDictionary alloc] init];
	[self buildDiff];
	[self setupEventListener];
}

- (void) registerDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary
		dictionaryWithObjects:
			[NSArray arrayWithObjects:
			 [NSMutableDictionary new],
			 nil]
		forKeys:
			[NSArray arrayWithObjects:
			 @"FileStorage:structure",
			 nil]
	];
	[defaults registerDefaults: appDefaults];
}

- (void) buildDiff {
	NSLog(@"FileStorage:buildDiff");
	
	NSMutableArray *entities = [[NSMutableArray alloc] init];
	NSArray *content = [fm subpathsOfDirectoryAtPath:workFolder error:nil];
	currentStructure = [[NSMutableDictionary alloc] initWithCapacity:[content count]];
	for (NSString* node in content) {
		NSString *file = [NSString stringWithFormat:@"%@/%@", workFolder, node];
		NSDictionary *savedFileInfo = [savedStructure objectForKey:node];
		NSDictionary *fileInfo = [self getFileInfo:file];
		
		[currentStructure setObject:fileInfo forKey:node];
		
		if (savedFileInfo == nil) { // new entity
			NSLog(@"(buildDiff) New file entity: %@", node);
			//[self onFileModified:watchFile withInfo:fileInfo];
			[entities addObject:[self onFileModified:node withInfo:fileInfo]];
		} else if ([savedFileInfo isEqualToDictionary:fileInfo] == NO) { // existed entity modified
			NSLog(@"(buildDiff) Existed entity modified: %@", node);
			//[self onFileModified:watchFile withInfo:fileInfo];
			[entities addObject:[self onFileModified:node withInfo:fileInfo]];
		}
	}
	for (NSString *node in [savedStructure allKeys]) {
		if (![content containsObject:node]) {
			NSLog(@"(buildDiff) Entity deleted: %@", node);
			//[self onFileRemoved:node withInfo:[currentStructure objectForKey:node]];
			[entities addObject:[self onFileRemoved:node withInfo:[savedStructure objectForKey:node]]];
		}
	}
	[self dispatchHook:entities];
	[entities release];
	//NSLog(@"currentStructure:: %@", [currentStructure allKeys]);
}

/**
 * Sets up the event listener using SCEvents and sets its delegate to this controller.
 * The event stream is started by calling startWatchingPaths: while passing the paths
 * to be watched.
 */
- (void) setupEventListener {
    SCEvents *events = [SCEvents sharedPathWatcher];
    [events setDelegate:self];
    
	NSMutableArray *paths = [NSMutableArray arrayWithObject:workFolder];
    //NSMutableArray *excludePaths = [NSMutableArray arrayWithObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"]];
    
	//[events setExcludedPaths:excludePaths];
	[events startWatchingPaths:paths];
}

- (void) pathWatcher: (SCEvents *) pathWatcher eventOccurred: (SCEvent *) event {
	NSLog(@"pathWatcher: %@", event.eventPath);
	
	NSMutableArray *entities = [[NSMutableArray alloc] init];
	NSString *watchFile;
	NSString *watchPath = @"";
	if ([event.eventPath isEqualToString:workFolder] == NO) {
		watchPath = [event.eventPath substringFromIndex:[workFolder length] + 1];
	}

	NSArray *content = [fm subpathsOfDirectoryAtPath:event.eventPath error:nil];
	
	for (NSString *node in content) {
		if ([watchPath isEqualToString:@""]) {
			watchFile = node;
		} else {
			watchFile = [NSString stringWithFormat:@"%@/%@", watchPath, node];
		}
		
		NSString *file = [NSString stringWithFormat:@"%@/%@", event.eventPath, node];
		NSDictionary *savedFileInfo = [currentStructure objectForKey:watchFile];
		NSDictionary *fileInfo = [self getFileInfo:file];
		if (savedFileInfo == nil) { // new entity
			NSLog(@"(pathWatcher) New file entity: %@", watchFile);
			[currentStructure setObject:fileInfo forKey:watchFile];
			[entities addObject:[self onFileModified:watchFile withInfo:fileInfo]];
		} else if ([savedFileInfo isEqualToDictionary:fileInfo] == NO) { // existed entity modified
			NSLog(@"(pathWatcher) Existed entity modified: %@", watchFile);
			[currentStructure setObject:fileInfo forKey:watchFile];
			[entities addObject:[self onFileModified:watchFile withInfo:fileInfo]];
		}
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", [NSString stringWithFormat:@"%@*", watchPath]];
	NSArray *structureFolders = [[currentStructure allKeys] filteredArrayUsingPredicate:predicate];
	
	for (NSString *node in structureFolders) {
		watchFile = node;
		if (![watchPath isEqualToString:@""] && ![node isEqualToString:watchPath]) {
			watchFile = [node substringFromIndex:[watchPath length] + 1];
		}
		if (![content containsObject:watchFile] && ![watchFile isEqualToString:watchPath]) {
			NSLog(@"(pathWatcher) Entity deleted: %@", node);
			[currentStructure removeObjectForKey:node];
			[entities addObject:[self onFileRemoved:node withInfo:[currentStructure objectForKey:node]]];
		}
	}
	
	[self dispatchHook:entities];
	[entities release];
}

- (FileEntity *) onFileModified: (NSString *) file withInfo: (NSDictionary *) fileInfo {
	return [[FileEntity alloc] initWithInfo:fileInfo forFile:file isRemoved:NO workFolder:workFolder];
}

- (FileEntity *) onFileRemoved: (NSString *) file withInfo: (NSDictionary *) fileInfo {
	return [[FileEntity alloc] initWithInfo:nil forFile:file isRemoved:YES workFolder:workFolder];
}

- (void) dispatchHook: (NSMutableArray *) entities {
	NSLog(@"dispatchHook");
	[appController performSelector:hook withObject:entities];
}

- (NSDictionary *) getFileInfo: (NSString *) path {
	return [fm attributesOfItemAtPath:path error:nil];
}

@end
