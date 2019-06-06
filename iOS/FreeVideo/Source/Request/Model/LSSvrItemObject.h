//
//  LSSvrItemObject
//  dating
//
//  Created by Alex on 17/10/13.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LSSvrItemObject : NSObject
/**
 * 流媒体服务器
 * svrId       流媒体服务器ID
 * tUrl        流媒体服务器测速url
 */
@property (nonatomic, copy) NSString* _Nonnull svrId;
@property (nonatomic, copy) NSString* _Nonnull tUrl;

@end
