//
//  LoginItemObject.h
//  dating
//
//  Created by Alex on 17/5/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginItemObject : NSObject
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* nickName;
@property (nonatomic, assign) int level;
@property (nonatomic, strong) NSString* country;
@property (nonatomic, strong) NSString* photoUrl;
@property (nonatomic, strong) NSString* sign;
@property (nonatomic, assign) BOOL anchor;
@property (nonatomic, assign) BOOL modifyinfo;
@end
