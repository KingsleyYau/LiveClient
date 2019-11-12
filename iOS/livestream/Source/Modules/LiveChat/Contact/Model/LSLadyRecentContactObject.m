//
//  LSLadyRecentContactObject.m
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSLadyRecentContactObject.h"

#import "LSLiveChatManagerOC.h"

#import "QNChatTextAttachment.h"

@interface LSLadyRecentContactObject ()
@property (strong) LSLCLiveChatMsgItemObject *msg;
@end

@implementation LSLadyRecentContactObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.womanId = [coder decodeObjectForKey:@"womanId"];
        self.firstname = [coder decodeObjectForKey:@"firstname"];
        self.age = [coder decodeIntegerForKey:@"age"];
        self.photoURL = [coder decodeObjectForKey:@"photoURL"];
        self.photoBigURL = [coder decodeObjectForKey:@"photoBigURL"];
        self.isFavorite = [coder decodeBoolForKey:@"isFavorite"];
        self.videoCount = [coder decodeIntegerForKey:@"videoCount"];
        self.lasttime = [coder decodeIntegerForKey:@"lasttime"];
        self.isOnline = [coder decodeBoolForKey:@"isOnline"];
        self.isInChat = [coder decodeBoolForKey:@"isInChat"];
        self.lastInviteMessage = [coder decodeObjectForKey:@"lastInviteMessage"];
        self.showBtn = [coder decodeBoolForKey:@"showBtn"];
        self.isInCamshare = [coder decodeBoolForKey:@"isInCamshare"];
        self.isCamshareEnable = [coder decodeBoolForKey:@"isCamshareEnable"];
        self.isCamShareInviteMsg = [coder decodeBoolForKey:@"isCamShareInviteMsg"];
        self.manLastMsg = [coder decodeBoolForKey:@"manLastMsg"];
        self.unreadCount = [coder decodeIntegerForKey:@"unreadCount"];
        self.showBtn = [coder decodeBoolForKey:@"showBtn"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.womanId forKey:@"womanId"];
    [coder encodeObject:self.firstname forKey:@"firstname"];
    [coder encodeInteger:self.age forKey:@"age"];
    [coder encodeObject:self.photoURL forKey:@"photoURL"];
    [coder encodeObject:self.photoBigURL forKey:@"photoBigURL"];
    [coder encodeBool:self.isFavorite forKey:@"isFavorite"];
    [coder encodeInteger:self.videoCount forKey:@"videoCount"];
    [coder encodeInteger:self.lasttime forKey:@"lasttime"];
    [coder encodeBool:self.isOnline forKey:@"isOnline"];
    [coder encodeBool:self.isInChat forKey:@"isInChat"];
    [coder encodeObject:self.lastInviteMessage forKey:@"lastInviteMessage"];
    [coder encodeBool:self.showBtn forKey:@"showBtn"];
    [coder encodeBool:self.isInCamshare forKey:@"isInCamshare"];
    [coder encodeBool:self.isCamshareEnable forKey:@"isCamshareEnable"];
    [coder encodeBool:self.isCamShareInviteMsg forKey:@"isCamShareInviteMsg"];
    [coder encodeBool:self.manLastMsg forKey:@"manLastMsg"];
    [coder encodeInteger:self.unreadCount forKey:@"unreadCount"];
    [coder encodeBool:self.isShowBtn forKey:@"showBtn"];
}

- (id)copyWithZone:(NSZone *)zone {
    LSLadyRecentContactObject *contactObject = [[[self class] allocWithZone:zone] init];
    contactObject.womanId = self.womanId;
    contactObject.firstname = [self.firstname copyWithZone:zone];
    contactObject.age = self.age;
    contactObject.photoURL = [self.photoURL copyWithZone:zone];
    contactObject.photoBigURL = [self.photoBigURL copyWithZone:zone];
    contactObject.isFavorite = self.isFavorite;
    contactObject.videoCount = self.videoCount;
    contactObject.lasttime = self.lasttime;
    contactObject.isOnline = self.isOnline;
    contactObject.isInChat = self.isInChat;
    contactObject.lastInviteMessage = self.lastInviteMessage;
    contactObject.showBtn = self.showBtn;
    contactObject.isInCamshare = self.isInCamshare;
    contactObject.isCamshareEnable = self.isCamshareEnable;
    contactObject.isCamShareInviteMsg = self.isCamShareInviteMsg;
    contactObject.manLastMsg = self.manLastMsg;
    contactObject.unreadCount = self.unreadCount;
    contactObject.showBtn = self.isShowBtn;
    return contactObject;
}

#pragma mark - 逻辑和界面使用属性和方法
- (NSString *)userName {
    NSString *showName = (self.firstname.length > 0) ? self.firstname : self.womanId;
    return showName;
}

- (void)updateLastTime {
    // TODO:更新联系人最后联系时间
    NSDate *nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timestamp = nowDate.timeIntervalSince1970;
    self.lasttime = (NSInteger)timestamp;
}

