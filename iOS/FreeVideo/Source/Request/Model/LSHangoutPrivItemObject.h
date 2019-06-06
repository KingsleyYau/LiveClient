//
//  LSHangoutPrivItemObject.h
//  dating
//
//  Created by Alex on 19/3/19.
//  Copyright © 20179年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  Hangout权限相关
 *  isHangoutPriv       Hangout总权限（NO：禁止，YES：正常，默认：YES）
 */
@interface LSHangoutPrivItemObject : NSObject
@property (nonatomic, assign) BOOL isHangoutPriv;

@end
