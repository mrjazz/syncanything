//
//  SyncServerActions.m
//  SyncAnyApp
//
//  Created by Corbie on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncServerActions.h"


@implementation SyncServerActions

+ (BOOL) actionLogin: (NSString *) session {
	if (session == nil) {
		return NO;
	}
	return YES;
}

+ (void) actionError {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Error!"];
	[alert setInformativeText:@"You must open file previously."];
	[alert setAlertStyle: NSCriticalAlertStyle];
	[alert runModal];
	[alert release];
}

@end
