//
//  LiveRoomMsgManager.m
//  livestream
//
//  Created by randy on 2017/8/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoomMsgManager.h"
#import "LSImageViewLoader.h"

#define NameFontSize 14
#define NameFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:NameFontSize]

#define MessageFontSize 16
#define MessageFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:MessageFontSize]

@interface LiveRoomMsgManager ()
@property (nonatomic, strong) LSImageViewLoader *loader;
@end

@implementation LiveRoomMsgManager

+ (instancetype)msgManager {

    static LiveRoomMsgManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[LiveRoomMsgManager alloc] init];
        manager.loader = [LSImageViewLoader loader];
    });
    
    return manager;
}

- (NSMutableAttributedString *)presentTheRoomStyleItem:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item{
    
    
    NSMutableAttributedString *attributeStr;
    
    if (item.type != MsgType_Join) {
        attributeStr = [[NSMutableAttributedString alloc] initWithString:@""];
        
    }else {
        attributeStr = [[NSMutableAttributedString alloc] init];
    }
    
    if ( item.honorUrl.length > 0 && item.honorUrl != nil ) {
        UIImageView *honorImageView = [[UIImageView alloc] init];
        [self.loader loadImageWithImageView:honorImageView options:0 imageUrl:item.honorUrl placeholderImage:[UIImage imageNamed:@"Live_ medal_nomal"]];
        
        honorImageView.frame = CGRectMake(0, 0, 13, 14);
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:honorImageView contentMode:UIViewContentModeCenter attachmentSize:honorImageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
        [attributeStr appendAttributedString:attachText];
        [attributeStr appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
    }
    
    switch (item.type) {
        case MsgType_Announce:
            // 普通公告
            [attributeStr appendAttributedString:[self parseMessage:item.text font:MessageFont color:roomStyleItem.announceStrColor]];
            
            break;
            
        case MsgType_Link:
            // 带链接公告
            [attributeStr appendAttributedString:[self linkMessage:item.text font:MessageFont color:roomStyleItem.announceStrColor]];
            
            break;
        
        case MsgType_Warning:
            // 警告提示
            [attributeStr appendAttributedString:[self parseMessage:NSLocalizedString(@"ANNOUNCE_WARNING",@"ANNOUNCE_WARNING") font:MessageFont color:roomStyleItem.warningStrColor]];
            [attributeStr appendAttributedString:[self parseMessage:item.text font:MessageFont color:roomStyleItem.warningStrColor]];
            
            break;
            
        case MsgType_Chat:
            // 名字
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ : ",item.name] font:NameFont color:roomStyleItem.nameColor]];
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:item.text font:MessageFont color:roomStyleItem.chatStrColor]];
            
            break;
        
        case MsgType_Follow:
            // 名字
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.name] font:NameFont color:roomStyleItem.nameColor]];
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:NSLocalizedString(@"Member_Follow",@"Member_Follow") font:MessageFont color:roomStyleItem.followStrColor]];
            
            break;
            
        case MsgType_Gift:
            // 名字
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.name] font:NameFont color:roomStyleItem.nameColor]];
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ %@ ", NSLocalizedString(@"Member_SentGift",@"Member_SentGift"), item.giftName] font:MessageFont color:roomStyleItem.sendStrColor]];
            
            break;
            
        case MsgType_Join:
            // 名字
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.name] font:NameFont color:roomStyleItem.nameColor]];
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:NSLocalizedString(@"Member_Join",@"Member_Join") font:MessageFont color:roomStyleItem.chatStrColor]];
            
            break;
            
        case MsgType_RiderJoin:
            // 名字
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.name] font:NameFont color:roomStyleItem.riderStrColor]];
            // 内容
            [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Member_RiderJoin",@"Member_RiderJoin"), item.riderName]  font:MessageFont color:roomStyleItem.riderStrColor]];
            
            break;
            
        case MsgType_Share:
            
            break;
            
        default:
            break;
    }

    // 拼送礼图片
    if (item.type == MsgType_Gift) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.loader loadImageWithImageView:imageView options:0 imageUrl:item.smallImgUrl placeholderImage:
         [UIImage imageNamed:@"Live_Publish_Btn_Gift"]];
        
        imageView.frame = CGRectMake(0, 0, 21, 21);
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
        [attributeStr appendAttributedString:attachText];
        [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@" x%d", item.giftNum]
                                                           font:MessageFont
                                                          color:roomStyleItem.sendStrColor]];
        
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

- (NSAttributedString *)linkMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor,
                                     NSUnderlineColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    attributeString.yy_underlineStyle = NSUnderlineStyleSingle;
    return attributeString;
}

@end
