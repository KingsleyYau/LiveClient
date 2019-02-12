//
//  MagicIconTypeItemObject.h
//  dating
//
//  Created by alex on 16/9/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MagicIconTypeItemObject : NSObject

/** 分类ID */
@property (nonatomic, strong) NSString *typeId;
/** 分类名称 */
@property (nonatomic, strong) NSString *typeTitle;

//初始化
- (MagicIconTypeItemObject *)init;


@end