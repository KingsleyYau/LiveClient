//
//  ContactManager.m
//  dating
//
//  Created by lance on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNContactManager.h"

#import "LSSessionRequestManager.h"
#import "LSLiveChatManagerOC.h"
#import "LSLoginManager.h"

#import "QNChatTextAttachment.h"

static QNContactManager *gManager = nil;
@interface QNContactManager () <LSLiveChatManagerListenerDelegate, LoginManagerDelegate>
/**
 *  请求管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

/**
 *  回调数组
 */
@property (nonatomic, strong) NSMutableArray *delegates;

/**
 *  Livechat管理器
 */
@property (nonatomic, strong) LSLiveChatManagerOC *liveChatManager;

/**
 *  Login管理器
 */
@property (nonatomic, strong) LSLoginManager *loginManager;

/**
 *  在线状态刷新定时器
 */
@property (nonatomic, strong) NSTimer *statusTimer;

/**
 当前本地的联系人列表(内部用)
 */
@property (nonatomic, strong) NSMutableArray *items;

/**
 当前本地的邀请列表(内部用)
 */
@property (nonatomic, strong) NSMutableArray *invites;

@end
@implementation QNContactManager

#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _status = ContactManagerStatusNone;
        
        self.delegates = [NSMutableArray array];
        self.items = [NSMutableArray array];
        self.invites = [NSMutableArray array];
        
        self.sessionManager = [LSSessionRequestManager manager];
        
        self.liveChatManager = [LSLiveChatManagerOC manager];
        [self.liveChatManager addDelegate:self];
        
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
    }
    return self;
}

- (void)addDelegate:(id<QNContactManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<QNContactManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<QNContactManagerDelegate> item = (id<QNContactManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}

#pragma mark - 触发同步联系人列表
- (void)onGetContactList:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg usersInfo:(NSArray<LSLCLiveChatUserInfoItemObject *> *_Nonnull)usersInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onGetContactList( [同步服务器联系人列表], errMsg : %@ )", errMsg);
        if (LSLIVECHAT_LCC_ERR_SUCCESS == errType) {
            [self syncLivechatUserList:usersInfo];
        }
        // 通知监听者
        [self onSyncRecentContactList:errType errmsg:errMsg];
    });
}

/**
 更新联系人状态
 */
- (void)updateRecentsStatus {
    NSLog(@"QNContactManager::updateRecentsStatus( [IM和Http都已经登录, 更新所有联系人状态] )");
    // 更新在聊状态
    [self updateChatingStatus];
    // 更新男士邀请状态
    [self updateManInviteStatus];
    // 更新联系人信息
    [self updateRecentContactAllStatus];
    // 更新未读信息状态
    [self updateReadMsg];
    
    [self.statusTimer invalidate];
    self.statusTimer = nil;
    // 开启定时器
    self.statusTimer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(updateOnlineStatus:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.statusTimer forMode:NSDefaultRunLoopMode];
    [self.statusTimer fire];
}

/**
 同步并合并联系人
 
 @param array <#array description#>
 */
- (void)syncLivechatUserList:(NSArray<LSLCLiveChatUserInfoItemObject *> *_Nonnull)array {
    NSLog(@"QNContactManager::syncLivechatUserList( [同步服务器联系人列表], count : %ld )", (long)array.count);
    
    for (LSLCLiveChatUserInfoItemObject *user in array) {
        
        LSLadyRecentContactObject *recentItem = [[LSLadyRecentContactObject alloc] init];
        
        // 非联系人
        recentItem.womanId = user.userId;
        recentItem.firstname = user.userName;
        recentItem.photoURL = user.avatarImg;
        
        NSString *premiumSticker = NSLocalizedString(@"NOTICE_MESSAGE_ANIMATING_STICKER", nil);
        NSString *animationSticker = NSLocalizedString(@"NOTICE_MESSAGE_PREMIUM_STICKER", nil);
        BOOL bFlag = [self.liveChatManager isChatingUserInChatState:user.userId];
        recentItem.isInChat = bFlag;
        
        // 获取最后一条消息
        LSLCLiveChatMsgItemObject *msg = [self.liveChatManager getTheOtherLastMessage:user.userId];
        if (msg.msgType == MT_Text && msg.textMsg) {
            NSString *string = [LSStringEncoder htmlEntityDecode:msg.textMsg.displayMsg];
            NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            recentItem.lastInviteMessage = [self parseMessageTextEmotion:trimmedString font:[UIFont systemFontOfSize:15]];
        } else if (msg.msgType == MT_Emotion) {
            recentItem.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"%@ %@", recentItem.firstname, premiumSticker] font:[UIFont systemFontOfSize:15]];
        } else if (msg.msgType == MT_MagicIcon) {
            recentItem.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"%@ %@", recentItem.firstname, animationSticker] font:[UIFont systemFontOfSize:15]];
        } else {
            recentItem.lastInviteMessage = [[NSMutableAttributedString alloc] initWithString:@""];
        }
        
        // 更新为未读
        recentItem.unreadCount = 0;
        
        LSLadyRecentContactObject *theRecent = [self getRecentWithId:user.userId];
        if (nil != theRecent) {
            // 已存在，则更新数据
            [self updateRecentInfo:theRecent src:recentItem];
        } else {
            // 不存在，则添加到列表
            [self.items addObject:recentItem];
        }
    }
}

