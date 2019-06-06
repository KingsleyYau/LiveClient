//
//  LSOrderProductItemObject
//  dating
//
//  Created by Alex on 18/9/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSProductItemObject.h"
@interface LSOrderProductItemObject : NSObject
/**
 * 买点信息
 * list             产品列表
 * desc             描述
 * more             详情描述
 * title            主标题
 * subTitle         副标题
 */
@property (nonatomic, strong) NSMutableArray<LSProductItemObject *>* _Nonnull list;
@property (nonatomic, copy) NSString* _Nonnull desc;
@property (nonatomic, copy) NSString* _Nonnull more;
@property (nonatomic, copy) NSString* _Nonnull title;
@property (nonatomic, copy) NSString* _Nonnull subTitle;

@end
