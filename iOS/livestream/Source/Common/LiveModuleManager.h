//
//  LiveModuleManager.h
//  livestream
//
//  Created by randy on 2017/8/3.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"
#import "FileCacheManager.h"
#import "LoginManager.h"
#import "IMManager.h"
#import "LiveGiftDownloadManager.h"
#import "FirebaseCore/FIRApp.h"

@interface LiveModuleManager : NSObject

@property (nonatomic, strong)LoginManager *loginManager;

@property (nonatomic, strong)IMManager *imManager;

@property (nonatomic, strong)LiveGiftDownloadManager *giftDownloadManager;

+ (instancetype)createLiveManager;

+ (void)setLiveRequestManager;

+ (void)liveLoginToPhone:(NSString *)phone password:(NSString *)password areano:(NSString *)areano;

+ (void)pushToLivestreamWithController:(UIViewController *)controller;

@end
