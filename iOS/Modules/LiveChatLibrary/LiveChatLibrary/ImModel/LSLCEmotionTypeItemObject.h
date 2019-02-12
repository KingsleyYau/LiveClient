//
//  LSLCEmotionTypeItemObject.h
//  dating
//
//  Created by alex on 16/9/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLCEmotionTypeItemObject : NSObject

/** 终端使用标志 */
@property (nonatomic, assign) NSInteger toflag;
/** 分类ID */
@property (nonatomic, strong) NSString *typeId;
/** 分类名称 */
@property (nonatomic, strong) NSString *typeName;

//初始化
- (LSLCEmotionTypeItemObject *)init;


@end
