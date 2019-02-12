//
//  EmotionTagItemObject.h
//  dating
//
//  Created by alex on 16/9/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmotionTagItemObject : NSObject

/** 终端使用标志 */
@property (nonatomic, assign) NSInteger toflag;
/** 分类ID */
@property (nonatomic, strong) NSString *typeId;
/** tagID */
@property (nonatomic, strong) NSString *tagId;
/** tag名称 */
@property (nonatomic, strong) NSString *tagName;



//初始化
- (EmotionTagItemObject *)init;


@end
