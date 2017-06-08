//
//  ChatEmotion.m
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatEmotion.h"

@implementation ChatEmotion
- (id)init {
    if( self = [super init] ) {
        self.text = @"";
        self.image = nil;
    }
    return self;
}

- (id)initWithTextImage:(NSString*)text image:(UIImage*)image {
    if( self = [super init] ) {
        self.text = text;
        self.image = image;
    }
    return self;
}

@end
