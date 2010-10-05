//
//  FileEntity.h
//  SyncAnyApp
//
//  Created by Corbie on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CommonCrypto/CommonDigest.h>
#import "EntityProtocol.h"


@interface FileEntity : NSObject <EntityProtocol> {

	NSString *workFolder;
	NSString *file;
	NSDictionary *fileInfo;
	
}

@property (retain) NSString *file;
@property (retain) NSDictionary *fileInfo;

- (id) initWithInfo: (NSDictionary *) _fileInfo forFile: (NSString *) _file isRemoved: (BOOL) isRemoved workFolder: (NSString *) path;
- (void) setWorkFolder: (NSString *) path;
- (void) setInfo: (NSDictionary *) _fileInfo forFile: (NSString *) _file isRemoved: (BOOL) isRemoved;
- (NSString *) getMD5Checksum: (NSString *) path;

@end
