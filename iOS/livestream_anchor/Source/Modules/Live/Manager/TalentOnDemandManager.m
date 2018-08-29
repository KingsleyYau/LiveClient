//
//  TalentOnDemandManager.m
//  livestream
//
//  Created by Calvin on 17/9/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TalentOnDemandManager.h"

@interface TalentOnDemandManager ()

@end

@implementation TalentOnDemandManager

+ (instancetype)manager{
    
    static TalentOnDemandManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TalentOnDemandManager alloc] init];
        
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
   
    }
    return self;
}



@end
