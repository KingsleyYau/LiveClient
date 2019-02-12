//
//  LIveChatSendPhotoItem.h
//  dating
//
//  Created by lance on 16/7/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LIveChatSendPhotoItem : NSObject
/** 私密照id */
@property (nonatomic,strong) NSString *photoId;
/** 发送者Id */
@property (nonatomic,strong) NSString *sendId;
@end