#pragma mark - 获取本地联系人
- (NSArray *)recentItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (LSLadyRecentContactObject *item in self.items) {
        //        if (item.isOnline) {
        //            [self.liveChatManager getLadyCamStatus:item.womanId];
        //        }
        
        // 获取最后一条消息
        LSLCLiveChatMsgItemObject *msg = [self.liveChatManager getLastMsg:item.womanId];
        [item updateRecentWithMsg:msg];
        
        [items addObject:item];
    }
    
    return items;
}

#pragma mark - 获取本地邀请
- (NSArray *)inviteItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSArray<LSLCLiveChatUserItemObject *> *array = [self.liveChatManager getInviteUsers];
    for (LSLCLiveChatUserItemObject *user in array) {
        // 根据Id获取(创建)邀请
        LSLadyRecentContactObject *inviteItem = [self getOrNewInviteWithId:user.userId];
        // 根据Id获取联系人
        LSLadyRecentContactObject *recentItem = [self getRecentWithId:user.userId];
        if (recentItem) {
            // 已经是联系人, 更新为联系人数据
            [self updateRecentInfo:inviteItem src:recentItem];
        }
        
        // 更新名字和头像
        [inviteItem updateRecent:user.userName recentPhoto:user.imageUrl];
        // 更新邀请信息
        LSLCLiveChatMsgItemObject *msg = [self.liveChatManager getLastMsg:user.userId];
        [inviteItem updateInviteWithMsg:msg];
        
        [items addObject:inviteItem];
    }
    
    return items;
}

#pragma mark - 本地联系人管理
- (LSLadyRecentContactObject *)getOrNewRecentWithId:(NSString *)womanId {
    NSLog(@"QNContactManager::getOrNewRecentWithId( [获取/添加联系人], womanId : %@ )", womanId);
    
    LSLadyRecentContactObject *item = [self getRecentWithId:womanId];
    if (nil == item) {
        item = [[LSLadyRecentContactObject alloc] init];
        item.womanId = womanId;
        [self.items addObject:item];
    }
    return item;
}

- (LSLadyRecentContactObject *)getRecentWithId:(NSString *)userId {
    // TODO:根据用户ID获取联系人
    LSLadyRecentContactObject *object = nil;
    for (LSLadyRecentContactObject *recent in self.items) {
        if ([recent.womanId isEqualToString:userId]) {
            object = recent;
            break;
        }
    }
    return object;
}

#pragma mark - 本地邀请管理
- (LSLadyRecentContactObject *)getOrNewInviteWithId:(NSString *)userId {
    // TODO:根据用户ID获取(创建)邀请
    NSLog(@"QNContactManager::getOrNewInviteWithId( [获取/添加邀请], userId : %@ )", userId);
    
    LSLadyRecentContactObject *item = [self getInviteWithId:userId];
    if (nil == item) {
        item = [[LSLadyRecentContactObject alloc] init];
        item.womanId = userId;
        // 创建邀请用户时候默认为在线
        item.isOnline = YES;
        [self.invites addObject:item];
    }
    return item;
}

