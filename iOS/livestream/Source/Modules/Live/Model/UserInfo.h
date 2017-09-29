//
//  UserInfo.h
//  livestream
//
//  Created by Max on 2017/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetNewFansBaseInfoItemObject.h"

@interface UserInfo : NSObject
@property (strong) NSString *userId;
@property (strong, readonly) NSString *photoUrl;
@property (strong) GetNewFansBaseInfoItemObject *item;
@end
