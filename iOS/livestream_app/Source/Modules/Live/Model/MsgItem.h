//
//  MsgItem.h
//  livestream
//
//  Created by Max on 2017/5/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYText.h>

typedef enum MsgType {
    MsgType_Chat,
    MsgType_Gift,
    MsgType_Announce,
    MsgType_Link,
    MsgType_Share,
    MsgType_Join,
    MsgType_RiderJoin,
    MsgType_Follow,
    MsgType_Warning
} MsgType;

@interface MsgItem : NSObject

@property (assign) MsgType type;
@property (assign) NSInteger level;
@property (strong) NSString* name;
@property (strong) NSString *giftName;
@property (strong) NSString* text;
@property (strong) NSMutableAttributedString* attText;
@property (nonatomic, strong) YYTextLayout *layout;
@property (strong) NSString *smallImgUrl;
@property (nonatomic, assign) int giftNum;
@property (strong) NSString *linkStr;
@property (strong) NSString *riderName;
@property (strong) NSString *honorUrl;

@end