- (LSLadyRecentContactObject *)getInviteWithId:(NSString *)userId {
    // TODO:根据用户ID获取邀请
    LSLadyRecentContactObject *object = nil;
    for (LSLadyRecentContactObject *invite in self.invites) {
        if ([invite.womanId isEqualToString:userId]) {
            object = invite;
            break;
        }
    }
    return object;
}

#pragma mark - 同步联系人状态
- (void)updateRecents {
    // TODO:更新联系人列表
    NSLog(@"QNContactManager::updateRecents( [更新联系人列表] )");
    
    // 进行排序
    [self sortRecents];
    // 更新联系人列表
    [self onChangeRecentContactStatusCallback];
}

- (BOOL)isInChatUser:(NSString *)userId {
    // TODO:判断是否在聊用户
    BOOL bFlag = [self.liveChatManager isChatingUserInChatState:userId];
    NSLog(@"QNContactManager::isInChatUser( [更新联系人列表], userId : %@, bFlag : %@ )", userId, BOOL2YES(bFlag));
    return bFlag;
}

- (void)updateChatingStatus {
    // TODO:更新用户在聊状态
    NSLog(@"QNContactManager::updateChatingStatus( [更新用户在聊状态] )");
    
    BOOL isChange = NO;
    NSArray<LSLCLiveChatUserItemObject *> *array = [self.liveChatManager getChatingUsers];
    for (LSLCLiveChatUserItemObject *user in array) {
        LSLadyRecentContactObject *theRecent = [self getRecentWithId:user.userId];
        if (nil != theRecent) {
            BOOL newIsInChat = (LC_CHATTYPE_IN_CHAT_CHARGE == user.chatType || LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET == user.chatType);
            if (theRecent.isInChat != newIsInChat) {
                theRecent.isInChat = newIsInChat;
                isChange = YES;
            }
        } else {
            LSLadyRecentContactObject *recent = [self getOrNewRecentWithId:user.userId];
            recent.lasttime = [[NSDate new] timeIntervalSince1970];
            recent.manLastMsg = YES;
            BOOL newIsInChat = (LC_CHATTYPE_IN_CHAT_CHARGE == user.chatType || LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET == user.chatType);
            recent.isInChat = newIsInChat;
            [recent updateRecent:user.userName recentPhoto:user.imageUrl];
            
            isChange = YES;
        }
    }
    
    if (isChange) {
        // 进行排序
        [self sortRecents];
        // 更新联系人列表
        [self onChangeRecentContactStatusCallback];
    }
}

- (void)updateManInviteStatus {
    // TODO:更新男士邀请为在聊状态
    NSLog(@"QNContactManager::updateManInviteStatus( [更新用户在聊状态(男士邀请)] )");
    BOOL isChange = NO;
    NSArray<LSLCLiveChatUserItemObject *> *array = [self.liveChatManager getManInviteUsers];
    for (LSLCLiveChatUserItemObject *user in array) {
        LSLadyRecentContactObject *theRecent = [self getRecentWithId:user.userId];
        if (nil != theRecent) {
            BOOL newIsInChat = (LC_CHATTYPE_MANINVITE == user.chatType);
            if (newIsInChat) {
                theRecent.isInChat = NO;
                isChange = YES;
            }
        } else {
            LSLadyRecentContactObject *recent = [self getOrNewRecentWithId:user.userId];
            recent.lasttime = [[NSDate new] timeIntervalSince1970];
            recent.manLastMsg = YES;
            recent.isInChat = NO;
            isChange = YES;
            
            [recent updateRecent:user.userName recentPhoto:user.imageUrl];
        }
    }
    
    if (isChange) {
        // 进行排序
        [self sortRecents];
        // 更新联系人列表
        [self onChangeRecentContactStatusCallback];
    }
}

- (void)updateReadMsg {
    // TODO:更新未读信息状态
    NSLog(@"QNContactManager::updateReadMsg( [更新女士信息未读] )");
    
    BOOL isChange = NO;
    for (LSLadyRecentContactObject *user in self.items) {
        if (user) {
            NSInteger unreadCount = 0;
            NSString *unreadCountKey = [NSString stringWithFormat:@"unreadCount_%@", user.womanId];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:unreadCountKey] != nil) {
                if (user.isInChat) {
                    unreadCount = [[NSUserDefaults standardUserDefaults] integerForKey:unreadCountKey];
                }
            }
            user.unreadCount = unreadCount;
        }
    }
    if (isChange) {
        // 进行排序
        [self sortRecents];
        // 更新联系人列表
        [self onChangeRecentContactStatusCallback];
    }
}

