//
//  LSIMLoginManager.h
//  livestream
//
//  Created by Calvin on 2018/11/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LSIMLoginManagerDelegate <NSObject>
@optional

@end

@interface LSIMLoginManager : NSObject <ILoginService>

/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

/**
 *  增加监听器
 *
 *  @param delegate 监听器
 */
- (void)addDelegate:(id<LSIMLoginManagerDelegate> _Nonnull)delegate;

/**
 *  移除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<LSIMLoginManagerDelegate> _Nonnull)delegate;


@property (nonatomic, assign, readonly) LoginStatus status;
@end

NS_ASSUME_NONNULL_END
