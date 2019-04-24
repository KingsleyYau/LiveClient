//
//  LadyListNotificationView.m
//  dating
//
//  Created by Calvin on 16/12/20.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNLadyListNotificationView.h"
#import "QNChatTextAttachment.h"

#define HideAnmationTime 5

@interface QNLadyListNotificationView ()
@property (nonatomic, strong) LSLCLiveChatUserItemObject *item;
@end

@implementation QNLadyListNotificationView

+ (instancetype)initLadyListNotificationViewXibLoadUser:(LSLCLiveChatUserItemObject *)user msg:(NSString *)msg msgItem:(LSLCLiveChatMsgItemObject *)item {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"QNLadyListNotificationView" owner:nil options:nil];
    QNLadyListNotificationView *view = [nibs objectAtIndex:0];
    [view loadUser:user msg:msg msgItem:item];
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)updateNameFrame:(NSString *)name {
    CGSize nameSize = CGSizeMake(screenSize.width, self.nameLabel.frame.size.height);

    CGRect rect = [name boundingRectWithSize:nameSize options:NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : self.nameLabel.font } context:nil];

    CGFloat w = ceil(rect.size.width);

    CGRect nameRect = self.nameLabel.frame;
    nameRect.size.width = w + 10;
    self.nameLabel.frame = nameRect;

    CGRect iconRect = self.chatIcon.frame;
    iconRect.origin.x = nameRect.origin.x + w + 10;
    self.chatIcon.frame = iconRect;
}

- (void)updateMsgFrame:(NSString *)msg {
    CGFloat msgStatusW = [msg sizeWithAttributes:@{NSFontAttributeName : self.msgStatus.font}].width;
    CGRect msgStatusWRect = self.msgStatus.frame;
    msgStatusWRect.size.width = msgStatusW;
    self.msgStatus.frame = msgStatusWRect;

    CGRect camshareRect = self.camshareInviteIcon.frame;
    if (self.camshareInviteIcon.image) {
        camshareRect.origin.x = msgStatusWRect.origin.x + msgStatusW;
        camshareRect.size = CGSizeMake(12, 12);
        self.camshareInviteIcon.frame = camshareRect;
    } else {
        camshareRect.origin.x = msgStatusWRect.origin.x + msgStatusW;
        camshareRect.size = CGSizeMake(0, 0);
        self.camshareInviteIcon.frame = camshareRect;
    }

    CGRect msgRect = self.msgLabel.frame;
    msgRect.origin.x = msgStatusWRect.origin.x + msgStatusW + camshareRect.size.width;
    msgRect.size.width = screenSize.width - msgRect.origin.x - 40;
    self.msgLabel.frame = msgRect;
}

- (void)loadUser:(LSLCLiveChatUserItemObject *)user msg:(NSString *)msg msgItem:(LSLCLiveChatMsgItemObject *)item {
    self.item = user;
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.frame.size.width / 2;
    self.ladyImageView.layer.masksToBounds = YES;

    self.imageViewLoader = nil;
    // 头像
    // 显示默认头像
    [self.ladyImageView setImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    // 创建新的
    self.imageViewLoader = [LSImageViewLoader loader];

    // 加载
    [self.imageViewLoader loadImageWithImageView:self.ladyImageView options:SDWebImageRefreshCached imageUrl:user.imageUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:nil];
    self.nameLabel.text = user.userName;
    [self updateNameFrame:user.userName];

    NSString *newStr = @"";
    //是否inChat
    if ([[LSLiveChatManagerOC manager] isChatingUserInChatState:user.userId]) {
        //        newStr = @"[New]";
        self.msgStatus.text = @"[New]";
        [self updateMsgFrame:self.msgStatus.text];
        self.nameLabel.textColor = Color(252, 91, 7, 255);
        self.chatIcon.image = [UIImage imageNamed:@"LS_ChatList_InChatIcon"];
        //        //是否在CamShare
        //        if ([[LSLiveChatManagerOC manager] isCamshareInChat:user.userId]) {
        //            self.chatIcon.image = [UIImage imageNamed:@"ChatList_CamShareIcon"];
        //        }
    } else {
        self.msgStatus.text = @"[Invitation]";
        if (item.inviteType == IniviteTypeChat) {
            self.camshareInviteIcon.image = nil;
        } else {
            //self.camshareInviteIcon.image = [UIImage imageNamed:@"chatlist_cam_b"];
        }
        [self updateMsgFrame:self.msgStatus.text];
        self.nameLabel.textColor = [UIColor blackColor];

        self.chatIcon.image = nil;
    }

    self.msgLabel.attributedText = [self parseMessageTextEmotion:msg newMessage:newStr font:self.msgLabel.font];

    [UIView animateWithDuration:0.3
        animations:^{
            self.alpha = 1;
        }
        completion:^(BOOL finished) {
            [self performSelector:@selector(removeNotificationView) withObject:nil afterDelay:HideAnmationTime];
        }];
}

- (IBAction)cancalNotication:(id)sender {
    [self removeNotificationView];
    if ([self.delegate respondsToSelector:@selector(LadyListNotificationViewDidToChat:)]) {
        [self.delegate LadyListNotificationViewDidToChat:self.item];
    }
}

- (IBAction)closeBtnDid:(UIButton *)sender {
    [self removeNotificationView];
}

- (void)removeNotificationView {
    if (self) {
        [UIView animateWithDuration:0.3
            animations:^{
                self.alpha = 0;
            }
            completion:^(BOOL finished) {
                [self.imageViewLoader stop];
                self.imageViewLoader = nil;
                [self removeFromSuperview];
            }];
    }
}

#pragma mark - 自动替换表情
- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text newMessage:(NSString *)message font:(UIFont *)font {
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

    [attributeString addAttributes:@{ NSFontAttributeName : font } range:NSMakeRange(0, attributeString.length)];

    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithString:message];

    [newString appendAttributedString:attributeString];

    [newString addAttribute:NSForegroundColorAttributeName value:Color(252, 91, 7, 255) range:[newString.string rangeOfString:message]];

    return newString;
    
}
@end
