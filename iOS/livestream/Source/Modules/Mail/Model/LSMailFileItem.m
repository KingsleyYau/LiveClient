//
//  LSMailFileItem.m
//  livestream
//
//  Created by Calvin on 2018/12/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMailFileItem.h"

@implementation LSMailFileItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fileId = @"";
        self.fileName = @"";
        self.filePath = @"";
        self.msg = @"";
        self.url = @"";
        self.type = FileType_Photo;
        self.uploadStatus = UploadStatus_uploading;
    }
    return self;
}
@end