- (void)updateReadMsg:(NSString *)womanId {
    // TODO:更新女士已读信息
    NSLog(@"QNContactManager::updateReadMsg( [更新女士信息已读], womanId : %@ )", womanId);
    
    LSLadyRecentContactObject *theRecent = [self getRecentWithId:womanId];
    if (theRecent) {
        theRecent.unreadCount = 0;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *unreadCountKey = [NSString stringWithFormat:@"unreadCount_%@", womanId];
        [userDefaults setInteger:theRecent.unreadCount forKey:unreadCountKey];
        [userDefaults synchronize];
        
        // 进行排序
        [self sortRecents];
        // 更新联系人列表
        [self onChangeRecentContactStatusCallback];
    }
}

- (NSInteger)getChatListUnreadCount {
    // TODO: 获取所有联系人列表未读数量总和
    NSInteger contactUnreadCount = 0;
    for (LSLadyRecentContactObject *item in self.items) {
        if (item.unreadCount > 0 ) {
            contactUnreadCount += item.unreadCount;
        }
    }
    NSLog(@"QNContactManager::getChatListUnreadCount( [是否存在未读信息], contactUnreadCount : %d )", (int)contactUnreadCount);
    return contactUnreadCount;
}

- (void)removeChatLastMsg:(NSString *)womanId {
    // TODO:清空女士聊天列表最后一条消息
    NSLog(@"QNContactManager::removeChatLastMsg( [清空女士聊天列表最后一条消息], womanId : %@ )", womanId);
    for (LSLadyRecentContactObject *obj in self.items) {
        if ([obj.womanId isEqualToString:womanId]) {
            obj.lastInviteMessage = [[NSAttributedString alloc] initWithString:@""];
            break;
        }
    }
}
#pragma mark - 在线状态刷新定时器回调
- (void)updateOnlineStatus:(id)timer {
    // TODO:定时获取联系人在线状态
    NSLog(@"QNContactManager::updateOnlineStatus( [定时更新联系人在线状态] )");
    [self updateOnlineStatusWithBatch:self.items];
}

- (void)updateOnlineStatusWithBatch:(NSArray<LSLadyRecentContactObject *> *)recents {
    // TODO:分批获取联系人在线状态
    NSLog(@"QNContactManager::updateOnlineStatusWithBatch( [分批获取联系人在线状态], count : %d )", (int)recents.count);
    
    // 定义每批获取的数量
    const NSInteger setp = 20;
    NSRange range = NSMakeRange(0, setp);
    
    // 分批获取联系人在线状态
    while (range.location < [recents count]) {
        if (range.location + setp < [recents count]) {
            range.length = setp;
        } else {
            range.length = [recents count] - range.location;
        }
        
        // 获取本批联系人的ID数组
        NSArray<LSLadyRecentContactObject *> *recentContacts = [recents subarrayWithRange:range];
        NSMutableArray<NSString *> *userIds = [NSMutableArray array];
        for (LSLadyRecentContactObject *object in recentContacts) {
            [userIds addObject:object.womanId];
        }
        
        // 获取本批联系人在线状态
        [self.liveChatManager getUserStatus:userIds];
        
        range.location += range.length;
    }
}

#pragma mark - 同步联系人详情
- (void)updateRecentContactAllStatus {
    // TODO:分批获取联系人所有信息
    NSArray<LSLadyRecentContactObject *> *recents = self.items;
    NSLog(@"QNContactManager::updateRecentContactAllStatus( [分批获取联系人所有信息(名字/头像/Cam状态)], count : %d )", (int)recents.count);
    
    // 定义每批获取的数量
    const NSInteger setp = 20;
    NSRange range = NSMakeRange(0, setp);
    
    // 分批获取联系人信息
    while (range.location < [recents count]) {
        if (range.location + setp < [recents count]) {
            range.length = setp;
        } else {
            range.length = [recents count] - range.location;
        }
        
        // 获取本批联系人的ID数组
        NSArray<LSLadyRecentContactObject *> *recentContacts = [recents subarrayWithRange:range];
        NSMutableArray<NSString *> *userIds = [NSMutableArray array];
        for (LSLadyRecentContactObject *object in recentContacts) {
            // 获取头像和名字
            if (object.photoURL.length == 0 || object.firstname.length == 0) {
                [self.liveChatManager getUserInfo:object.womanId];
            }
            [userIds addObject:object.womanId];
        }
        
        range.location += range.length;
    }
}

