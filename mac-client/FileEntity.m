//
//  FileEntity.m
//  SyncAnyApp
//
//  Created by Corbie on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileEntity.h"

@implementation FileEntity

@synthesize file, fileInfo;

- (void) setWorkFolder: (NSString *) path {
	NSLog(@"FileEntity::setWorkFolder");
	workFolder = path;
}

- (id) initWithInfo: (NSDictionary *) _fileInfo forFile: (NSString *) _file isRemoved: (BOOL) isRemoved workFolder: (NSString *) path {
	NSLog(@"FileEntity::initWithInfo");
	self = [super init];
    if (self != nil) {
		[self setWorkFolder:path];
		[self setInfo:_fileInfo forFile:_file isRemoved:isRemoved];
    }
	return self;
}

- (void) setInfo: (NSDictionary *) _fileInfo forFile: (NSString *) _file isRemoved: (BOOL) isRemoved {
	file = _file;
	
	NSString *isFolder = @"false";
	if ([_fileInfo valueForKey:@"NSFileType"] == NSFileTypeDirectory) {
		isFolder = @"true";
	}
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	 [@"files:" stringByAppendingString:file], @"path",
	 isFolder, @"folder",
	 isRemoved ? @"true" : @"false", @"removed",
	 isRemoved ? @"0" : [_fileInfo valueForKey:@"NSFileSize"], @"size",
	 isRemoved ? [dateFormat stringFromDate:[NSDate date]] : [dateFormat stringFromDate:[_fileInfo valueForKey:@"NSFileModificationDate"]], @"modified",
	 !isRemoved && isFolder == @"false" ? [self getMD5Checksum:_file] : @"", @"hash",
	 nil];
	[dateFormat release];
	[isFolder release];
}

- (NSString *) toJSON {
	//NSLog(@"FileEntity:toJSON: %@", [fileInfo yajl_JSONString]);
	return [fileInfo yajl_JSONString];
}

- (NSString *) getMD5Checksum: (NSString *) path {
	NSData *fileContent = [NSData dataWithContentsOfFile:[workFolder stringByAppendingString:path]];
	const char *cStr = [fileContent bytes];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStr, [fileContent length], result);
	[fileContent release];
	
	return [NSString stringWithFormat:
		@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
		result[0], result[1],
		result[2], result[3],
		result[4], result[5],
		result[6], result[7],
		result[8], result[9],
		result[10], result[11],
		result[12], result[13],
		result[14], result[15]
	];
}

@end
