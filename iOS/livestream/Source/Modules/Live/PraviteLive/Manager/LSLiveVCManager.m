//
//  LSLiveVCManager.m
//  livestream
//
//  Created by Randy_Fan on 2020/3/25.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSLiveVCManager.h"

#import "LSCancelInviteHangoutRequest.h"
#import "LSSendinvitationHangoutRequest.h"
#import "LSGetHangoutInvitStatusRequest.h"
#import "LSAcceptScheduleInviteRequest.h"
#import "LSDeclinedScheduleInviteRequest.h"
#import "LSSendScheduleInviteRequest.h"

#import "LSScheduleInviteCell.h"
#import "LSScheduleStatusTipCell.h"

#define MessageFontSize 16
#define MessageFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:MessageFontSize]

@interface LSLiveVCManager()<IMLiveRoomManagerDelegate, IMManagerDelegate, LSPrePaidManagerDelegate>

@property (nonatomic, assign) NSInteger msgId;

@end

@implementation LSLiveVCManager

- (void)dealloc {
    // 移除直播间IM代理监听
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    self.paidManager.liveRoom = nil;
    [self.paidManager removeDelegate:self];
}

+ (instancetype)manager {
    LSLiveVCManager *manager = [[LSLiveVCManager alloc] init];
    return manager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        // 初始化IM管理器
        self.imManager = [LSImManager manager];
        [self.imManager addDelegate:self];
        [self.imManager.client addDelegate:self];
        
        // 初始登录
        self.loginManager = [LSLoginManager manager];
        
        // 初始化礼物管理器
        self.giftDownloadManager = [LSGiftManager manager];
        
        // 初始化用户信息管理器
        self.roomUserInfoManager = [LSRoomUserInfoManager manager];
        
        // 初始请求管理器
        self.sessionManager = [LSSessionRequestManager manager];
        
        // 初始化文字管理器
        self.msgManager = [[PraviteLiveMsgManager alloc] init];
        
        // 初始化表情管理器
        self.emotionManager = [LSChatEmotionManager emotionManager];
        
        // 初始化预付费管理器
        self.paidManager = [LSPrePaidManager manager];
        [self.paidManager addDelegate:self];
        
        // 消息Id
        self.msgId = -1;
    }
    return self;
}

- (void)setLiveRoom:(LiveRoom *)liveRoom {
    _liveRoom = liveRoom;
    self.paidManager.liveRoom = liveRoom;
}

