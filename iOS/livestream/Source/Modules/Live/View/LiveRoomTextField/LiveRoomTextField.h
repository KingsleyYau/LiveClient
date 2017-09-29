//
//  LiveRoomTextField.h
//  livestream
//
//  Created by randy on 2017/8/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BLTextField.h"
#import "ChatEmotion.h"
#import "ChatTextAttachment.h"

@interface LiveRoomTextField : BLTextField

@property (strong) NSString *fullText;

/**
 *   生成富文本,用以显示表情
 *
 *  @param emotion 表情模型
 */
- (void)insertEmotion:(ChatEmotion* _Nonnull)emotion;

@end
