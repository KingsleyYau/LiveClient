//
//  LSValidSiteIdItemObject
//  dating
//
//  Created by Alex on 18/9/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
@interface LSValidSiteIdItemObject : NSObject
/**
 * 可登录的站点
 * siteId          网站ID
 * isLive          是否直播站点
 */
@property (nonatomic, assign) HTTP_OTHER_SITE_TYPE siteId;
@property (nonatomic, assign) BOOL isLive;

@end
