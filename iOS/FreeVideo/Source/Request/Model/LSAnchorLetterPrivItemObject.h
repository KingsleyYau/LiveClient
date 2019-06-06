//
//  LSAnchorLetterPrivItemObject.h
//  dating
//
//  Created by Alex on 17/9/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  主播信件权限相关
 *  userCanSend       男士是否有发信权限
 *  anchorCanSend     主播是否有发送及接收信件权限
 */
@interface LSAnchorLetterPrivItemObject : NSObject
@property (nonatomic, assign) BOOL userCanSend;
@property (nonatomic, assign) BOOL anchorCanSend;

@end
