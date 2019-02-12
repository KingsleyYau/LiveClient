//
//  ChatSmallGradeEmotion.h
//  dating
//
//  Created by test on 16/11/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSLCLiveChatMagicIconItemObject.h"
#import "LSLCMagicIconItemObject.h"

@interface QNChatSmallGradeEmotion : NSObject


/**
 图片
 */
@property (nonatomic, readonly) UIImage* image;


/** 基本内容 */
@property (nonatomic,strong) LSLCLiveChatMagicIconItemObject *liveChatMagicIconItemObject;
/** 基本属性 */
@property (nonatomic,strong) LSLCMagicIconItemObject *magicIconItemObject;

@end
