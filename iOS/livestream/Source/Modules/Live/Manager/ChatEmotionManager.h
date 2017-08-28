//
//  ChatEmotionManager.h
//  livestream
//
//  Created by randy on 2017/8/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatTextAttachment.h"
#import "ChatEmotionItem.h"
#import "ChatEmotionListItem.h"

@interface ChatEmotionManager : NSObject

/** 单例实例 */
+ (instancetype)emotionManager;

/** 表情列表 */
@property (nonatomic, retain) NSArray *emotionArray;

@property (nonatomic, retain) NSArray *imageNameArray;

/** 表情列表(用于查找) */
@property (nonatomic, retain) NSDictionary *emotionDict;

@property (nonatomic, retain) ChatEmotionListItem *stanListItem;

@property (nonatomic, retain) ChatEmotionListItem *advanListItem;



/** 请求表情列表 */
- (void)sendRequestEmotionList;

/** 获取表情列表 */
- (void)getTheEmotionListWithUserID:(NSString *)userID;

/** 失败重新下载 */
- (void)againDownloadTheEmotion;

/** 发送带表情消息 */
- (void)sendTheEmotionMessage:(NSString *)userID iconID:(NSString *)iconID;

/** 加载普通表情 */
- (void)reloadEmotion;

/**
 *  解析消息表情和文本消息
 *
 *  @param text 普通文本消息
 *  @param font        字体
 *  @return 表情富文本消息
 */

- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font;

- (NSAttributedString *)parseMessageAttributedTextEmotion:(NSMutableAttributedString *)text font:(UIFont *)font;

@end
