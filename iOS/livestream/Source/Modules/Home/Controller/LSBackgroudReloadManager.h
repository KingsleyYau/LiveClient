//
//  LSBackgroudReloadManager.h
//  livestream
//
//  Created by Calvin on 2018/8/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LSBackgroudReloadManagerDelegate <NSObject>
- (void)WillEnterForegroundReloadData;
@end

@interface LSBackgroudReloadManager : NSObject

@property (nonatomic, weak) id<LSBackgroudReloadManagerDelegate> delegate;
+ (instancetype)manager;

//进入前台
- (void)willEnterForeground;

//进入后台
- (void)didEnterBackground;
@end
