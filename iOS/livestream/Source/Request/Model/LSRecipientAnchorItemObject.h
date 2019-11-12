//
//  LSRecipientAnchorItemObject.h
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSRecipientAnchorItemObject : NSObject
{

}
/**
 * Recipient主播列表结构体
 * anchorId             主播ID
 * anchorNickName       主播昵称
 * anchorAvatarImg      主播头像
 * anchorAge            主播年龄
 */
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, copy) NSString* anchorNickName;
@property (nonatomic, copy) NSString* anchorAvatarImg;
@property (nonatomic, assign) int anchorAge;
@end
