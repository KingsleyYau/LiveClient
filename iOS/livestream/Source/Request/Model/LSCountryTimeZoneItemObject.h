//
//  LSCountryTimeZoneItemObject.h
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSTimeZoneItemObject.h"

@interface LSCountryTimeZoneItemObject : NSObject
{

}
/**
 * 国家时区结构体
 * countryCode              国家码(AL)
 * countryName             国家名称(Albania)
 * isDefault                    是否默认选中(1)
 * timeZoneList             时区列表
 */
@property (nonatomic, copy) NSString* countryCode;
@property (nonatomic, copy) NSString* countryName;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, strong) NSMutableArray<LSTimeZoneItemObject *>* timeZoneList;
@end
