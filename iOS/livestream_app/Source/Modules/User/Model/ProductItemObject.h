//
//  ProductItemObject.h
//  livestream
//
//  Created by test on 2017/12/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductItemObject : NSObject
/** 产品的ID */
@property (nonatomic,copy) NSString *productId;
/** 产品的名称 */
@property (nonatomic,copy) NSString *name;
/** 产品的价格 */
@property (nonatomic,copy) NSString *price;
@end