#pragma mark - 发起多人互动邀请
- (void)sendHangoutInvite:(NSString *)recommendId recommendAnchorId:(NSString *)recommendAnchorId recommendAnchorName:(NSString *)recommendAnchorName {
    
    LSSendinvitationHangoutRequest *request = [[LSSendinvitationHangoutRequest alloc] init];
    request.roomId = self.liveRoom.roomId;
    request.anchorId = self.liveRoom.userId;
    request.recommendId = recommendId;
    request.isCreateOnly = YES;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *roomId, NSString *inviteId, int expire) {
        NSLog(@"LSVIPLiveViewController::sendHangoutInvite( [发起多人互动邀请], success : %@, errnum : %d, errmsg : %@, roomId : %@, inviteId : %@, expire : %d )",
        BOOL2SUCCESS(success), errnum, errmsg, roomId, inviteId, expire);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(onRecvInvitationHangout:errmsg:inviteId:recommendId:recommendAnchorId:recommendAnchorName:)]) {
                [self.delegate onRecvInvitationHangout:errnum errmsg:errmsg inviteId:inviteId recommendId:recommendId
                                     recommendAnchorId:recommendAnchorId recommendAnchorName:recommendAnchorName];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 取消多人互动邀请
- (void)sendCancelHangoutInvite:(NSString *)inviteId {
    LSCancelInviteHangoutRequest *request = [[LSCancelInviteHangoutRequest alloc] init];
    request.inviteId = inviteId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        NSLog(@"LSLiveVCManager::LSCancelInviteHangoutRequest( [取消多人互动邀请 %@] errnum : %d,"
              "errmsg : %@ )",success == YES ? @"成功":@"失败", errnum, errmsg);
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 查询Hangout邀请状态
- (void)getHangoutInviteStatu:(NSString *)inviteId {
    if (inviteId.length > 0) {
        LSGetHangoutInvitStatusRequest *request = [[LSGetHangoutInvitStatusRequest alloc] init];
        request.inviteId = inviteId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, HangoutInviteStatus status, NSString *roomId, int expire) {
            NSLog(@"LSLiveVCManager::getHangoutInviteStatu( [查询多人互动邀请状态] success : %@, errnum : %d, errmsg : %@,"
            "status : %d, roomId : %@, expire : %d )",BOOL2SUCCESS(success), errnum, errmsg, status, roomId, expire);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(onRecvGetHangoutInvitStatus:status:roomId:)]) {
                    [self.delegate onRecvGetHangoutInvitStatus:success status:status roomId:roomId];
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
}

#pragma mark - 发送预付费邀请
- (void)sendScheduleInviteToAnchor:(LSScheduleInviteItem *)inviteItem {
    self.paidManager.liveRoom = self.liveRoom;
    [self.paidManager sendScheduleInvite:inviteItem];
}

#pragma mark - 发送接收预付费邀请
- (void)sendAcceptScheduleInviteToAnchor:(NSString *)inviteId duration:(int)duration infoObj:(LSScheduleInviteItem *)infoObj {
    self.paidManager.liveRoom = self.liveRoom;
    [self.paidManager sendAcceptScheduleInvite:inviteId duration:duration infoObj:infoObj];
}

#pragma mark - 获取直播间预付费邀请列表
- (void)getScheduleList {
    self.paidManager.liveRoom = self.liveRoom;
    if (self.liveRoom.roomType == LiveRoomType_Public) {
        [self.paidManager getScheduleRequestsList:LSSCHEDULEINVITETYPE_PUBLICLIVE refId:self.liveRoom.roomId];
    } else if (self.liveRoom.roomType == LiveRoomType_Private) {
        [self.paidManager getScheduleRequestsList:LSSCHEDULEINVITETYPE_PRIVATELIVE refId:self.liveRoom.roomId];
    }
}

#pragma mark - 获取座驾信息
- (void)getDriveInfo:(NSString *)userId {
    [self.roomUserInfoManager getFansBaseInfo:userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MsgItem *msgItem;
            if (item.riderId.length > 0) {
                AudienceModel *model = [[AudienceModel alloc] init];
                model.userid = userId;
                model.nickname = item.nickName;
                model.photourl = item.photoUrl;
                model.riderid = item.riderId;
                model.riderurl = item.riderUrl;
                model.ridername = item.riderName;
                if ([self.delegate respondsToSelector:@selector(onRecvAudienceRideIn:)]) {
                    [self.delegate onRecvAudienceRideIn:model];
                }
                msgItem = [self addRiderJoinMessageNickName:item.nickName riderName:item.riderName fromId:userId];
            } else {
                msgItem = [self addJoinMessageNickName:item.nickName fromId:userId];
            }
            
            if ([self.delegate respondsToSelector:@selector(onRecvMessageListItem:)]) {
                [self.delegate onRecvMessageListItem:msgItem];
            }
        });
    }];
}

#pragma mark - 获取直播间观众信息
- (void)getLiveRoomUserInfo:(NSString *)userId {
    [self.roomUserInfoManager getFansBaseInfo:userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
        if ([self.delegate respondsToSelector:@selector(onRecvUserOrAnchorInfo:)]) {
            [self.delegate onRecvUserOrAnchorInfo:item];
        }
    }];
}

#pragma mark - 获取直播间主播信息
- (void)getLiveRoomAnchorInfo:(NSString *)userId {
    [self.roomUserInfoManager getLiverInfo:userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
        if ([self.delegate respondsToSelector:@selector(onRecvUserOrAnchorInfo:)]) {
            [self.delegate onRecvUserOrAnchorInfo:item];
        }
    }];
}

