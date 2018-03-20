//
//  ChatEmotionItem.h
//  livestream
//
//  Created by randy on 2017/8/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatEmotionItem : NSObject

/* 表情ID */
@property (nonatomic, copy) NSString* emoId;
/* 表情文本标记 */
@property (nonatomic, copy) NSString* emoSign;
/* 表情图片url */
@property (nonatomic, copy) NSString* emoUrl;
/* 表情icon图片url，用于移动端在表情列表显示 */
@property (nonatomic, copy) NSString* emoIconUrl;

@end
