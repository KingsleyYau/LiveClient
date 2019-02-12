//
//  LiveChatEmotionItemObject.h
//  dating
//
//  Created by alex on 16/9/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveChatEmotionItemObject : NSObject

/** 高级表情ID */
@property (nonatomic,strong) NSString *emotionId;
/** 缩略图路径 */
@property (nonatomic,strong) NSString *imagePath;
/** 播放大图路径 */
@property (nonatomic,strong) NSString *playBigPath;
/** 播放大图路径数组 */
@property (nonatomic,strong) NSMutableArray *playBigImages;

//初始化
- (LiveChatEmotionItemObject *)init;


@end
