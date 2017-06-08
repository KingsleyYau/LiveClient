//
//  NSURL+File.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "NSURL+FileAttribute.h"
#import <sys/xattr.h>

@implementation NSURL(FileAttribute)
- (BOOL)addSkipBackupAttribute {
    BOOL success = YES;
    NSString *crrSysVer = [[UIDevice currentDevice] systemVersion];
    if(NSOrderedDescending == [crrSysVer compare:@"5"]) {
        // TODO:IOS 5.0 or later
        if(NSOrderedSame == [crrSysVer compare:@"5.0"]) {
            // TODO:IOS 5.0
        }
        else if(NSOrderedSame == [crrSysVer compare:@"5.0.1"]) {
            // TODO:IOS 5.0.1
            assert([[NSFileManager defaultManager] fileExistsAtPath: [self path]]);
            const char* filePath = [[self path] fileSystemRepresentation];
            const char* attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            success = (result == 0)?YES:NO;
        }
        else if(NSOrderedAscending != [crrSysVer compare:@"5.1"]){
            // TODO:IOS 5.1 or later
            assert([[NSFileManager defaultManager] fileExistsAtPath: [self path]]);
            NSError *error = nil;
            success = [self setResourceValue: [NSNumber numberWithBool: YES]
                                          forKey: NSURLIsExcludedFromBackupKey error: &error];
        }
    }
    return success;
}
@end
