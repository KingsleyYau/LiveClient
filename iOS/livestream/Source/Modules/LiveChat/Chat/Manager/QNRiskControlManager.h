//
//  RiskControlManager.h
//  dating
//
//  Created by Calvin on 2017/11/8.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RiskType_Ladyprofile = 0,
    RiskType_livechat
}RiskType;

@interface QNRiskControlManager : NSObject

+ (instancetype _Nonnull)manager;

@property (nonatomic, assign) RiskType type;

- (BOOL)isRiskControlType:(RiskType)type withController:(UIViewController *_Nullable)vc;
@end
