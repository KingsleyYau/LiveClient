//
//  LSChatTextAttachment.m
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSChatTextAttachment.h"

@implementation LSChatTextAttachment
- (id)init {
    if( self = [super init] ) {
        self.url = nil;
        self.text = nil;
    }
    return self;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    return [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
//    return CGRectMake(0, 0, lineFrag.size.height, lineFrag.size.height);
}

@end
