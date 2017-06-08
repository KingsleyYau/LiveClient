//
//  IMManager.h
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImClientOC.h"

@interface IMManager : NSObject
@property (strong) ImClientOC* client;
#pragma mark - 获取实例
+ (instancetype)manager;
@end
