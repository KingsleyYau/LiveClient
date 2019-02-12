//
//  LSLCCookiesItemObject.h
//  dating
//
//  Created by alex on 16/9/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LSLCCookiesItemObject : NSObject

/** cookies的域 */
@property (nonatomic,strong) NSString *domain;
/** cookies是否接受其他web */
@property (nonatomic,strong) NSString *accessOtherWeb;
/** cookies的符号 */
@property (nonatomic,strong) NSString *symbol;
/** 是否发送 */
@property (nonatomic,strong) NSString *isSend;
/** cookies的过期时间 */
@property (nonatomic,strong) NSString *expiresTime;
/** cookies的名字 */
@property (nonatomic,strong) NSString *cName;
/** cookies的值*/
@property (nonatomic,strong) NSString *value;

//初始化
- (LSLCCookiesItemObject *)init;


@end
