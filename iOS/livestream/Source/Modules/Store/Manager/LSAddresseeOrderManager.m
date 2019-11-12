//
//  LSAddresseeOrderManager.m
//  livestream
//
//  Created by Randy_Fan on 2019/10/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSAddresseeOrderManager.h"
#import "LSSessionRequestManager.h"
#import "LiveModule.h"

#import "GetContactListRequest.h"
#import "GetAnchorListRequest.h"

#import "LSAddCartGiftRequest.h"

@interface LSAddresseeOrderManager ()

@property (nonatomic, strong) NSMutableArray<LSAddresseeItem *> *itemArray;

@property (nonatomic, strong) LSSessionRequestManager *sessionRequest;

@end

@implementation LSAddresseeOrderManager

- (void)removeAddressee {
    [self.itemArray removeAllObjects];
}

+ (instancetype)manager {
    static LSAddresseeOrderManager *manager = nil;
    if (manager == nil) {
        manager = [[LSAddresseeOrderManager alloc] init];
    }
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.itemArray = [[NSMutableArray alloc] init];
        self.sessionRequest = [LSSessionRequestManager manager];
    }
    return self;
}

- (void)getAddresseeList:(GetAddresseeFinshtHandler)finish {
    if (self.itemArray.count > 5) {
        finish(YES, self.itemArray, @"");
    } else {
        [self getContactList:finish];
    }
}

- (void)getContactList:(GetAddresseeFinshtHandler)finish {
    GetContactListRequest *request = [[GetContactListRequest alloc] init];
    request.start = 0;
    request.step = 6;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSRecommendAnchorItemObject *> *array, int totalCount) {
        NSLog(@"LSAddresseeOrderManager::getContactList([获取最近联系人列表] success : %@, errnum : %d, errmsg : %@, totalCount : %d)",BOOL2SUCCESS(success), errnum, errmsg, totalCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.itemArray removeAllObjects];
            if (success) {
                for (int index = 0; index < array.count; index++) {
                    LSRecommendAnchorItemObject *model = array[index];
                    LSAddresseeItem *item = [[LSAddresseeItem alloc] init];
                    item.anchorId = model.anchorId;
                    item.anchorName = model.anchorNickName;
                    item.anchorHeadUrl = model.anchorAvatar;
                    item.anchorCoverUrl = model.anchorCover;
                    [self.itemArray addObject:item];
                    if (index == 5) {
                        break;
                    }
                }
                if (self.itemArray.count > 5) {
                    NSLog(@"[获取最近联系人列表 FinshtHandler] success : %@, arrayCount : %d",BOOL2SUCCESS(success), (int)self.itemArray.count);
                    finish(success , self.itemArray, errmsg);
                } else {
                    [self getAnchorList:finish];
                }
            } else {
                [self getAnchorList:finish];
            }
        });
    };
    [self.sessionRequest sendRequest:request];
}

- (void)getAnchorList:(GetAddresseeFinshtHandler)finish {
    GetAnchorListRequest *request = [[GetAnchorListRequest alloc] init];
    request.start = 0;
    request.step = 0;
    request.isForTest = [LiveModule module].test;
    request.hasWatch = NO;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LiveRoomInfoItemObject *> *array) {
        NSLog(@"LSAddresseeOrderManager::getAnchorList([获取Hot列表] success : %@, errnum : %d, errmsg : %@, totalCount : %d", BOOL2SUCCESS(success), errnum, errmsg, (int)array.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                for (LiveRoomInfoItemObject *infoItem in array) {
                    BOOL isContent = NO;
                    for (LSAddresseeItem *item in self.itemArray) {
                        if ([infoItem.userId isEqualToString:item.anchorId]) {
                            isContent = YES;
                        }
                    }
                    if (!isContent) {
                        LSAddresseeItem *addreItem = [[LSAddresseeItem alloc] init];
                        addreItem.anchorId = infoItem.userId;
                        addreItem.anchorName = infoItem.nickName;
                        addreItem.anchorHeadUrl = infoItem.photoUrl;
                        addreItem.anchorCoverUrl = infoItem.roomPhotoUrl;
                        [self.itemArray addObject:addreItem];
                        if (self.itemArray.count > 5) {
                            break;
                        }
                    }
                }
                NSLog(@"[获取Hot列表 FinshtHandler] success : %@, arrayCount : %d",BOOL2SUCCESS(success), (int)self.itemArray.count);
                finish(success, self.itemArray, errmsg);
                
            } else {
                BOOL have = self.itemArray.count > 0 ? YES : NO;
                finish(have, self.itemArray, errmsg);
                NSLog(@"[获取Hot列表 FinshtHandler] success : %@, arrayCount : %d",BOOL2SUCCESS(have), (int)self.itemArray.count);
            }
        });
    };
    [self.sessionRequest sendRequest:request];
}

- (void)addCartGift:(NSString *)giftId anchorId:(NSString *)anchorId finish:(AddCartGiftFinshtHandler)finish {
    LSAddCartGiftRequest *request = [[LSAddCartGiftRequest alloc] init];
    request.anchorId = anchorId;
    request.giftId = giftId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        NSLog(@"LSAddresseeOrderManager::addCartGift[添加鲜花礼物进购物车] success : %@, errnum : %d, errmsg : %@", BOOL2SUCCESS(success), errnum, errmsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            finish(success, errnum, errmsg);
        });
    };
    [self.sessionRequest sendRequest:request];
}

@end
