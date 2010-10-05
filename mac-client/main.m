//
//  main.m
//  SyncAnyApp
//
//  Created by Corbie on 9/14/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <YAJL/YAJL.h>

#include <IOKit/IOKitLib.h>

void CopySerialNumber(CFStringRef *serialNumber)
{
	if (serialNumber != NULL) {
		*serialNumber = NULL;
		
		io_service_t    platformExpert =
		IOServiceGetMatchingService(kIOMasterPortDefault,
									
									IOServiceMatching("IOPlatformExpertDevice"));
		
		if (platformExpert) {
			CFTypeRef serialNumberAsCFString =
			IORegistryEntryCreateCFProperty(platformExpert,
											CFSTR(kIOPlatformSerialNumberKey),
											kCFAllocatorDefault, 0);
			if (serialNumberAsCFString) {
				*serialNumber = serialNumberAsCFString;
			}
			
			IOObjectRelease(platformExpert);
		}
	}
	
} 

int main(int argc, char *argv[])
{
	CFStringRef myStringRef;
	CopySerialNumber(&myStringRef);
	NSLog(@"%@", myStringRef);
	
	
	//[alert beginSheetModalForWindow:[searchField window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
//	NSString *j = @"{\"path\": \"files:test/folder/1\"}";
//	NSArray *a = [NSArray arrayWithObject:j];
//	NSLog(@"%@", [a yajl_JSONStringWithOptions:YAJLGenOptionsBeautify indentString:@"    "]);
//	exit(0);
	
	
	
	return NSApplicationMain(argc,  (const char **) argv);
}

