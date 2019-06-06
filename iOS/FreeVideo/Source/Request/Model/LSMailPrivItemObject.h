//
//  LSMailPrivItemObject.h
//  dating
//
//  Created by Alex on 17/9/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSUserSendMailPrivItemObject.h"
/**
 *  信件及意向信权限相关
 *  userSendMailPriv       是否有权限发送信件
 *  userSendMailImgPriv    发送照片相关
 */
@interface LSMailPrivItemObject : NSObject
@property (nonatomic, assign) BOOL userSendMailPriv;
@property (nonatomic, strong) LSUserSendMailPrivItemObject* userSendMailImgPriv;

@end
