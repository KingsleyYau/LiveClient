//
//  LSOrderProductItemObject
//  dating
//
//  Created by Alex on 17/12/23.
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
 */
@property (nonatomic, strong) NSMutableArray<LSProductItemObject *>* _Nonnull list;
@property (nonatomic, copy) NSString* _Nonnull desc;
@property (nonatomic, copy) NSString* _Nonnull more;

@end