#pragma mark - LivechatManager状态处理
- (void)onChangeOnlineStatus:(LSLCLiveChatUserItemObject *)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isChange = [self updateRecentWithUserItem:user];
        if (isChange) {
            // 进行排序
            [self sortRecents];
            // 更新联系人列表
            [self onChangeRecentContactStatusCallback];
        }
    });
}

- (void)onRecvTalkEvent:(LSLCLiveChatUserItemObject *)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onRecvTalkEvent()");
        BOOL isChange = [self updateRecentWithUserItem:user];
        if (isChange) {
            // 进行排序
            [self sortRecents];
            // 更新联系人列表
            [self onChangeRecentContactStatusCallback];
            // 更新邀请列表
            [self onChangeInviteListCallback];
        }
    });
}

- (void)onEndTalk:(LSLCLiveChatUserItemObject *)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isChange = NO;
        LSLadyRecentContactObject *theRecent = [self getRecentWithId:user.userId];
        if (nil != theRecent) {
            BOOL newIsInChat = (LC_CHATTYPE_IN_CHAT_CHARGE == user.chatType || LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET == user.chatType);
            if (theRecent.isInChat != newIsInChat) {
                theRecent.isInChat = newIsInChat;
                if (newIsInChat == NO) {
                    theRecent.unreadCount = 0;
                    theRecent.lastInviteMessage = [[NSMutableAttributedString alloc] initWithString:@""];
                }
                isChange = YES;
            } else if (theRecent.manLastMsg) {
                isChange = YES;
            }
        }
        NSLog(@"QNContactManager::onEndTalk( userId : %@  isChange : %@)", user.userId, BOOL2YES(isChange));
        if (isChange) {
            // 进行排序
            [self sortRecents];
            // 更新联系人列表
            [self onChangeRecentContactStatusCallback];
        }
        
    });
}

- (void)onGetTalkList:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onGetTalkList()");
        [self updateRecentsStatus];
    });
}

- (void)onGetUsersHistoryMessage:(BOOL)success errNo:(NSString *)errNo errMsg:(NSString *)errMsg userIds:(NSArray<NSString *> *)userIds {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onGetUsersHistoryMessage()");
        [self updateOnlineStatusWithBatch:self.items];
    });
}

- (void)onGetUserStatus:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg users:(NSArray<LSLCLiveChatUserItemObject *> *_Nonnull)users {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onGetUserStatus( count : %d )", (int)users.count);
        if (LSLIVECHAT_LCC_ERR_SUCCESS == errType) {
            BOOL isChange = NO;
            for (LSLCLiveChatUserItemObject *userItem in users) {
                BOOL bFlag = [self updateRecentWithUserItem:userItem];
                if (bFlag) {
                    isChange = bFlag;
                }
            }
            
            if (isChange) {
                // 进行排序
                [self sortRecents];
                // 更新联系人列表
                [self onChangeRecentContactStatusCallback];
            }
        }
    });
}

- (void)onGetUserInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg userId:(NSString *)userId userInfo:(LSLCLiveChatUserItemObject *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (LSLIVECHAT_LCC_ERR_SUCCESS == errType) {
            BOOL isChange = [self updateRecentWithUserInfoItem:userInfo];
            if (isChange) {
                // 进行排序
                [self sortRecents];
                // 更新联系人列表
                [self onChangeRecentContactStatusCallback];
            }
            
            isChange = [self updateInviteWithUserInfoItem:userInfo];
            if (isChange) {
                // 更新邀请列表
                [self onChangeInviteListCallback];
            }
        }
    });
}

