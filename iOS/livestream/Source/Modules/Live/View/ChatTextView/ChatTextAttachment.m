//
//  ChatTextAttachment.m
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatTextAttachment.h"

@implementation ChatTextAttachment
- (id)init {
    if( self = [super init] ) {
        self.url = nil;
        self.text = nil;
    }
    return self;
}
@end
