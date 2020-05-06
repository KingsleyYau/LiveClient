//
//  MsgTableViewCell.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "MsgTableViewCell.h"
#import "NSAttributedString+YYText.h"

@interface MsgTableViewCell ()

@property (nonatomic, strong) UIButton *tapBtn;
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, strong) UIView *textBackgroundView;
@end


@implementation MsgTableViewCell
+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textBackgroundView = [[UIView alloc] init];
        self.textBackgroundView.hidden = YES;
        self.textBackgroundView.clipsToBounds = YES;
        [self addSubview:self.textBackgroundView];
        
        self.messageLabel = [YYLabel new];
        self.messageLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH - 165, 0);
        self.messageLabel.displaysAsynchronously = YES;
        [self addSubview:self.messageLabel];
        
        [self.textBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.messageLabel.mas_right).offset(4);
            make.top.equalTo(@1);
            make.bottom.equalTo(@(-1));
        }];
        
        self.tapBtn = [[UIButton alloc] init];
        self.tapBtn.backgroundColor = [UIColor clearColor];
        [self.tapBtn addTarget:self action:@selector(pushGoAction) forControlEvents:UIControlEventTouchUpInside];
        self.tapBtn.hidden = YES;
        [self addSubview:self.tapBtn];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.messageLabelWidth = 0;
        self.messageLabelHeight = 0;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updataChatMessage:(MsgItem *)item styleItem:(RoomStyleItem *)styleItem {
    
    self.textBackgroundView.backgroundColor = styleItem.sendBackgroundViewColor;
    
    // 礼物label重算frame值
    CGRect giftFrame = item.labelFrame;
    if (item.msgType == MsgType_Gift) {
        self.textBackgroundView.hidden = NO;
        giftFrame.origin.x = 3;
    } else {
        self.textBackgroundView.hidden = YES;
        giftFrame.origin.x = 0;
    }
    
    self.messageLabel.frame = giftFrame;
    self.messageLabel.textLayout = item.layout;
    self.messageLabel.shadowColor = Color(0, 0, 0, 0.7);
    self.messageLabel.shadowOffset = CGSizeMake(0, 0.5);
    self.messageLabel.shadowBlurRadius = 1.0f;
    self.messageLabelWidth = self.messageLabel.frame.size.width;
    self.messageLabelHeight = self.messageLabel.frame.size.height;
   
    if (item.msgType == MsgType_Link) {
        self.tapBtn.hidden = NO;
        [self.tapBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(self.messageLabelWidth));
            make.left.top.height.equalTo(self);
        }];
        self.linkUrl = item.linkStr;
    } else {
        self.tapBtn.hidden = YES;
    }
}

- (void)setupChatMessage:(MsgItem *)item styleItem:(RoomStyleItem *)styleItem {
    
    self.textBackgroundView.hidden = NO;
    self.tapBtn.hidden = YES;
    
    // 礼物label重算frame值
    CGRect giftFrame = item.labelFrame;
    if (item.msgType == MsgType_Gift || item.msgType == MsgType_Chat) {
        giftFrame.origin.x = 3;
    } else {
        giftFrame.origin.x = 8;
    }
    
    self.messageLabel.frame = giftFrame;
    self.messageLabel.textLayout = item.layout;
    self.messageLabel.shadowColor = Color(0, 0, 0, 0.7);
    self.messageLabel.shadowOffset = CGSizeMake(0, 0.5);
    self.messageLabel.shadowBlurRadius = 1.0f;
    self.messageLabelWidth = self.messageLabel.frame.size.width;
    self.messageLabelHeight = self.messageLabel.frame.size.height;
    
    [self.textBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.messageLabel.mas_right).offset(8);
        make.bottom.equalTo(@(-5));
    }];
    
    switch (item.msgType) {
        case MsgType_Chat:{
            self.textBackgroundView.backgroundColor = styleItem.chatBackgroundViewColor;
        }break;
            
        case MsgType_Gift:{
            self.textBackgroundView.backgroundColor = styleItem.sendBackgroundViewColor;
        }break;
            
        case MsgType_Link:{
            self.textBackgroundView.backgroundColor = styleItem.announceBackgroundViewColor;
            self.tapBtn.hidden = NO;
            [self.tapBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.textBackgroundView);
            }];
            self.linkUrl = item.linkStr;
        }break;
            
        case MsgType_Announce:{
            self.textBackgroundView.backgroundColor = styleItem.announceBackgroundViewColor;
        }break;
            
        case MsgType_Join:
        case MsgType_RiderJoin:{
            self.textBackgroundView.backgroundColor = styleItem.riderBackgroundViewColor;
        }break;
            
        case MsgType_Warning:{
            self.textBackgroundView.backgroundColor = styleItem.warningBackgroundViewColor;
        }break;
            
        case MsgType_FirstFree:
        case MsgType_Public_FirstFree:{
            self.textBackgroundView.backgroundColor = styleItem.firstFreeBackgroundViewColor;
        }break;
            
        default:{
            self.textBackgroundView.backgroundColor = [UIColor clearColor];
        }break;
    }
}

- (void)pushGoAction {
    if ([self.msgDelegate respondsToSelector:@selector(msgCellRequestHttp:)]) {
        [self.msgDelegate msgCellRequestHttp:self.linkUrl];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textBackgroundView.layer.cornerRadius = 5;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}


@end