#pragma mark - 发送弹幕
- (void)sendRoomToast:(NSString *)text {
    [self.imManager sendToast:self.liveRoom.roomId nickName:self.loginManager.loginItem.nickName msg:text];
}

#pragma mark - 发送直播间消息
- (void)sendLiveRoomChat:(NSString *)text at:(NSArray<NSString *> *_Nullable)at {
    [self.imManager sendLiveChat:self.liveRoom.roomId nickName:self.loginManager.loginItem.nickName msg:text at:at];
}

#pragma mark - 开启双向视频
- (BOOL)sendVideoControl:(BOOL)start {
    IMControlType type = start ? IMCONTROLTYPE_START : IMCONTROLTYPE_CLOSE;
    BOOL bFlag = [self.imManager controlManPush:self.liveRoom.roomId control:type finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, NSArray<NSString *> *manPushUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(onRecvManPush:errmsg:isStart:manPushUrls:)]) {
                [self.delegate onRecvManPush:errType errmsg:errMsg isStart:start manPushUrls:manPushUrl];
            }
        });
    }];
    return bFlag;
}

#pragma mark - 接受礼物通知
- (void)onRecvSendGiftNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName giftId:(NSString *)giftId giftName:(NSString *)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(NSString *)honorUrl photoUrl:(NSString * _Nonnull)photoUrl {
    NSLog(@"LSLiveVCManager::onRecvRoomGiftNotice( [接收礼物], roomId : %@, fromId : %@, nickName : %@, giftId : %@, giftName : %@, giftNum : %d, honorUrl : %@ ,photoUrl : %@)", roomId, fromId, nickName, giftId, giftName, giftNum, honorUrl, photoUrl);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 判断本地是否有该礼物
        BOOL bHave = ([self.giftDownloadManager getGiftItemWithId:giftId] != nil);
        if (bHave) {
            // 连击起始数
            int starNum = multi_click_start - 1;
               
            // 接收礼物消息item
            GiftItem *giftItem = [GiftItem itemRoomId:roomId
                                              fromID:fromId
                                            nickName:nickName
                                                photoUrl:photoUrl
                                              giftID:giftId
                                            giftName:giftName
                                             giftNum:giftNum
                                         multi_click:multi_click
                                             starNum:starNum
                                              endNum:multi_click_end
                                             clickID:multi_click_id];
            // 插入送礼消息
            MsgItem *msgItem = [self addGiftMessageNickName:nickName giftID:giftId giftNum:giftNum fromId:fromId];
            
            if ([self.delegate respondsToSelector:@selector(onRecvSendGiftItem:)]) {
                [self.delegate onRecvSendGiftItem:giftItem];
            }
            
            if ([self.delegate respondsToSelector:@selector(onRecvMessageListItem:)]) {
                [self.delegate onRecvMessageListItem:msgItem];
            }
            
        } else {
            
        }
    });
}

#pragma mark - 接受弹幕通知
- (void)onRecvSendToastNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName msg:(NSString *)msg honorUrl:(NSString *)honorUrl avatarImg:(NSString *)avatarImg {
    NSLog(@"LSLiveVCManager::onRecvSendToastNotice( [接收直播间弹幕通知], roomId : %@, fromId : %@, nickName : %@, msg : %@ honorUrl : %@ avatarImg : %@)", roomId, fromId, nickName, msg, honorUrl, avatarImg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 插入弹幕消息
            MsgItem *msgItem = [self addChatMessageNickName:nickName text:msg fromId:fromId];
            
            // 插入到弹幕
            BarrageModel *bgItem = [BarrageModel barrageModelForName:nickName message:msg userId:fromId url:avatarImg];
            
            if ([self.delegate respondsToSelector:@selector(onRecvSendToastBarrage:)]) {
                [self.delegate onRecvSendToastBarrage:bgItem];
            }
            
            if ([self.delegate respondsToSelector:@selector(onRecvMessageListItem:)]) {
                [self.delegate onRecvMessageListItem:msgItem];
            }
        }
    });
}

