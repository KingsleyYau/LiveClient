//
//  HangoutMsgManager.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangoutMsgManager.h"
#import "LSImageViewLoader.h"

#define MessageFontSize 16
#define MessageFont  [UIFont systemFontOfSize:MessageFontSize]

#define GiftMessageFontSize 16
#define GiftMessageFont [UIFont boldSystemFontOfSize:GiftMessageFontSize]

@implementation HangoutMsgManager

- (NSMutableAttributedString *)setupChatMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item {
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];
    // 姓名颜色
    UIColor *sendNameColor = [[UIColor alloc] init];
    if (item.usersType == UsersType_Me) {
        sendNameColor = roomStyleItem.myNameColor;
    } else {
        sendNameColor = roomStyleItem.liverNameColor;
    }
    
//    if ( item.honorUrl.length > 0 ) {
//        UIImageView *honorImageView = [[UIImageView alloc] init];
//        [[LSImageViewLoader loader] loadImageWithImageView:honorImageView options:0 imageUrl:item.honorUrl placeholderImage:[UIImage imageNamed:@"Live_Medal_Nomal"]];
//
//        honorImageView.frame = CGRectMake(0, 0, 13, 14);
//        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:honorImageView contentMode:UIViewContentModeCenter attachmentSize:honorImageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
//        [attributeStr appendAttributedString:attachText];
//        [attributeStr appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
//    }
    
    // 开头样式
    [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ : ",item.sendName] font:MessageFont color:sendNameColor]];
    if (item.toName.length > 0) {
        item.text = [NSString stringWithFormat:@"@%@ %@",item.toName, item.text];
    } else if (item.nameArray.count > 0) {
        for (NSString *name in item.nameArray) {
            item.text = [NSString stringWithFormat:@"@%@ %@",name, item.text];
        }
    }
    // 内容
    [attributeStr appendAttributedString:[self parseMessage:item.text font:MessageFont color:roomStyleItem.chatStrColor]];
    
    return attributeStr;
}

- (NSMutableAttributedString *)setupGiftMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item {
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];
    // 姓名颜色
    UIColor *sendNameColor = [[UIColor alloc] init];
    UIColor *toNameColor = [[UIColor alloc] init];
    if (item.usersType == UsersType_Me) {
        sendNameColor = roomStyleItem.myNameColor;
        toNameColor = roomStyleItem.liverNameColor;
    } else {
        sendNameColor = roomStyleItem.liverNameColor;
        toNameColor = roomStyleItem.myNameColor;
    }
    
    if ( item.honorUrl.length > 0 ) {
        UIImageView *honorImageView = [[UIImageView alloc] init];
        [[LSImageViewLoader loader] loadImageWithImageView:honorImageView options:0 imageUrl:item.honorUrl placeholderImage:[UIImage imageNamed:@"Live_Medal_Nomal"]];
        
        honorImageView.frame = CGRectMake(0, 0, 13, 14);
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:honorImageView contentMode:UIViewContentModeCenter attachmentSize:honorImageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
        [attributeStr appendAttributedString:attachText];
        [attributeStr appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
    }
    
    // 开头样式
    [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.sendName] font:MessageFont color:sendNameColor]];
    
    switch (item.giftType) {
            
        case GIFTTYPE_BAR:{
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ %@ ", NSLocalizedString(@"Member_BarGift",@"Member_BarGift"), item.giftName] font:GiftMessageFont color:roomStyleItem.sendStrColor]];
            // 礼物图片
            [attributeStr appendAttributedString:[self parseGiftIcon:item.smallImgUrl]];
            // for
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@" %@",
                NSLocalizedString(@"Member_For",@"Member_For")] font:GiftMessageFont color:roomStyleItem.sendStrColor]];
            // ToName
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@" %@",item.toName] font:MessageFont color:toNameColor]];
            
        }break;
            
        case GIFTTYPE_CELEBRATE:{
            
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.giftName] font:GiftMessageFont color:roomStyleItem.sendStrColor]];
            // 礼物图片
//            [attributeStr appendAttributedString:[self parseGiftIcon:item.smallImgUrl]];
            
        }break;
            
        default:{
            if (item.toName.length > 0) {
                // 内容
                [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ %@ ",    NSLocalizedString(@"Member_SentGift",@"Member_SentGift"), item.giftName] font:GiftMessageFont color:roomStyleItem.sendStrColor]];
                // 礼物图片
                [attributeStr appendAttributedString:[self parseGiftIcon:item.smallImgUrl]];
                // to
                [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@" %@",
                                                                         NSLocalizedString(@"Member_To",@"Member_To")] font:GiftMessageFont color:roomStyleItem.sendStrColor]];
                // ToName
                [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@" %@",item.toName] font:MessageFont color:toNameColor]];
            } else {
                // 内容
                [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.giftName] font:GiftMessageFont color:roomStyleItem.sendStrColor]];
            }
        }break;
    }
    
    return attributeStr;
}

- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    return attributeString;
}

// 添加礼物图片
- (NSMutableAttributedString *)parseGiftIcon:(NSString *)url {
    UIImageView *imageView = [[UIImageView alloc] init];
    [[LSImageViewLoader loader] loadImageWithImageView:imageView options:0 imageUrl:url placeholderImage:
     [UIImage imageNamed:@"Live_Publish_Btn_Gift"]];
    
    imageView.frame = CGRectMake(0, 0, 20, 20);
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
    
    return attachText;
}

@end
