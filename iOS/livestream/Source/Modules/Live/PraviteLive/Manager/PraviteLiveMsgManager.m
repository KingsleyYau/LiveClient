//
//  PraviteLiveMsgManager.m
//  livestream
//
//  Created by Randy_Fan on 2019/8/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "PraviteLiveMsgManager.h"
#import "LSChatNameView.h"

#define NameFontSize 11
#define NoticeFontSize 12
#define MessageFontSize 14

#define BoldSystemFont(S) [UIFont boldSystemFontOfSize:S]
#define SystemFont(S) [UIFont systemFontOfSize:S]

@implementation PraviteLiveMsgManager

- (NSMutableAttributedString *)presentTheRoomStyleItem:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item {
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    switch (item.msgType) {
        case MsgType_FirstFree:{
            /** 私密直播间试用券消息 **/
            [attributeStr appendAttributedString:[self parseMessage:NSLocalizedString(@"Member_FirstFree", @"Member_FirstFree") font:SystemFont(NoticeFontSize) color:roomStyleItem.firstFreeStrColor]];
            [attributeStr appendAttributedString:[self parseMessage:item.text font:SystemFont(NoticeFontSize) color:COLOR_WITH_16BAND_RGB(0xff3508)]];
            [attributeStr appendAttributedString:[self parseMessage:NSLocalizedString(@"Member_FirstFree_Time", @"Member_FirstFree_Time") font:SystemFont(NoticeFontSize) color:roomStyleItem.firstFreeStrColor]];
        } break;
            
        case MsgType_Public_FirstFree:{
            /** 公开直播间试用券消息 **/
            [attributeStr appendAttributedString:[self parseMessage:NSLocalizedString(@"Member_FirstFree", @"Member_FirstFree") font:SystemFont(NoticeFontSize) color:roomStyleItem.firstFreeStrColor]];
            [attributeStr appendAttributedString:[self parseMessage:item.text font:SystemFont(NoticeFontSize) color:COLOR_WITH_16BAND_RGB(0xff3508)]];
            [attributeStr appendAttributedString:[self parseMessage:NSLocalizedString(@"Member_Public_Time", @"Member_Public_Time") font:SystemFont(NoticeFontSize) color:roomStyleItem.firstFreeStrColor]];
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%d",item.freeSeconds] font:SystemFont(NoticeFontSize) color:COLOR_WITH_16BAND_RGB(0xff3508)]];
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:NSLocalizedString(@"Member_Public_Room_Price", @"Member_Public_Room_Price"),item.roomPrice] font:SystemFont(NoticeFontSize) color:roomStyleItem.firstFreeStrColor]];
        } break;
            
        case MsgType_Announce: {
            /** 普通公告 **/
            [attributeStr appendAttributedString:[self parseMessage:item.text font:SystemFont(NoticeFontSize) color:roomStyleItem.announceStrColor]];
        } break;
            
        case MsgType_Link: {
            /** 带链接公告 **/
            [attributeStr appendAttributedString:[self linkMessage:item.text font:SystemFont(NoticeFontSize) color:roomStyleItem.announceStrColor]];
        } break;
            
        case MsgType_Warning: {
            /** 警告提示 **/
            [attributeStr appendAttributedString:[self parseMessage:item.text font:SystemFont(NoticeFontSize) color:roomStyleItem.warningStrColor]];
        } break;
            
        case MsgType_Join: {
            /** 入场消息 **/
            // 姓名
            UIFont *nameFont = [[UIFont alloc] init];
            if (item.usersType == UsersType_Me) {
                nameFont = BoldSystemFont(MessageFontSize);
            } else {
                nameFont = SystemFont(MessageFontSize);
            }
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ", item.sendName] font:nameFont color:roomStyleItem.riderStrColor]];
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:NSLocalizedString(@"Member_Join", @"Member_Join") font:SystemFont(MessageFontSize) color:roomStyleItem.riderStrColor]];
        } break;
            
        case MsgType_RiderJoin: {
            /** 座驾入场消息 **/
            // 姓名
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ", item.sendName] font:SystemFont(MessageFontSize) color:roomStyleItem.riderStrColor]];
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:NSLocalizedString(@"Member_RiderJoin", @"Member_RiderJoin"), item.riderName] font:SystemFont(MessageFontSize) color:roomStyleItem.riderStrColor]];
        } break;
        case MsgType_Talent: {
            /**才艺点播**/
            
        } break;
        default: {
        } break;
    }
    return attributeStr;
}

