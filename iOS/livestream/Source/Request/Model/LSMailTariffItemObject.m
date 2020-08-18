//
//  LSMailTariffItemObject.m
//  dating
//
//  Created by Alex on 20/08/05.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSMailTariffItemObject.h"
@interface LSMailTariffItemObject () <NSCoding>
@end


@implementation LSMailTariffItemObject

- (id)init {
    if( self = [super init] ) {
        self.mailSendBase = NULL;
        self.mailReadBase = NULL;
        self.mailPhotoAttachBase = NULL;
        self.mailPhotoBuyBase = NULL;
        self.mailVideoBuyBase = NULL;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.mailSendBase = [coder decodeObjectForKey:@"mailSendBase"];
        self.mailReadBase = [coder decodeObjectForKey:@"mailReadBase"];
        self.mailPhotoAttachBase = [coder decodeObjectForKey:@"mailPhotoAttachBase"];
        self.mailPhotoBuyBase = [coder decodeObjectForKey:@"mailPhotoBuyBase"];
        self.mailVideoBuyBase = [coder decodeObjectForKey:@"mailVideoBuyBase"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.mailSendBase forKey:@"mailSendBase"];
    [coder encodeObject:self.mailReadBase forKey:@"mailReadBase"];
    [coder encodeObject:self.mailPhotoAttachBase forKey:@"mailPhotoAttachBase"];
    [coder encodeObject:self.mailPhotoBuyBase forKey:@"mailPhotoBuyBase"];
    [coder encodeObject:self.mailVideoBuyBase forKey:@"mailVideoBuyBase"];

}

@end
