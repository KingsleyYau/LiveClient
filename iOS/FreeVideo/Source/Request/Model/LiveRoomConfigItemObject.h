//
//  LiveRoomConfigItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LiveRoomConfigItemObject : NSObject
/* IM服务器ip或域名 */
@property (nonatomic, strong) NSString* imSvr_ip;
/* IM服务器端口 */
@property (nonatomic, assign) int imSvr_port;
/* http服务器ip或域名 */
@property (nonatomic, strong) NSString* httpSvr_ip;
/* http服务器端口 */
@property (nonatomic, assign) int httpSvr_port;
/* 上传图片服务器ip或域名 */
@property (nonatomic, strong) NSString* uploadSvr_ip;
/* 上传图片服务器或端口 */
@property (nonatomic, assign) int uploadSvr_port;
@end
