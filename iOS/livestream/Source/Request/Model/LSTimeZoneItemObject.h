//
//  LSTimeZoneItemObject.h
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSTimeZoneItemObject : NSObject
{

}
/**
 * 时区结构体
 * zoneId              时区ID(2)
 * value              时区差值(+01:00)
 * city                  城市(Tirane)
 * cityCode                  城市码(CET)
 * summerTimeStart       夏令时开始时间(1584576000)
 * summerTimeEnd       夏令时结束时间(1593558000)
 */
@property (nonatomic, copy) NSString* zoneId;
@property (nonatomic, copy) NSString* value;
@property (nonatomic, copy) NSString* city;
@property (nonatomic, copy) NSString* cityCode;
@property (nonatomic, assign) NSInteger summerTimeStart;
@property (nonatomic, assign) NSInteger summerTimeEnd;
@end
