//
//  LSSayHiThemeItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 主题列表
 * themeId         主题ID
 * themeName       主题名称
 * smallImg        小图
 * bigImg          大图
 */
@interface LSSayHiThemeItemObject : NSObject
@property (nonatomic, assign) int themeId;
@property (nonatomic, copy) NSString *themeName;
@property (nonatomic, copy) NSString *smallImg;
@property (nonatomic, copy) NSString *bigImg;


@end