- (NSMutableAttributedString *)setupChatMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item {
    
    // 名称标签
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];
    [attributeStr appendAttributedString:[self addChatNameImage:item roomStyleItem:roomStyleItem]];
    
    // 内容
    [attributeStr appendAttributedString:[self parseMessage:item.text font:SystemFont(MessageFontSize) color:roomStyleItem.chatStrColor]];
    
    return attributeStr;
}

- (NSMutableAttributedString *)setupGiftMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item {
    // 名称标签
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];
    [attributeStr appendAttributedString:[self addChatNameImage:item roomStyleItem:roomStyleItem]];
    
    // 内容
    [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ \"%@\" ", NSLocalizedString(@"Member_SentGift", @"Member_SentGift"), item.giftName] font:SystemFont(MessageFontSize) color:roomStyleItem.sendStrColor]];
    // 图片图片
    [attributeStr appendAttributedString:[self parseGiftIcon:item.smallImgUrl]];
    // 礼物数量
    if (item.giftNum > 1) {
        [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@" x%d", item.giftNum]
                                                           font:SystemFont(MessageFontSize)
                                                          color:roomStyleItem.sendStrColor]];
    }
    return attributeStr;
}

// 添加标签图片
- (NSAttributedString *)addChatNameImage:(MsgItem *)item roomStyleItem:(RoomStyleItem *)styleItem {

    CGSize size = [item.sendName sizeWithAttributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:11] }];
    CGFloat width = size.width + 5 + 6; // 标签宽度 = 文本宽度 + label内边距 + label左右间隔
    LSChatNameView *view = [[LSChatNameView alloc] initWithFrame:CGRectMake(0, 0, width > 100 ? 100 : width, 19)];
    view.nameLabel.text = item.sendName;
    view.layer.cornerRadius = 4;
    view.layer.masksToBounds = YES;
    
    if (item.usersType == UsersType_Liver) {
        view.backgroundColor = COLOR_WITH_16BAND_RGB(0x00cc66);
    } else {
        view.backgroundColor = COLOR_WITH_16BAND_RGB(0xff9901);
    }
    
    // 视图转换高清图片
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:view.frame.size alignToFont:SystemFont(MessageFontSize) alignment:YYTextVerticalAlignmentCenter];
    [attributeString appendAttributedString:attachText];
    [attributeString appendAttributedString:[self parseMessage:@" " font:SystemFont(MessageFontSize) color:styleItem.myNameColor]];
    return attributeString;
}

// 添加礼物图片
- (NSMutableAttributedString *)parseGiftIcon:(NSString *)url {
    UIImageView *imageView = [[UIImageView alloc] init];
    [[LSImageViewLoader loader] loadImageWithImageView:imageView
                                               options:0
                                              imageUrl:url
                                      placeholderImage:
     [UIImage imageNamed:@"Live_Publish_Btn_Gift"]
                                         finishHandler:nil];
    
    imageView.frame = CGRectMake(0, 0, 17, 17);
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:SystemFont(MessageFontSize) alignment:YYTextVerticalAlignmentCenter];
    
    return attachText;
}

- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)];
    return attributeString;
}

- (NSAttributedString *)linkMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : textColor,
                                     NSUnderlineColorAttributeName : textColor,
                                     NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                     }
                             range:NSMakeRange(0, attributeString.length)];
    //    attributeString.yy_underlineStyle = NSUnderlineStyleSingle;
    return attributeString;
}

@end
