//
//  LSChatMessageObject.m
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSChatMessageObject.h"

@implementation LSChatMessageObject

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.emotionArray = [[NSArray alloc]init];
    }
    return self;
}

- (void)chatMessageHaveEmotionWithString:(NSString *)string {
    
    if ( self.emotionArray ) {
        
        for ( LSChatEmotion *emotion in self.emotionArray ) {
            
            if ([string containsString: emotion.text]) {
                
                NSLog(@"LSChatMessageObject: string %@",emotion.text);
                
            }
        }
    }
}

@end
