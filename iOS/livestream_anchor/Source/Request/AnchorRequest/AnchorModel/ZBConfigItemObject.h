//
//  ZBConfigItemObject.h
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBLSSvrItemObject.h"

@interface ZBConfigItemObject : NSObject
/**
 * 同步配置结构体
 * imSvrUrl                   IM服务器ip或域名
 * httpSvrUrl                 http服务器ip或域名
 * mePageUrl                  播个人中心页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
 * manPageUrl                 男士资料页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
 * showDetailPage             节目详情页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
 * minAavilableVer            App最低可用的内部版本号（整型）
 * minAvailableMsg            App强制升级提示
 * newestVer                  App最新的内部版本号（整型）
 * newestMsg                  App普通升级提示
 * downloadAppUrl             下载App的url
 * svrList                    流媒体服务器ID
 */
@property (nonatomic, copy) NSString *_Nonnull imSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull httpSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull mePageUrl;
@property (nonatomic, copy) NSString *_Nonnull manPageUrl;
@property (nonatomic, copy) NSString *_Nonnull showDetailPage;
@property (nonatomic, assign) int minAavilableVer;
@property (nonatomic, copy) NSString *_Nonnull minAvailableMsg;
@property (nonatomic, assign) int newestVer;
@property (nonatomic, copy) NSString *_Nonnull newestMsg;
@property (nonatomic, copy) NSString *_Nonnull downloadAppUrl;
@property (nonatomic, strong) NSMutableArray<ZBLSSvrItemObject *>* _Nullable svrList;

@end