- (void)onGetUsersInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg seq:(int)seq userIdList:(NSArray *)userIdList usersInfo:(NSArray<LSLCLiveChatUserItemObject *> *)usersInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onGetUsersInfo( count : %d )", (int)usersInfo.count);
        if (LSLIVECHAT_LCC_ERR_SUCCESS == errType) {
            BOOL isChange = NO;
            for (LSLCLiveChatUserItemObject *userInfo in usersInfo) {
                BOOL bFlag = [self updateRecentWithUserInfoItem:userInfo];
                if (bFlag) {
                    isChange = bFlag;
                }
            }
            
            if (isChange) {
                // 进行排序
                [self sortRecents];
                // 更新联系人列表
                [self onChangeRecentContactStatusCallback];
            }
        }
    });
}

#pragma mark - LiveChatManager消息处理
- (void)onRecvTextMsg:(LSLCLiveChatMsgItemObject *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onRecvTextMsg( [收到文本消息], fromId : %@ )", msg.fromId);
        [self reloadDataWithRecvMsg:msg];
    });
}

- (void)onRecvVoice:(LSLCLiveChatMsgItemObject *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onRecvVoice( [收到语音消息], fromId : %@ )", msg.fromId);
        [self reloadDataWithRecvMsg:msg];
    });
}

- (void)onRecvMagicIcon:(LSLCLiveChatMsgItemObject *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onRecvMagicIcon( [收到小高表消息], fromId : %@ )", msg.fromId);
        [self reloadDataWithRecvMsg:msg];
    });
}

- (void)onRecvEmotion:(LSLCLiveChatMsgItemObject *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onRecvEmotion( [收到高级表情消息], fromId : %@ )", msg.fromId);
        [self reloadDataWithRecvMsg:msg];
    });
}

- (void)onRecvPhoto:(LSLCLiveChatMsgItemObject *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onRecvPhoto( [收到私密照消息], fromId : %@ )", msg.fromId);
        [self reloadDataWithRecvMsg:msg];
    });
}

- (void)onRecvVideo:(LSLCLiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onRecvVideo( [收到视频消息], fromId : %@ )", msgItem.fromId);
        [self reloadDataWithRecvMsg:msgItem];
    });
}

- (void)reloadDataWithRecvMsg:(LSLCLiveChatMsgItemObject *)msg {
    NSLog(@"QNContactManager::reloadDataWithRecvMsg( [根据消息刷新联系人/邀请], fromId : %@, inviteType : %@ )", msg.fromId, (msg.inviteType == IniviteTypeCamshare)?@"Cam":@"Chat");
    
    BOOL isContactMsg = NO;
    LSLadyRecentContactObject *lady = [self getRecentWithId:msg.fromId];
    if (lady) {
        // 收到联系人消息, 更新未读/是否Cam邀请
        isContactMsg = [lady updateRecentNewMsgWithMsg:msg];
        
        // 更新联系人为有未读消息
        NSString *unreadCountKey = [NSString stringWithFormat:@"unreadCount_%@", msg.fromId];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:lady.unreadCount forKey:unreadCountKey];
        [userDefaults synchronize];
        
        if (!lady.isInChat) {
            // 不是在聊
            LSLadyRecentContactObject *invite = [self getOrNewInviteWithId:msg.fromId];
            // 刷新未读/是否Cam邀请
            [invite updateInviteNewMsgWithMsg:msg];
        }
        
    } else {
        // 不是联系人, 一定是邀请
        LSLadyRecentContactObject *invite = [self getOrNewInviteWithId:msg.fromId];
        // 刷新未读/是否Cam邀请
        [invite updateInviteNewMsgWithMsg:msg];
        
        // 可能没有头像, 请求详情
        [self.liveChatManager getUserInfo:msg.fromId];
    }
    
    // 进行排序
    [self sortRecents];
    // 更新联系人列表
    [self onChangeRecentContactStatusCallback];
    // 更新邀请列表
    [self onChangeInviteListCallback];
}

#pragma mark - 内部联系人管理
- (void)updateRecentInfo:(LSLadyRecentContactObject *)des src:(LSLadyRecentContactObject *)src {
    // TODO:更新联系人数据
    des.womanId = src.womanId;
    des.firstname = src.firstname;
    des.age = src.age;
    des.photoURL = src.photoURL;
    des.photoBigURL = src.photoBigURL;
    des.isFavorite = src.isFavorite;
    des.videoCount = src.videoCount;
    des.lasttime = src.lasttime;
    des.isOnline = src.isOnline;
    des.isInChat = src.isInChat;
    des.isInCamshare = src.isInCamshare;
    des.isCamshareEnable = src.isCamshareEnable;
}

