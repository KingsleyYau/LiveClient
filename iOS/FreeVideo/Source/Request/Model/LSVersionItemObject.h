//
//  LSVersionItemObject
//  dating
//
//  Created by Alex on 18/9/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LSVersionItemObject : NSObject
/**
 * 更新版本信息
 * versionCode            最新的客户端内部版本号
 * versionName            客户端显示本号
 * versionDesc            客户端描述
 * isForceUpdate            是否强制升级（1：是，0：否）
 * url                    客户端安装包下载URL
 * storeUrl                Store URL，客户端使用系统浏览器打开
 * pubTime                客户端发布时间
 * checkTime                检测更新时间（Unix Timestamp）
 */
@property (nonatomic, assign) int versionCode;
@property (nonatomic, copy) NSString* _Nonnull versionName;
@property (nonatomic, copy) NSString* _Nonnull versionDesc;
@property (nonatomic, assign) BOOL isForceUpdate;
@property (nonatomic, copy) NSString* _Nonnull url;
@property (nonatomic, copy) NSString* _Nonnull storeUrl;
@property (nonatomic, copy) NSString* _Nonnull pubTime;
@property (nonatomic, assign) NSInteger checkTime;

@end
