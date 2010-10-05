//
//  Config.m
//  SyncAnyApp
//
//  Created by Corbie on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Config.h"


@implementation Config

NSString * const SYNCHOST = @"localhost";
NSInteger const SYNCPORT = 8000;
NSString * const FILEHOST = @"localhost";
NSInteger const FILEPORT = 8001;

- (id) init {
	self = [super init];
    if (self != nil) {
        [self registerDefaults];
    }    
	return self;
}

- (void) registerDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary
		dictionaryWithObjects:
			[NSArray arrayWithObjects:
			 @"",
			 @"",
			 @"",
			 nil]
		forKeys:
			[NSArray arrayWithObjects:
			 @"User:email",
			 @"User:password",
			 @"User:folder",
			 nil]
	];
	[defaults registerDefaults: appDefaults];
}

- (id) getParamValue: (NSString *) param {
	return [[NSUserDefaults standardUserDefaults] objectForKey:param];
}

- (void) setParamValue: (id) value forKey: (NSString *) key {
	NSLog(@"setParamValue: forKey:%s", [key UTF8String]);
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:value forKey:key];
	[defaults synchronize];
}

- (BOOL) checkUserSettings {
	if ([[NSString stringWithFormat:@"%@", [self getParamValue:@"User:email"]] length] == 0) {
		return NO;
	}
	if ([[NSString stringWithFormat:@"%@", [self getParamValue:@"User:password"]] length] == 0) {
		return NO;
	}
	if ([[NSString stringWithFormat:@"%@", [self getParamValue:@"User:folder"]] length] == 0) {
		return NO;
	}
	return YES;
}


@end