- (void)updateRecent:(NSString *)name recentPhoto:(NSString *)photoUrl {
    // TODO:名和头像只更新一次
    if (self.firstname.length == 0) {
        self.firstname = name.length > 0 ? name : self.firstname;
    }

    if (self.photoURL.length == 0) {
        self.photoURL = photoUrl.length > 0 ? photoUrl : self.photoURL;
    }
}

- (BOOL)updateRecentWithUserItem:(LSLCLiveChatUserItemObject *)userInfo {
    // TODO:根据LiveChat接口更新用户状态信息
    BOOL bFlag = NO;

    BOOL bOnline = self.isOnline;
    NSString *userName = self.firstname;
    BOOL bInChat = self.isInChat;

    BOOL bNewInChat = (LC_CHATTYPE_IN_CHAT_CHARGE == userInfo.chatType ||
                       LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET == userInfo.chatType);

    self.isOnline = (userInfo.statusType == USTATUS_ONLINE);
    if (self.firstname.length == 0) {
        self.firstname = (userInfo.userName.length > 0) ? userInfo.userName : self.firstname;
    }
    self.isInChat = bNewInChat;

    if (self.isOnline != bOnline ||
        ![self.firstname isEqualToString:userName] ||
        self.isInChat != bInChat) {
        bFlag = YES;
    }

    return bFlag;
}

- (BOOL)updateRecentWithUserInfoItem:(LSLCLiveChatUserInfoItemObject *)userInfo {
    // TODO:根据LiveChat接口更新用户信息
    BOOL bFlag = NO;

    BOOL bOnline = self.isOnline;
    NSString *userName = self.firstname;

    self.isOnline = (userInfo.status == USTATUS_ONLINE);
    if (self.firstname.length == 0) {
        self.firstname = (userInfo.userName.length > 0) ? userInfo.userName : self.firstname;
    }
    
    if (self.photoURL.length == 0) {
        self.photoURL = (userInfo.avatarImg.length > 0) ? userInfo.avatarImg : self.photoURL;
    }
    
    if (bOnline != self.isOnline || ![self.firstname isEqualToString:userName]) {
        bFlag = YES;
    }

    return bFlag;
}

- (BOOL)updateInviteNewMsgWithMsg:(LSLCLiveChatMsgItemObject *)msg {
    BOOL bFlag = YES;
    
    self.lasttime = msg.createTime;
    
    self.isCamShareInviteMsg = [[LSLiveChatManagerOC manager] isCamshareInviteMsg:self.womanId];
    
    return bFlag;
}

- (BOOL)updateRecentNewMsgWithMsg:(LSLCLiveChatMsgItemObject *)msg {
    BOOL bFlag = YES;
    
    self.lasttime = msg.createTime;
    self.manLastMsg = NO;
    self.unreadCount++;
    
    self.isCamShareInviteMsg = [[LSLiveChatManagerOC manager] isCamshareInviteMsg:self.womanId];
    
    return bFlag;
}

