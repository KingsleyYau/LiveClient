//
//  LSMainOpenURLManager.h
//  livestream
//
//  Created by Calvin on 2019/8/9.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMainViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface LSMainOpenURLManager : NSObject

 

@property (nonatomic,weak) LSMainViewController * mainVC;

- (void)removeMainVC;
@end

NS_ASSUME_NONNULL_END