#pragma mark - 直播间文本消息通知
- (void)onRecvSendChatNotice:(NSString *)roomId level:(int)level fromId:(NSString *)fromId nickName:(NSString *)nickName msg:(NSString *)msg honorUrl:(NSString *)honorUrl avatarImg:(NSString * _Nonnull)avatarImg {
    NSLog(@"LSLiveVCManager::onRecvSendChatNotice( [接收直播间文本消息通知], roomId : %@, nickName : %@, msg : %@, avatarImg : %@)", roomId, nickName, msg, avatarImg);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.imLiveRoom.roomId]) {
            // 插入聊天消息
            MsgItem *msgItem = [self addChatMessageNickName:nickName text:msg fromId:fromId];
            
            if ([self.delegate respondsToSelector:@selector(onRecvMessageListItem:)]) {
                [self.delegate onRecvMessageListItem:msgItem];
            }
        }
    });
}

#pragma mark - 接收直播间公告
- (void)onRecvSendSystemNotice:(NSString *)roomId msg:(NSString *)msg link:(NSString *)link type:(IMSystemType)type {
    NSLog(@"LSLiveVCManager::onRecvSendSystemNotice( [接收直播间公告消息], roomId : %@, msg : %@, link: %@ type:%d)", roomId, msg, link, type);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            MsgItem *msgItem = [[MsgItem alloc] init];
            msgItem.msgId = [self getMsgId];
            if (type == IMSYSTEMTYPE_COMMON) {
                if (link.length > 0) {
                    msgItem.msgType = MsgType_Link;
                    msgItem.linkStr = link;
                } else {
                    msgItem.msgType = MsgType_Announce;
                }
            } else {
                msgItem.msgType = MsgType_Warning;
            }
            msgItem.text = msg;
            NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
            msgItem.attText = attributeString;
            
            if ([self.delegate respondsToSelector:@selector(onRecvMessageListItem:)]) {
                [self.delegate onRecvMessageListItem:msgItem];
            }
        }
    });
}

#pragma mark - 观众进入直播间通知
- (void)onRecvEnterRoomNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl riderId:(NSString *)riderId riderName:(NSString *)riderName riderUrl:(NSString *)riderUrl fansNum:(int)fansNum honorImg:(NSString *)honorImg isHasTicket:(BOOL)isHasTicket {
    
    NSLog(@"LSLiveVCManager::onRecvFansRoomIn( [接收观众进入直播间], roomId : %@, userId : %@, nickName : %@, photoUrl : %@ )", roomId, userId, nickName, photoUrl);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.imLiveRoom.roomId]) {
            if (![userId isEqualToString:self.loginManager.loginItem.userId]) {
                
                MsgItem *msgItem;
                if (riderId.length) {
                    AudienceModel *model = [[AudienceModel alloc] init];
                    model.userid = userId;
                    model.nickname = nickName;
                    model.photourl = photoUrl;
                    model.riderid = riderId;
                    model.ridername = riderName;
                    model.riderurl = riderUrl;
                    if ([self.delegate respondsToSelector:@selector(onRecvAudienceRideIn:)]) {
                        [self.delegate onRecvAudienceRideIn:model];
                    }
                    msgItem = [self addRiderJoinMessageNickName:nickName riderName:riderName fromId:userId];
                } else {
                    msgItem = [self addJoinMessageNickName:nickName fromId:userId];
                }
                    
                if ([self.delegate respondsToSelector:@selector(onRecvMessageListItem:)]) {
                    [self.delegate onRecvMessageListItem:msgItem];
                }
            }
        }
    });
}

