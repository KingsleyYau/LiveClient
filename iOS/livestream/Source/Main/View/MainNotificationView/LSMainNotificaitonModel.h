//
//  LSMainNotificaitonModel.h
//  livestream
//
//  Created by Calvin on 2019/1/17.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MsgStatus_Chat = 0,
    MsgStatus_Hangout
} MsgType;

@interface LSMainNotificaitonModel : NSObject

@property (nonatomic, copy) NSString * notifiID;
@property (nonatomic, copy) NSString * userId;
@property (nonatomic, copy) NSString * photoUrl;
@property (nonatomic, copy) NSString * friendUrl;
@property (nonatomic, copy) NSString * userName;
@property (nonatomic, copy) NSString * contentStr;
@property (nonatomic, assign) MsgType msgType;
@property (nonatomic, assign) NSInteger createTime;
@end


 
