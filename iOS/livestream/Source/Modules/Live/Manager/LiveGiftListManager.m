//
//  LiveGiftListManager.m
//  livestream
//
//  Created by randy on 2017/8/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveGiftListManager.h"
#import "GetLiveRoomGiftListByUserIdRequest.h"

@interface LiveGiftListManager ()

/** 接口管理器 **/
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@end

@implementation LiveGiftListManager

+ (instancetype)liveGiftListManager{
    
    static LiveGiftListManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LiveGiftListManager alloc] init];
        manager.liveGiftArray = [[NSMutableArray alloc] init];
        manager.showGiftArray = [[NSMutableArray alloc] init];
    });
    
    return manager;
}

- (void)requestTheLiveGiftListWithRoomID:(NSString *)roomId callBack:(RequestFinshtBlock)back{
    
    GetLiveRoomGiftListByUserIdRequest *request = [[GetLiveRoomGiftListByUserIdRequest alloc] init];
    request.roomId = roomId;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<NSString *> * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"PlayViewController::sendGetGiftListRequest( "
                  "[发送获取礼物列表请求结果], "
                  "roomId : %@, "
                  "success : %s, "
                  "errnum : %ld, "
                  "errmsg : %@ "
                  "array : %@ "
                  ")",
                  roomId,
                  success?"true":"false",
                  (long)errnum,
                  errmsg,
                  array
                  );
            
            back(success, [NSMutableArray arrayWithArray:array]);
            
        });
    };
    [self.sessionManager sendRequest:request];
}

@end
