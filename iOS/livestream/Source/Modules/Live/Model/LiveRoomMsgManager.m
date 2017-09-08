//
//  LiveRoomMsgManager.m
//  livestream
//
//  Created by randy on 2017/8/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoomMsgManager.h"


#define NameFontSize 14
#define NameFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:NameFontSize]

#define MessageFontSize 16
#define MessageFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:MessageFontSize]

#define Member_Join @"Joined"
#define Member_Follow @"is following the broadcaster"
#define Member_SentGift @"sent"



@implementation LiveRoomMsgManager

+ (instancetype)msgManager {

    static LiveRoomMsgManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[LiveRoomMsgManager alloc] init];
    });
    
    return manager;
}

- (NSMutableAttributedString *)presentTheSetStringItem:(SetStringItem *)strItem msgItem:(MsgItem *)item{
    
    
    NSMutableAttributedString *attributeStr;
    
    if (item.type != MsgType_Join) {
        attributeStr = [[NSMutableAttributedString alloc] initWithString:@""];
        
    }else{
        attributeStr = [[NSMutableAttributedString alloc] init];
    }
    
    // 拼名字
    if (item.type == MsgType_Chat) {
        [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ : ",item.name] font:NameFont color:strItem.nameColor]];
    }else{
        [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ ",item.name] font:NameFont color:strItem.nameColor]];
    }
    
    // 拼内容
    if (item.type == MsgType_Follow) {
        
        [attributeStr appendAttributedString:[self parseMessage:Member_Follow font:MessageFont color:strItem.followStrColor]];
    } else if (item.type == MsgType_Gift) {
        
        [attributeStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ %@ ", Member_SentGift, item.giftName] font:MessageFont color:strItem.sendStrColor]];
        
    } else if (item.type == MsgType_Join) {
        
        [attributeStr appendAttributedString:[self parseMessage:Member_Join font:MessageFont color:strItem.chatStrColor]];
    } else if (item.text != nil) {
        
        [attributeStr appendAttributedString:[self parseMessage:item.text font:MessageFont color:strItem.chatStrColor]];
    }
    
    
    if (item.type == MsgType_Gift) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView sd_setImageWithURL:[NSURL URLWithString:item.smallImgUrl] placeholderImage:[UIImage imageNamed:@"Live_Publish_Btn_Gift"] options:0];
        imageView.frame = CGRectMake(0, 0, 15, 15);
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:MessageFont alignment:YYTextVerticalAlignmentCenter];
        [attributeStr appendAttributedString:attachText];
        
        if (item.giftNum > 1) {
            [attributeStr appendAttributedString:[self parseMessage:
                                                  [NSString stringWithFormat:@" x%d", item.giftNum]
                                                               font:MessageFont
                                                              color:strItem.sendStrColor]];
        }
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

@end
