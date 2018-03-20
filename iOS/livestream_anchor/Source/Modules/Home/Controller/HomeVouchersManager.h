//
//  HomeVouchersManager.h
//  livestream
//
//  Created by Calvin on 2018/1/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
@interface HomeVouchersManager : NSObject

+ (instancetype)manager;


- (void)getVouchersData;

- (BOOL)isShowFreeLive:(NSString *)userId LiveRoomType:(HttpRoomType)type;
@end
