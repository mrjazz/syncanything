//
//  StorageProtocol.h
//  SyncAnyApp
//
//  Created by Corbie on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



@protocol StorageProtocol

- (void) dispose;

- (void) addHook: (SEL) _hook controller: (NSObject *) controller;

@end
