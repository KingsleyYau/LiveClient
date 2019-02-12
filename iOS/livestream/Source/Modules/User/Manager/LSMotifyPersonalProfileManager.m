//
//  MotifyPersonalProfileManager.m
//  dating
//
//  Created by lance on 16/8/3.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSMotifyPersonalProfileManager.h"
#import "LSPersonalProfileItemObject.h"
#import "LSGetMyProfileRequest.h"
#import "LSStartEditResumeRequest.h"
#import "LSUpdateProfileRequest.h"

@interface LSMotifyPersonalProfileManager ()

/** 任务管理 */
@property (nonatomic,strong) LSDomainSessionRequestManager *sessionManager;

/** 个人信息 */
@property (nonatomic,strong) LSPersonalProfileItemObject *personalItem;
@end


static LSMotifyPersonalProfileManager *gManager = nil;
@implementation LSMotifyPersonalProfileManager

+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        self.personalItem = nil;
        self.sessionManager = [LSDomainSessionRequestManager manager];
    }
    return self;
}



- (void)motifyPersonalResume:(NSString *)resume {
    [self getPersonalProfileResume:resume];

}


- (BOOL)getPersonalProfileResume:(NSString *)resume{
    LSGetMyProfileRequest *request = [[LSGetMyProfileRequest alloc] init];
    request.finishHandler = ^(BOOL success,  HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSPersonalProfileItemObject * _Nullable userInfoItem){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                
                NSLog(@"LSMotifyPersonalProfileManager::getPersonalProfile( 获取男士详情成功 )");
                self.personalItem = userInfoItem;
                [self startEditResume:resume];
                
            }else{
                if (self.delegate &&[self.delegate respondsToSelector:@selector(lsMotifyPersonalProfileResult:result:)]) {
                    [self.delegate lsMotifyPersonalProfileResult:self result:NO];
                }
            }
        });
    };
    return [self.sessionManager sendRequest:request];
}


- (BOOL)startEditResume:(NSString * _Nullable)resume {

    LSStartEditResumeRequest *request = [[LSStartEditResumeRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{

            if (success) {
                NSLog(@"LSMotifyPersonalProfileManager::startEditResume( 开始计时成功 )");
                // 开始上传个人详情
                [self updateProfile:resume];

            } else {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(lsMotifyPersonalProfileResult:result:)]) {
                    [self.delegate lsMotifyPersonalProfileResult:self result:NO];
                }
            }
        });
    };

    return [self.sessionManager sendRequest:request];
}

- (BOOL)updateProfile:(NSString * _Nullable)resume{
    LSUpdateProfileRequest *request = [[LSUpdateProfileRequest alloc] init];
    request.resume = resume;
    request.height = self.personalItem.height;
    request.weight = self.personalItem.weight;
    request.smoke = self.personalItem.smoke;
    request.drink = self.personalItem.drink;
    request.religion = self.personalItem.religion;
    request.education = self.personalItem.education;
    request.profession = self.personalItem.profession;
    request.ethnicity = self.personalItem.ethnicity;
    request.income = self.personalItem.income;
    request.children = self.personalItem.children;
    request.interests = self.personalItem.interests;
    request.zodiac = self.personalItem.zodiac;
    request.finishHandler  = ^(BOOL success,  HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, BOOL isModify){
        dispatch_async(dispatch_get_main_queue(), ^{

            if( success ) {
                NSLog(@"MotifyPersonalProfileManager::updateProfile( 更新男士详情成功 )");
                if( !isModify ) {
                    if (self.delegate &&[self.delegate respondsToSelector:@selector(lsMotifyPersonalProfileResult:result:)]) {
                        [self.delegate lsMotifyPersonalProfileResult:self result:NO];
                    }
                    
                }else {
                    if (self.delegate &&[self.delegate respondsToSelector:@selector(lsMotifyPersonalProfileResult:result:)]) {
                        [self.delegate lsMotifyPersonalProfileResult:self result:YES];
                    }
                }

            } else {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(lsMotifyPersonalProfileResult:result:)]) {
                    [self.delegate lsMotifyPersonalProfileResult:self result:NO];
                }
            }
            
        });
        
    };
    
    return [self.sessionManager sendRequest:request];
}

@end
