//
//  Config.h
//  SyncAnyApp
//
//  Created by Corbie on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const SYNCHOST;
extern NSInteger const SYNCPORT;
extern NSString * const FILEHOST;
extern NSInteger const FILEPORT;

@interface Config : NSObject {

}

- (id) getParamValue: (NSString *) param;
- (void) setParamValue: (id) value forKey: (NSString *) key;
- (void) registerDefaults;
- (BOOL) checkUserSettings;

@end