#pragma mark - 主播推荐好友通知
- (void)onRecvRecommendHangoutNotice:(IMRecommendHangoutItemObject *)item {
    NSLog(@"LSLiveVCManager::onRecvRecommendHangoutNotice( [接收主播推荐好友通知] roomId : %@, anchorID : %@,"
      "nickName : %@, recommendId : %@, photourl : %@ )", item.roomId, item.anchorId, item.nickName, item.recommendId, item.photoUrl);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([item.roomId isEqualToString:self.liveRoom.roomId]) {
            MsgItem *msgItem = [[MsgItem alloc] init];
            msgItem.msgId = [self getMsgId];
            msgItem.msgType = MsgType_Recommend;
            msgItem.sendName = item.nickName;
            msgItem.recommendItem = item;
            msgItem.text = [NSString stringWithFormat:NSLocalizedString(@"WOULD_LIKE_TO_HANGOUT",@"WOULD_LIKE_TO_HANGOUT"),item.nickName,item.friendNickName];
            
            if ([self.delegate respondsToSelector:@selector(onRecvMessageListItem:)]) {
                [self.delegate onRecvMessageListItem:msgItem];
            }
        }
    });
}

#pragma mark - 观众等级升级通知
- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"LSLiveVCManager::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.liveRoom.imLiveRoom.manLevel = level;
        
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Recv_Level_Up", @"Recv_Level_Up"), level];
        [self addTips:msg];
    });
}

#pragma mark - 观众亲密度升级通知
- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *)loveLevelItem {
    NSLog(@"LSLiveVCManager::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d, anchorId: %@, anchorName: %@  )", loveLevelItem.loveLevel, loveLevelItem.anchorId, loveLevelItem.anchorName);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.liveRoom.imLiveRoom.loveLevel = loveLevelItem.loveLevel;
        
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Recv_Love_Up", @"Recv_Love_Up"), self.liveRoom.userName, loveLevelItem.loveLevel];
        [self addTips:msg];
    });
}

// 插入普通聊天消息
- (MsgItem *)addChatMessageNickName:(NSString *)name text:(NSString *)text fromId:(NSString *)fromId {
    // 发送普通消息
    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.msgId = [self getMsgId];
    // 判断是谁发送
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Me;
        
    } else if ([fromId isEqualToString:self.liveRoom.userId]) {
        msgItem.usersType = UsersType_Liver;
        
    } else {
        msgItem.usersType = UsersType_Audience;
    }
    msgItem.msgType = MsgType_Chat;
    msgItem.sendName = name;
    msgItem.text = text;
    if (text.length > 0) {
        NSMutableAttributedString *attributeString = [self.msgManager setupChatMessageStyle:self.roomStyleItem msgItem:msgItem];
        msgItem.attText = [self.emotionManager parseMessageAttributedTextEmotion:attributeString font:MessageFont];
    }
    return msgItem;
}

// 插入送礼消息
- (MsgItem *)addGiftMessageNickName:(NSString *)nickName giftID:(NSString *)giftID giftNum:(int)giftNum fromId:(NSString *)fromId {
    
    LSGiftManagerItem *item = [[LSGiftManager manager] getGiftItemWithId:giftID];
    
    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.msgId = [self getMsgId];
    // 判断是谁发送
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Me;
        
    } else if ([fromId isEqualToString:self.liveRoom.userId]) {
        msgItem.usersType = UsersType_Liver;
        
    } else {
        msgItem.usersType = UsersType_Audience;
    }
    msgItem.msgType = MsgType_Gift;
    msgItem.giftType = item.infoItem.type;
    msgItem.sendName = nickName;
    msgItem.giftName = item.infoItem.name;
    
    LSGiftManagerItem *giftItem = [[LSGiftManager manager] getGiftItemWithId:giftID];
    msgItem.smallImgUrl = giftItem.infoItem.smallImgUrl;
    
    msgItem.giftNum = giftNum;
    // 增加文本消息
    NSMutableAttributedString *attributeString = [self.msgManager setupGiftMessageStyle:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = attributeString;
    return msgItem;
}