- (BOOL)updateRecentWithUserItem:(LSLCLiveChatUserItemObject *)userInfo {
    // TODO:根据LiveChat接口更新联系人状态信息
    BOOL bFlag = NO;
    
    LSLadyRecentContactObject *theRecent = [self getRecentWithId:userInfo.userId];
    if (theRecent) {
        bFlag = [theRecent updateRecentWithUserItem:userInfo];
        NSLog(@"QNContactManager::updateRecentWithUserItem( [根据LiveChat接口更新联系人状态信息], userId : %@， bOnline : %@, userName : %@, bInChat : %@, photoURL : %@ )", theRecent.womanId, BOOL2YES(theRecent.isOnline), theRecent.firstname, BOOL2YES(theRecent.isInChat), theRecent.photoURL);
    }
    
    return bFlag;
}

- (BOOL)updateRecentWithUserInfoItem:(LSLCLiveChatUserItemObject *)userInfo {
    // TODO:根据LiveChat接口更新联系人信息
    BOOL bFlag = NO;
    
    LSLadyRecentContactObject *theRecent = [self getRecentWithId:userInfo.userId];
    if (theRecent) {
        bFlag = [theRecent updateRecentWithUserInfoItem:userInfo];
        
        NSLog(@"QNContactManager::updateRecentWithUserInfoItem( [根据LiveChat接口更新联系人信息], userId : %@， bOnline : %@, userName : %@, photoURL : %@ )", theRecent.womanId, BOOL2YES(theRecent.isOnline), theRecent.firstname, theRecent.photoURL);
    }
    
    return bFlag;
}

- (void)combineRecentWithRequest:(NSArray<LSLadyRecentContactObject *> *)recents {
    // TODO:合并请求回来的联系人
    for (LSLadyRecentContactObject *recent in recents) {
        LSLadyRecentContactObject *theRecent = [self getRecentWithId:recent.womanId];
        if (nil != theRecent) {
            // 已存在，则更新数据
            [self updateRecentInfo:theRecent src:recent];
        } else {
            // 不存在，则添加到列表
            [self.items addObject:recent];
        }
    }
}

NSInteger sortRecent(id obj1, id obj2, void *context) {
    // TODO:联系人排序函数
    NSComparisonResult result = NSOrderedSame;
    LSLadyRecentContactObject *recent1 = (LSLadyRecentContactObject *)obj1;
    LSLadyRecentContactObject *recent2 = (LSLadyRecentContactObject *)obj2;
    
    // 比较在线状态
    if (NSOrderedSame == result) {
        if (recent1.isOnline != recent2.isOnline) {
            result = (recent1.isOnline ? NSOrderedAscending : NSOrderedDescending);
        }
    }
    
    // 比较在聊状态
    if (NSOrderedSame == result) {
        if (recent1.isInChat != recent2.isInChat) {
            result = (recent1.isInChat ? NSOrderedAscending : NSOrderedDescending);
        }
    }
    
    // 比较favorite
    if (NSOrderedSame == result) {
        if (recent1.isFavorite != recent2.isFavorite) {
            result = (recent1.isFavorite ? NSOrderedAscending : NSOrderedDescending);
        }
    }
    
    // 比较最后一条聊天消息时间
    if (NSOrderedSame == result) {
        if (recent1.lasttime != recent2.lasttime) {
            result = (recent1.lasttime > recent2.lasttime ? NSOrderedAscending : NSOrderedDescending);
        }
    }
    
    return result;
}

- (void)sortRecents {
    // TODO:对联系人数组排序
    [self.items sortUsingFunction:sortRecent context:nil];
}

#pragma mark - 内部邀请管理
- (BOOL)updateInviteWithUserInfoItem:(LSLCLiveChatUserItemObject *)userInfo {
    // TODO:根据LiveChat接口更新邀请信息
    BOOL bFlag = NO;
    
    LSLadyRecentContactObject *lady = [self getInviteWithId:userInfo.userId];
    if (lady) {
        bFlag = [lady updateRecentWithUserInfoItem:userInfo];
        
        NSLog(@"QNContactManager::updateInviteWithUserInfoItem( [根据LiveChat接口更新邀请信息], userId : %@， bOnline : %@, userName : %@, photoURL : %@ )", lady.womanId, BOOL2YES(lady.isOnline), lady.firstname, lady.photoURL);
    }
    
    return bFlag;
}

