//
//  LiveRoomMsgManager.m
//  livestream
//
//  Created by randy on 2017/8/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoomMsgManager.h"
#import "LSImageViewLoader.h"

#define MessageFontSize 16
#define MessageFont  [UIFont systemFontOfSize:MessageFontSize]

#define GiftMessageFontSize 16
#define GiftMessageFont [UIFont boldSystemFontOfSize:GiftMessageFontSize]
//[UIFont fontWithName:@"AvenirNext-DemiBold" size:MessageFontSize]
//[UIFont fontWithName:@"AvenirNext-Bold" size:GiftMessageFontSize]

@interface LiveRoomMsgManager ()
@property (nonatomic, strong) LSImageViewLoader *loader;
@end

@implementation LiveRoomMsgManager

- (NSMutableAttributedString *)presentTheRoomStyleItem:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item{
    
    NSMutableAttributedString *attributeStr;
    
    if (item.msgType != MsgType_Join) {
        attributeStr = [[NSMutableAttributedString alloc] initWithString:@""];
        
    }else {
        attributeStr = [[NSMutableAttributedString alloc] init];
    }
    
//    if ( item.honorUrl.length > 0 ) {
//        UIImageView *honorImageView = [[UIImageView alloc] init];
//        [self.loader loadImageWithImageView:honorImageView options:0 imageUrl:item.honorUrl placeholderImage:[UIImage imageNamed:@"Live_Medal_Nomal"]];
//
//        honorImageView.frame = CGRectMake(0, 0, 13, 14);
//        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:honorImageView contentMode:UIViewContentModeCenter attachmentSize:honorImageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
//        [attributeStr appendAttributedString:attachText];
//        [attributeStr appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
//    }
    
    // 姓名颜色
    UIColor *nameColor = [[UIColor alloc] init];
    if (item.usersType == UsersType_Me) {
        nameColor = roomStyleItem.myNameColor;
    } else if (item.usersType == UsersType_Liver) {
        nameColor = roomStyleItem.liverNameColor;
    } else {
        nameColor = roomStyleItem.userNameColor;
    }
    
    switch (item.msgType) {
        case MsgType_Announce:{
            /** 普通公告 **/
            [attributeStr appendAttributedString:[self parseMessage:item.text font:MessageFont color:roomStyleItem.announceStrColor]];
        }break;
            
        case MsgType_Link:{
            /** 带链接公告 **/
            [attributeStr appendAttributedString:[self linkMessage:item.text font:MessageFont color:roomStyleItem.announceStrColor]];
        }break;
        
        case MsgType_Warning:{
            /** 警告提示 **/
            [attributeStr appendAttributedString:[self parseMessage:item.text font:MessageFont color:roomStyleItem.warningStrColor]];
        }break;
            
        case MsgType_Join:{
            /** 入场消息 **/
            
            //是否购票
            if (item.isHasTicket && item.usersType != UsersType_Liver) {
            [attributeStr appendAttributedString:[self addShowIconImage:item roomStyleItem:roomStyleItem]];
            }
            // 姓名
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.sendName] font:MessageFont color:nameColor]];
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:NSLocalizedString(@"Member_Join",@"Member_Join") font:MessageFont color:roomStyleItem.riderStrColor]];
        }break;
            
        case MsgType_RiderJoin:{
            /** 座驾入场消息 **/
            
            //是否购票
            if (item.isHasTicket) {
            [attributeStr appendAttributedString:[self addShowIconImage:item roomStyleItem:roomStyleItem]];
            }
            // 姓名
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.sendName] font:MessageFont color:nameColor]];
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Member_RiderJoin",@"Member_RiderJoin"), item.riderName]  font:MessageFont color:roomStyleItem.riderStrColor]];
        }break;
        case MsgType_Talent: {
            /**才艺点播**/
            
        }break;
        default:{
        }break;
    }

    return attributeStr;
}

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

- (NSAttributedString *)linkMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor,
                                     NSUnderlineColorAttributeName:textColor,
                                     NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
//    attributeString.yy_underlineStyle = NSUnderlineStyleSingle;
    return attributeString;
}

@end
