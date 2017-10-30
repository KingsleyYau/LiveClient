//
//  LiveRoomTextField.h
//  livestream
//
//  Created by randy on 2017/8/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSChatEmotion.h"
#import "LSChatTextAttachment.h"

@interface LiveRoomTextField : LSBLTextField

@property (strong) NSString * _Nullable fullText;

/**
 *   生成富文本,用以显示表情
 *
 *  @param emotion 表情模型
 */
- (void)insertEmotion:(LSChatEmotion* _Nonnull)emotion;

@end