#pragma mark - 监听者回调
- (void)onSyncRecentContactList:(LSLIVECHAT_LCC_ERR_TYPE)success errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            for (NSValue *value in self.delegates) {
                id<QNContactManagerDelegate> delegate = (id<QNContactManagerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(manager:onSyncRecentContactList:items:errmsg:)]) {
                    [delegate manager:self onSyncRecentContactList:success items:[self.items mutableCopy] errmsg:errmsg];
                }
            }
        }
    });
}

- (void)onChangeRecentContactStatusCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self.delegates) {
            for (NSValue *value in self.delegates) {
                id<QNContactManagerDelegate> delegate = (id<QNContactManagerDelegate>)value.nonretainedObjectValue;
                if (delegate && [delegate respondsToSelector:@selector(onChangeRecentContactStatus:)]) {
                    [delegate onChangeRecentContactStatus:self];
                }
            }
        }
    });
}

- (void)onChangeInviteListCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self.delegates) {
            for (NSValue *value in self.delegates) {
                id<QNContactManagerDelegate> delegate = (id<QNContactManagerDelegate>)value.nonretainedObjectValue;
                if (delegate && [delegate respondsToSelector:@selector(onChangeInviteList:)]) {
                    [delegate onChangeInviteList:self];
                }
            }
        }
    });
}

#pragma mark - 登录管理器回调 (LoginManagerDelegate)
- (void)onLogout:(LSLIVECHAT_LCC_ERR_TYPE)errType errmsg:(NSString *)errmsg isAutoLogin:(BOOL)isAutoLogin {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager::onLogout( [IMonLogout通知, 删除定时器] )");
        // 停止定时器
        [self.statusTimer invalidate];
        self.statusTimer = nil;
        
        if (!isAutoLogin) {
            // 清空本地联系人
            [self.items removeAllObjects];
            [self.invites removeAllObjects];
        }
        [self onSyncRecentContactList:LSLIVECHAT_LCC_ERR_SUCCESS errmsg:@""];
    });
}

#pragma mark - 富文本
- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font {
    NSMutableAttributedString *attributeString = nil;
    if (text != nil) {
        attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    }
    NSRange range;
    NSRange endRange;
    NSRange valueRange;
    NSRange replaceRange;
    
    NSString *emotionOriginalString = nil;
    NSString *emotionString = nil;
    NSAttributedString *emotionAttString = nil;
    QNChatTextAttachment *attachment = nil;
    UIImage *image = nil;
    
    NSString *findString = attributeString.string;
    
    // 替换img
    while (
           (range = [findString rangeOfString:@"[img:"]).location != NSNotFound &&
           (endRange = [findString rangeOfString:@"]"]).location != NSNotFound &&
           range.location < endRange.location) {
        // 增加表情文本
        attachment = [[QNChatTextAttachment alloc] init];
        attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
        
        // 解析表情字串
        valueRange = NSMakeRange(range.location, NSMaxRange(endRange) - range.location);
        emotionOriginalString = [findString substringWithRange:valueRange];
        
        valueRange = NSMakeRange(NSMaxRange(range), endRange.location - NSMaxRange(range));
        emotionString = [findString substringWithRange:valueRange];
        
        // 创建表情
        image = [UIImage imageNamed:[NSString stringWithFormat:@"LS_img%@", emotionString]];
        attachment.image = image;
        attachment.text = emotionOriginalString;
        
        // 生成表情富文本
        emotionAttString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        // 替换普通文本为表情富文本
        replaceRange = NSMakeRange(range.location, NSMaxRange(endRange) - range.location);
        [attributeString replaceCharactersInRange:replaceRange withAttributedString:emotionAttString];
        
        // 替换查找文本
        findString = attributeString.string;
    }
    
    [attributeString addAttributes:@{ NSFontAttributeName : font } range:NSMakeRange(0, attributeString.length)];
    
    return attributeString;
}
@end