- (BOOL)updateRecentWithMsg:(LSLCLiveChatMsgItemObject *)msg {
    BOOL bFlag = NO;

    if ([[LSLiveChatManagerOC manager] isCamshareInChat:self.womanId]) {
        self.isInCamshare = YES;
    } else {
        self.isInCamshare = NO;
    }

    if ([self isLastMsgChange:msg]) {
        // 更新联系人消息
        self.msg = msg;

        NSString *premiumSticker = NSLocalizedString(@"NOTICE_MESSAGE_ANIMATING_STICKER", nil);
        NSString *animationSticker = NSLocalizedString(@"NOTICE_MESSAGE_PREMIUM_STICKER", nil);
        NSString *photoSticker = NSLocalizedString(@"NOTICE_MESSAGE_PHOTO", nil);
        NSString *voiceSticker = NSLocalizedString(@"NOTICE_MESSAGE_VOICE", nil);
        NSString *videoSticker = NSLocalizedString(@"NOTICE_MESSAGE_VIDEO", nil);

        if (msg.msgType == MT_Text && msg.textMsg) {
            NSString *string = [LSStringEncoder htmlEntityDecode:msg.textMsg.displayMsg];
            NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.lastInviteMessage = [self parseMessageTextEmotion:trimmedString font:[UIFont systemFontOfSize:14]];
            switch (msg.sendType) {
                case SendType_Send: {
                    self.unreadCount = 0;
                } break;
                case SendType_Recv: {
                } break;
                default:
                    break;
            }
        } else if (msg.msgType == MT_Emotion) {
            switch (msg.sendType) {
                case SendType_Recv: {
                    self.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"%@ %@", self.firstname, premiumSticker] font:[UIFont systemFontOfSize:14]];
                } break;
                case SendType_Send: {
                    self.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"You %@", premiumSticker] font:[UIFont systemFontOfSize:14]];
                } break;
                default:
                    break;
            }
        } else if (msg.msgType == MT_MagicIcon) {
            switch (msg.sendType) {
                case SendType_Recv: {
                    self.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"%@ %@", self.firstname, animationSticker] font:[UIFont systemFontOfSize:14]];
                } break;
                case SendType_Send: {
                    self.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"You %@", animationSticker] font:[UIFont systemFontOfSize:14]];
                } break;

                default:
                    break;
            }
        } else if (msg.msgType == MT_Photo) {
            switch (msg.sendType) {
                case SendType_Recv: {
            
                   NSAttributedString *attributeString = [self parseMessageTextEmotion:[NSString stringWithFormat:@"  %@ %@", self.firstname, photoSticker] font:[UIFont systemFontOfSize:14]];
                        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attributeString];
                    //TODO 照片信息icon
                    self.lastInviteMessage = [self addShowIconImageText:string withImage:@"LSChatlist_Photo"];
                } break;
                case SendType_Send: {
                    NSAttributedString *attributeString = [self parseMessageTextEmotion:[NSString stringWithFormat:@"  You %@", photoSticker] font:[UIFont systemFontOfSize:14]];
                    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attributeString];
                    //TODO 照片信息icon
                    self.lastInviteMessage = [self addShowIconImageText:string withImage:@"LSChatlist_Photo"];
                } break;
                default:
                    break;
            }
        } else if (msg.msgType == MT_Voice) {
            switch (msg.sendType) {
                case SendType_Recv: {
                    self.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"%@ %@", self.firstname, voiceSticker] font:[UIFont systemFontOfSize:14]];
                } break;
                case SendType_Send: {
                    self.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"You %@", voiceSticker] font:[UIFont systemFontOfSize:14]];
                } break;

                default:
                    break;
            }
        }else if (msg.msgType == MT_Video) {
            switch (msg.sendType) {
                case SendType_Recv: {
                    
                    NSAttributedString *attributeString = [self parseMessageTextEmotion:[NSString stringWithFormat:@"  %@ %@", self.firstname, videoSticker] font:[UIFont systemFontOfSize:14]];
                    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attributeString];
                    //TODO 视频图片icon
                    self.lastInviteMessage = [self addShowIconImageText:string withImage:@"LSChatlist_Video"];

                } break;
                case SendType_Send: {
                    NSAttributedString *attributeString = [self parseMessageTextEmotion:[NSString stringWithFormat:@"  You %@", videoSticker] font:[UIFont systemFontOfSize:14]];
                    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attributeString];
                    //TODO 视频图片icon
                    self.lastInviteMessage = [self addShowIconImageText:string withImage:@"LSChatlist_Video"];
                } break;
                default:
                    break;
            }
        }else {
            // 如果消息被清空,当前联系还是保存之前的内容,需要置空
            self.lastInviteMessage = [[NSMutableAttributedString alloc] initWithString:@""];
        }
    }

    return bFlag;
}

- (BOOL)updateInviteWithMsg:(LSLCLiveChatMsgItemObject *)msg {
    BOOL bFlag = YES;

    // 更新为未读
    self.unreadCount = 0;

    NSString *premiumSticker = NSLocalizedStringFromSelf(@"NOTICE_MESSAGE_ANIMATING_STICKER");
    NSString *animationSticker = NSLocalizedStringFromSelf(@"NOTICE_MESSAGE_PREMIUM_STICKER");


    if ([self isLastMsgChange:msg]) {
        if (msg.sendType == SendType_Recv) {
            // 更新邀请
            self.msg = msg;
            
            if (msg.msgType == MT_Text && msg.textMsg) {
                NSString *string = [LSStringEncoder htmlEntityDecode:msg.textMsg.displayMsg];
                NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                self.lastInviteMessage = [self parseMessageTextEmotion:trimmedString font:[UIFont systemFontOfSize:15]];
            } else if (msg.msgType == MT_Emotion) {
                self.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"%@ %@", self.firstname, premiumSticker] font:[UIFont systemFontOfSize:15]];
            } else if (msg.msgType == MT_MagicIcon) {
                self.lastInviteMessage = [self parseMessageTextEmotion:[NSString stringWithFormat:@"%@ %@", self.firstname, animationSticker] font:[UIFont systemFontOfSize:15]];
            } else {
                // 如果消息被清空,当前联系还是保存之前的内容,需要置空
                self.lastInviteMessage = [[NSMutableAttributedString alloc] initWithString:@""];
            }
        }
        
    }
    return bFlag;
}

- (BOOL)isLastMsgChange:(LSLCLiveChatMsgItemObject *)msg {
    BOOL bChange = NO;

    if (self.msg) {
        if (self.msg.createTime != msg.createTime) {
            bChange = YES;
        }
    } else if (msg) {
        bChange = YES;
    }

    return bChange;
}

#pragma mark - 富文本
- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
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
    
    [attributeString addAttributes:@{ NSFontAttributeName : font,
                                      NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838)
                                      } range:NSMakeRange(0, attributeString.length)];

    
    return attributeString;
}

- (NSAttributedString *)addShowIconImageText:(NSMutableAttributedString *)attributeString withImage:(NSString *)imageName {
    //NSTextAttachment可以将要插入的图片作为特殊字符处理
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    //定义图片内容及位置和大小
    attch.image = [UIImage imageNamed:imageName];
    attch.bounds = CGRectMake(0, -2, 12, 12);
    //创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    //将图片放在第一位
    [attributeString insertAttributedString:string atIndex:0];
    
    return attributeString;
}


@end
