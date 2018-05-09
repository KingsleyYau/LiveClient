
//
//  IMAnchorUserInfoItemObject.h
//  livestream
//
//  Created by Max on 2018/4/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMAnchorUserInfoItemObject : NSObject

/**
 * 观众信息信息
 * @riderId            座驾ID
 * @riderName          座驾名称
 * @riderUrl           座驾图片url
 * @honorImg           勋章图片url
 */
@property (nonatomic, copy) NSString *_Nonnull riderId;
@property (nonatomic, copy) NSString *_Nonnull riderName;
@property (nonatomic, copy) NSString *_Nonnull riderUrl;
@property (nonatomic, copy) NSString *_Nonnull honorImg;
@end
