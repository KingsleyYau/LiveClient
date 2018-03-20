//
//  ChatEmotionListItem.h
//  livestream
//
//  Created by randy on 2017/8/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatEmotionItem.h"
#import "EmoticonInfoItemObject.h"

@interface ChatEmotionListItem : NSObject

@property (nonatomic, assign) EmoticonType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *errMsg;
@property (nonatomic, copy) NSString *emoUrl;
@property (nonatomic, strong) NSMutableArray<ChatEmotionItem *> *emoList;

@end
