//
//  LSChatEmotionManager.h
//  livestream
//
//  Created by randy on 2017/8/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSChatTextAttachment.h"
#import "ChatEmotionItem.h"
#import "ChatEmotionListItem.h"

@class LSChatEmotionManager;
@protocol LSChatEmotionManagerDelegate <NSObject>

- (void)downLoadStanListFinshHandle:(NSInteger)index;

- (void)downLoadAdvanListFinshHandle:(NSInteger)index;

@end

@interface LSChatEmotionManager : NSObject

/** 单例实例 */
+ (instancetype)emotionManager;

/** 普通表情列表 */
@property (nonatomic, retain) NSMutableArray *stanEmotionList;
/** 私密表情列表 */
@property (nonatomic, retain) NSMutableArray *advanEmotionList;
/** 表情标识数组 */
@property (nonatomic, retain) NSMutableArray *imageNameArray;

/** 表情列表(用于查找) */
@property (nonatomic, retain) NSMutableDictionary *emotionDict;

/** 表情Item */
@property (nonatomic, retain) ChatEmotionListItem *stanListItem;
@property (nonatomic, retain) ChatEmotionListItem *advanListItem;


@property (nonatomic, weak) id<LSChatEmotionManagerDelegate> delegate;

/** 加载普通表情 */
- (void)reloadEmotion;

/**
 *  解析消息表情和文本消息 弹幕使用
 *
 *  @param text 普通文本消息
 *  @param font        字体
 *  @return 表情富文本消息
 */
- (NSMutableAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font;


/**
 输入表情替换成转义符 聊天列表使用

 @param text 输入文字
 @param font 字体大小
 @return 拼接表情文字
 */
- (NSMutableAttributedString *)parseMessageAttributedTextEmotion:(NSMutableAttributedString *)text font:(UIFont *)font;

@end