// 插入普通入场消息
- (MsgItem *)addJoinMessageNickName:(NSString *)nickName fromId:(NSString *)fromId {
    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.msgId = [self getMsgId];
    // 判断是谁
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Me;
        
    } else if ([fromId isEqualToString:self.liveRoom.userId]) {
        msgItem.usersType = UsersType_Liver;
        
    } else {
        msgItem.usersType = UsersType_Audience;
    }
    msgItem.msgType = MsgType_Join;
    msgItem.sendName = nickName;
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = attributeString;
    return msgItem;
}

// 插入座驾入场消息
- (MsgItem *)addRiderJoinMessageNickName:(NSString *)nickName riderName:(NSString *)riderName fromId:(NSString *)fromId {
    
    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.msgId = [self getMsgId];
    // 判断是谁
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Me;
        
    } else if ([fromId isEqualToString:self.liveRoom.userId]) {
        msgItem.usersType = UsersType_Liver;
        
    } else {
        msgItem.usersType = UsersType_Audience;
    }
    msgItem.msgType = MsgType_RiderJoin;
    msgItem.sendName = nickName;
    msgItem.riderName = riderName;
    NSMutableAttributedString *riderString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = riderString;
    return msgItem;
}

// 插入公告提示语
- (void)addTips:(NSString *)text {
    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.msgId = [self getMsgId];
    msgItem.text = text;
    msgItem.msgType = MsgType_Announce;
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = attributeString;
    
    if ([self.delegate respondsToSelector:@selector(onRecvMessageListItem:)]) {
        [self.delegate onRecvMessageListItem:msgItem];
    }
}

// 插入试聊卷提示
- (void)addVouchTipsToList {
    if (self.liveRoom.imLiveRoom.usedVoucher) {
        MsgItem *msgItem = [[MsgItem alloc] init];
        msgItem.msgId = [self getMsgId];
        if (self.liveRoom.roomType == LiveRoomType_Public) {
            msgItem.msgType = MsgType_Public_FirstFree;
        } else if (self.liveRoom.roomType == LiveRoomType_Private){
            msgItem.msgType = MsgType_FirstFree;
        }
        msgItem.text = [NSString stringWithFormat:@"%d",(int)self.liveRoom.imLiveRoom.useCoupon];
        msgItem.freeSeconds = self.liveRoom.imLiveRoom.freeSeconds;
        msgItem.roomPrice = self.liveRoom.imLiveRoom.roomPrice;
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
        msgItem.attText = attributeString;
        
        if ([self.delegate respondsToSelector:@selector(onRecvMessageListItem:)]) {
            [self.delegate onRecvMessageListItem:msgItem];
        }
    }
}

// 插入预付费邀请消息
- (void)addScheduleInviteMsg:(NSString *)useId item:(ImScheduleRoomInfoObject *)item {
    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.msgId = [self getMsgId];
    msgItem.msgType = MsgType_Schedule;
    msgItem.usersType = UsersType_Me;
    msgItem.scheduleType = ScheduleType_Pending;
    msgItem.sendName = self.loginManager.loginItem.nickName;
    msgItem.scheduleMsg = item;
    msgItem.isScheduleMore = NO;
    msgItem.isMinimu = NO;
    msgItem.containerHeight = [LSScheduleInviteCell cellHeight:NO isAcceptView:NO isMinimum:NO];
    if ([self.delegate respondsToSelector:@selector(onRecvScheduleMessageItem:)]) {
        [self.delegate onRecvScheduleMessageItem:msgItem];
    }
}

