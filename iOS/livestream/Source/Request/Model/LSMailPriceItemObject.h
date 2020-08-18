//
//  LSMailPriceItemObject.h
//  dating
//
//  Created by Alex on 20/08/05.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSMailPriceItemObject : NSObject
/**
 * 信件价格结构体
 * creditPrice             所需的信用点
 * stampPrice           所需的邮票
 */

@property (nonatomic, assign) double creditPrice;
@property (nonatomic, assign) double stampPrice;


@end
