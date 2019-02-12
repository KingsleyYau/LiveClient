//
//  EMFAdmirerItemObject.h
//  dating
//
//  Created by test on 17/5/9.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftItemObject : NSObject

/** 礼物id */
@property (nonatomic,copy) NSString *vgid;
/** 标题 */
@property (nonatomic,copy) NSString *title;
/** 点数 */
@property (nonatomic,copy) NSString *price;


- (GiftItemObject *)init;

@end
