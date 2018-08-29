//
//  HomeVouchersManager.h
//  livestream
//
//  Created by Calvin on 2018/1/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//  试聊券接口管理器

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
#import "LSGetVoucherAvailableInfoRequest.h"
@interface HomeVouchersManager : NSObject

@property (nonatomic, strong) LSVoucherAvailableInfoItemObject * item;

+ (instancetype)manager;

- (void)getVouchersData:(GetVoucherAvailableInfoFinishHandler)finishHandler;

- (BOOL)isShowFreeLive:(NSString *)userId LiveRoomType:(HttpRoomType)type;
@end
