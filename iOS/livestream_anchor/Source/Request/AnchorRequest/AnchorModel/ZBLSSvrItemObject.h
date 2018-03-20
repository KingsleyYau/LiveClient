//
//  ZBLSSvrItemObject
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ZBLSSvrItemObject : NSObject
/**
 * 流媒体服务器
 * svrId       流媒体服务器ID
 * tUrl        流媒体服务器测速url
 */
@property (nonatomic, copy) NSString* _Nonnull svrId;
@property (nonatomic, copy) NSString* _Nonnull tUrl;

@end