// 插入主播发送/回复预付费邀请消息
- (void)addAncherSendScheduleMsg:(ImScheduleRoomInfoObject *)item {
    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.msgId = [self getMsgId];
    msgItem.msgType = MsgType_Schedule;
    msgItem.sendName = self.liveRoom.userName;
    if (self.liveRoom.roomType == LiveRoomType_Public) {
        msgItem.toName = [NSString stringWithFormat:@"@%@",item.msg.toNickName];
    } else {
        msgItem.toName = @"";
    }
    BOOL isAccept = NO;
    if (item.msg.status == IMSCHEDULESENDSTATUS_PENDING) {
        isAccept = YES;
        msgItem.usersType = UsersType_Liver;
        msgItem.scheduleType = ScheduleType_Pending;
    } else if (item.msg.status == IMSCHEDULESENDSTATUS_CONFIRMED) {
        msgItem.scheduleType = ScheduleType_Confirmed;
        msgItem.usersType = UsersType_Me;
    } else {
        msgItem.scheduleType = ScheduleType_Declined;
        msgItem.usersType = UsersType_Me;
    }
    msgItem.scheduleMsg = item;
    msgItem.isScheduleMore = NO;
    msgItem.isMinimu = NO;
    msgItem.containerHeight = [LSScheduleInviteCell cellHeight:NO isAcceptView:isAccept isMinimum:NO];
    if ([self.delegate respondsToSelector:@selector(onRecvScheduleMessageItem:)]) {
        [self.delegate onRecvScheduleMessageItem:msgItem];
    }
}

// 插入预付费邀请回复状态消息
- (void)addScheduleInviteReplyMsg:(MsgItem *)item {
    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.msgId = [self getMsgId];
    msgItem.msgType = MsgType_Schedule_Status_Tip;
    msgItem.usersType = item.usersType;
    msgItem.scheduleType = item.scheduleType;
    msgItem.scheduleMsg = item.scheduleMsg;
    msgItem.containerHeight = [LSScheduleStatusTipCell cellHeight];
    if ([self.delegate respondsToSelector:@selector(onRecvScheduleMessageItem:)]) {
        [self.delegate onRecvScheduleMessageItem:msgItem];
    }
}

// 获取MsgId
- (NSInteger)getMsgId {
    self.msgId += 1;
    return self.msgId;
}

#pragma mark - LSPrePaidManagerDelegate
#pragma mark - 发送预付费邀请回调
- (void)onRecvSendScheduleInvite:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg item:(LSSendScheduleInviteItemObject *)item {
    if ([self.delegate respondsToSelector:@selector(onRecvSendScheduleInviteToAnchor:errmsg:item:)]) {
        [self.delegate onRecvSendScheduleInviteToAnchor:errnum errmsg:errmsg item:item];
    }
}

#pragma mark - 发送同意预付费邀请回调
- (void)onRecvSendAcceptSchedule:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime scheduleInviteId:(NSString *)inviteId duration:(int)duration roomInfoItem:(ImScheduleRoomInfoObject *)roomInfoItem {
    if ([self.delegate respondsToSelector:@selector(onRecvSendAcceptScheduleToAnchor:errmsg:statusUpdateTime:scheduleInviteId:duration:roomInfoItem:)]) {
        [self.delegate onRecvSendAcceptScheduleToAnchor:errnum errmsg:errmsg statusUpdateTime:statusUpdateTime scheduleInviteId:inviteId duration:duration roomInfoItem:roomInfoItem];
    }
}

#pragma mark - 获取直播间预付费列表个数回调
- (void)onGetScheduleListCount:(NSInteger)maxCount confirmCount:(NSInteger)count pendingCount:(NSInteger)pCount {
    if ([self.delegate respondsToSelector:@selector(onRecvGetScheduleListCount:confirms:pendings:)]) {
        [self.delegate onRecvGetScheduleListCount:maxCount confirms:count pendings:pCount];
    }
}

#pragma mark - 女士发送预付费消息通知
- (void)onRecvAnchorSendScheduleNotice:(ImScheduleRoomInfoObject *)item {
    if ([item.roomId isEqualToString:self.liveRoom.roomId]) {
        if ([self.delegate respondsToSelector:@selector(onRecvAnchorSendScheduleToMeNotice:)]) {
            [self.delegate onRecvAnchorSendScheduleToMeNotice:item];
        }
    }
}


@end
