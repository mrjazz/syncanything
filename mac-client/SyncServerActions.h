//
//  SyncServerActions.h
//  SyncAnyApp
//
//  Created by Corbie on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SyncServerActions : NSObject {

}

+ (BOOL) actionLogin: (NSString *) session;
+ (void) actionError;

@end
