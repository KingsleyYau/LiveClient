//
//  ChatEmotionListItem.h
//  livestream
//
//  Created by randy on 2017/8/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatEmotionItem.h"

@interface ChatEmotionListItem : NSObject

@property (nonatomic, assign) int emo_type;

@property (nonatomic, strong) NSArray<ChatEmotionItem *> *chatList;

@end
