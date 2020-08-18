//
//  LSPremiumVideoTypeItemObject
//  dating
//
//  Created by Alex on 20/08/03.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LSPremiumVideoTypeItemObject : NSObject
/**
 * 付费视频分类结构体
 * typeId               分类ID
 * typeName        分类名称
 * typeName        是否默认选中
 */
@property (nonatomic, copy) NSString* typeId;
@property (nonatomic, copy) NSString* typeName;
@property (nonatomic, assign) BOOL isDefault;

@end
