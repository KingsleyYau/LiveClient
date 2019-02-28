//
//  MainNotificaitonCell.m
//  livestream
//
//  Created by Calvin on 2019/1/18.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "MainNotificaitonCell.h"
#import "QNChatTextAttachment.h"
#import "LSMainNotificationManager.h"
@implementation MainNotificaitonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.chatHead.layer.cornerRadius = self.chatHead.frame.size.width/2;
    self.chatHead.layer.masksToBounds = YES;
    
    self.liveHead.layer.cornerRadius = self.liveHead.frame.size.width/2;
    self.liveHead.layer.masksToBounds = YES;
    
    self.liveFriendHead.layer.cornerRadius = self.liveFriendHead.frame.size.width/2;
    self.liveFriendHead.layer.masksToBounds = YES;
    self.liveFriendHead.layer.borderColor = [UIColor whiteColor].CGColor;
    self.liveFriendHead.layer.borderWidth = 1;
    
    self.scheduledTimeView.layer.cornerRadius = 8;
    self.scheduledTimeView.layer.masksToBounds = YES;
}

+ (NSString *)cellIdentifier {
    return @"MainNotificaitonCell";
}

- (void)loadChatNotificationViewUI:(LSMainNotificaitonModel *)item
{
    //self.item = user;
    [self.imageViewLoader stop];
    // 头像
    // 显示默认头像
    [self.chatHead setImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    // 创建新的
    self.imageViewLoader = [LSImageViewLoader loader];
    
    // 加载
    [self.imageViewLoader loadImageWithImageView:self.chatHead options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    self.chatName.text = item.userName;
    
    [self updateNameFrame:item.userName];
    
//    NSString * newStr = @"";
//    //是否inChat
//    if (item.isInChat) {
//        self.msgStatus.text = @"[New]";
//        [self updateMsgFrame:self.msgStatus.text];
//        self.chatName.textColor = Color(252, 91, 7, 255);
//        self.onlineImage.image = [UIImage imageNamed:@"LS_ChatList_InChatIcon"];
//    }
//    else
//    {
//        self.msgStatus.text = @"[Invitation]";
//        [self updateMsgFrame:self.msgStatus.text];
//        self.chatName.textColor = [UIColor blackColor];
//        self.onlineImage.image = nil;
//    }
    
   // self.chatMsg.attributedText = [self parseMessageTextEmotion:item.contentStr newMessage:newStr font:self.chatMsg.font];
    
    self.chatMsg.text = item.contentStr;
    
    self.countdownLabel.text = @"Chat Now";
    
    self.colorView.backgroundColor = COLOR_WITH_16BAND_RGB(0x21A225);
    self.scheduledTimeView.backgroundColor = COLOR_WITH_16BAND_RGB(0x5BC563);
}

- (void)loadLiveNotificationViewUI:(LSMainNotificaitonModel *)item {
    
    [[LSImageViewLoader loader] loadImageWithImageView:self.liveHead options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    [[LSImageViewLoader loader] loadImageWithImageView:self.liveFriendHead options:SDWebImageRefreshCached imageUrl:item.friendUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    self.liveName.text = [NSString stringWithFormat:@"%@'s circle",item.userName];
    
    self.liveMsg.text = item.contentStr;
    
    self.countdownLabel.text = @"Hang-out";
    
    CGRect msgRect = self.liveMsg.frame;
    msgRect.size.width = self.tx_width - msgRect.origin.x - self.scheduledTimeView.tx_width - 20;
    self.liveMsg.frame = msgRect;
    
    self.colorView.backgroundColor = COLOR_WITH_16BAND_RGB(0xFC1615);
    self.scheduledTimeView.backgroundColor = COLOR_WITH_16BAND_RGB(0xFDAC0D);
}

- (void)updateNameFrame:(NSString *)name
{
    CGSize nameSize = CGSizeMake(screenSize.width, self.chatName.frame.size.height);
    
    CGRect rect = [name boundingRectWithSize:nameSize options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.chatName.font} context:nil];
    
    CGFloat w =  ceil(rect.size.width);
    
    CGRect nameRect = self.chatName.frame;
    nameRect.size.width = w + 10;
    self.chatName.frame = nameRect;
    
    CGRect msgRect = self.chatMsg.frame;
    msgRect.size.width = self.tx_width - msgRect.origin.x - self.scheduledTimeView.tx_width - 20;
    self.chatMsg.frame = msgRect;
}

- (void)updateMsgFrame:(NSString *)msg {
    CGFloat msgStatusW = [msg sizeWithAttributes:@{NSFontAttributeName:self.msgStatus.font}].width;
    CGRect msgStatusWRect = self.msgStatus.frame;
    msgStatusWRect.size.width = msgStatusW;
    self.msgStatus.frame = msgStatusWRect;
    

    CGRect msgRect = self.chatMsg.frame;
    msgRect.origin.x = msgStatusWRect.origin.x + msgStatusW;
    msgRect.size.width = screenSize.width - msgRect.origin.x - 40;
    self.chatMsg.frame = msgRect;
}

- (void)startCountdown:(NSInteger)time {
    
    CGFloat countdownTime = [LSMainNotificationManager manager].timeOutNum;
    self.time = time + countdownTime;

    [self countdown];
}

- (void)countdown {
    
    self.countdownTime = [[NSDate date] timeIntervalSince1970];
    
    CGFloat countdownTime = [LSMainNotificationManager manager].timeOutNum;
    
    CGFloat percent = self.scheduledTimeView.frame.size.width / countdownTime;
    
    NSInteger times = self.time - self.countdownTime;
    
    self.colorView.frame = CGRectMake(0, 0,self.scheduledTimeView.frame.size.width - ((countdownTime - times) * percent), self.scheduledTimeView.frame.size.height);
    
    [self performSelector:@selector(countdown) withObject:nil afterDelay:1];
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
    
    NSString* emotionOriginalString = nil;
    NSString* emotionString = nil;
    NSAttributedString* emotionAttString = nil;
    QNChatTextAttachment *attachment = nil;
    UIImage* image = nil;
    
    NSString* findString = attributeString.string;
    
    // 替换img
    while (
           (range = [findString rangeOfString:@"[img:"]).location != NSNotFound &&
           (endRange = [findString rangeOfString:@"]"]).location != NSNotFound &&
           range.location < endRange.location
           ) {
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
    
    [attributeString addAttributes:@{NSFontAttributeName : font} range:NSMakeRange(0, attributeString.length)];
    
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithString:message];
    
    [newString appendAttributedString:attributeString];
    
    [newString addAttribute:NSForegroundColorAttributeName value:Color(252, 91, 7, 255) range:[newString.string rangeOfString:message]];
    
    return newString;
    
}
@end
