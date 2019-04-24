//
//  PublicPrativeMsgManager.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PublicPrativeMsgManager.h"
#import "LSImageViewLoader.h"

#define MessageFontSize 16
#define MessageFont [UIFont systemFontOfSize:MessageFontSize]

#define GiftMessageFontSize 16
#define GiftMessageFont [UIFont boldSystemFontOfSize:GiftMessageFontSize]

@implementation PublicPrativeMsgManager

- (NSMutableAttributedString *)setupChatMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item {

    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];

    // 姓名颜色
    UIColor *sendNameColor = [[UIColor alloc] init];
    if (item.usersType == UsersType_Me) {
        sendNameColor = roomStyleItem.myNameColor;

    } else if (item.usersType == UsersType_Liver) {
        sendNameColor = roomStyleItem.liverNameColor;
        [attributeStr appendAttributedString:[self addLiverTypeImage:item roomStyleItem:roomStyleItem]];

    } else {
        sendNameColor = roomStyleItem.userNameColor;
    }

    //是否购票
    if (item.isHasTicket) {
        [attributeStr appendAttributedString:[self addShowIconImage:item roomStyleItem:roomStyleItem]];
    }
    // 开头样式
    [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ : ", item.sendName] font:MessageFont color:sendNameColor]];
    // 内容
    [attributeStr appendAttributedString:[self parseMessage:item.text font:MessageFont color:roomStyleItem.chatStrColor]];

    return attributeStr;
}

- (NSMutableAttributedString *)setupGiftMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item {

    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];

    // 姓名颜色
    UIColor *sendNameColor = [[UIColor alloc] init];
    if (item.usersType == UsersType_Me) {
        sendNameColor = roomStyleItem.myNameColor;

    } else if (item.usersType == UsersType_Liver) {
        sendNameColor = roomStyleItem.liverNameColor;
        [attributeStr appendAttributedString:[self addLiverTypeImage:item roomStyleItem:roomStyleItem]];

    } else {
        sendNameColor = roomStyleItem.userNameColor;
    }

    if (item.honorUrl.length > 0) {
        UIImageView *honorImageView = [[UIImageView alloc] init];
        [[LSImageViewLoader loader] loadImageWithImageView:honorImageView options:0 imageUrl:item.honorUrl placeholderImage:[UIImage imageNamed:@"Live_Medal_Nomal"] finishHandler:nil];

        honorImageView.frame = CGRectMake(0, 0, 13, 14);
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:honorImageView contentMode:UIViewContentModeCenter attachmentSize:honorImageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
        [attributeStr appendAttributedString:attachText];
        [attributeStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }

    //是否购票
    if (item.isHasTicket) {
        [attributeStr appendAttributedString:[self addShowIconImage:item roomStyleItem:roomStyleItem]];
    }
    // 开头样式
    [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ", item.sendName] font:MessageFont color:sendNameColor]];
    // 内容
    [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ %@ ", NSLocalizedString(@"Member_SentGift", @"Member_SentGift"), item.giftName] font:GiftMessageFont color:roomStyleItem.sendStrColor]];
    // 图片图片
    [attributeStr appendAttributedString:[self parseGiftIcon:item.smallImgUrl]];
    // 礼物数量
    if (item.giftNum > 1) {
        [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@" x%d", item.giftNum]
                                                           font:GiftMessageFont
                                                          color:roomStyleItem.sendStrColor]];
    }

    return attributeStr;
}

// 添加主播标签图片
- (NSAttributedString *)addLiverTypeImage:(MsgItem *)item roomStyleItem:(RoomStyleItem *)styleItem {

    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:styleItem.liverTypeImage];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    imageView.frame = CGRectMake(0, 0, 62, 21);
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
    if (item.msgType == MsgType_Gift) {
        [attributeString appendAttributedString:[self parseMessage:@" " font:MessageFont color:styleItem.myNameColor]];
    }
    [attributeString appendAttributedString:attachText];
    [attributeString appendAttributedString:[self parseMessage:@" " font:MessageFont color:styleItem.myNameColor]];

    return attributeString;
}

// 添加买票图片
- (NSAttributedString *)addShowIconImage:(MsgItem *)item roomStyleItem:(RoomStyleItem *)styleItem {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:styleItem.buyTicketImage];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    imageView.frame = CGRectMake(0, 0, 18, 18);
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
    if (item.msgType == MsgType_Gift) {
        [attributeString appendAttributedString:[self parseMessage:@" " font:MessageFont color:styleItem.myNameColor]];
    }
    [attributeString appendAttributedString:attachText];
    [attributeString appendAttributedString:[self parseMessage:@" " font:MessageFont color:styleItem.myNameColor]];

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

    imageView.frame = CGRectMake(0, 0, 20, 20);
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];

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


@end
