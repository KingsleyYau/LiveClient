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
#import "LSShadowView.h"
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
    [self.imageViewLoader loadImageWithImageView:self.chatHead options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:nil];
    
    self.chatName.text = item.userName;
    
    [self updateNameFrame:item.userName isChat:YES];
    
    self.chatMsg.attributedText = [self parseMessageTextEmotion:item.contentStr font:self.chatMsg.font];
        
    self.countdownLabel.text = @"Chat Now";
    self.colorView.image = nil;
    self.colorView.backgroundColor = COLOR_WITH_16BAND_RGB(0x21A225);
    self.scheduledTimeView.backgroundColor = COLOR_WITH_16BAND_RGB(0x5BC563);
}

- (void)loadLiveNotificationViewUI:(LSMainNotificaitonModel *)item {
    [[LSImageViewLoader loader] loadImageWithImageView:self.liveHead options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:nil];
    
    [[LSImageViewLoader loader] loadImageWithImageView:self.liveFriendHead options:SDWebImageRefreshCached imageUrl:item.friendUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:nil];
    
    self.liveName.text = [NSString stringWithFormat:@"%@'s circle",item.userName];
    [self updateNameFrame:self.liveName.text isChat:NO];
    
    self.liveMsg.text = item.contentStr;
    
    self.countdownLabel.text = @"Hang-out";
    
    CGRect msgRect = self.liveMsg.frame;
    msgRect.size.width = self.tx_width - msgRect.origin.x - self.scheduledTimeView.tx_width - 20;
    self.liveMsg.frame = msgRect;
    
 
    self.colorView.backgroundColor = [UIColor clearColor];
    self.colorView.image = [self gradientImageWithBounds:self.colorView.bounds andColors:@[COLOR_WITH_16BAND_RGB(0xFF5756),COLOR_WITH_16BAND_RGB(0xFF8500)] andGradientType:1];
    
    self.scheduledTimeView.backgroundColor = COLOR_WITH_16BAND_RGB(0xFDAC0D);
}

- (void)updateNameFrame:(NSString *)name isChat:(BOOL)isChat
{
    if (isChat) {
        CGRect nameRect = self.chatName.frame;
        nameRect.size.width = self.tx_width - (self.chatHead.tx_width +self.chatHead.tx_x) - self.scheduledTimeView.tx_width - 20;
        self.chatName.frame = nameRect;
        
        CGRect msgRect = self.chatMsg.frame;
        msgRect.size.width = self.tx_width - self.chatMsg.tx_x - self.scheduledTimeView.tx_width - 20;
        self.chatMsg.frame = msgRect;
    }else {
        CGRect nameRect = self.liveName.frame;
        nameRect.size.width = self.tx_width - (self.liveFriendHead.tx_width +self.liveFriendHead.tx_x) - self.scheduledTimeView.tx_width - 20;
        self.liveName.frame = nameRect;
        
        CGRect msgRect = self.liveMsg.frame;
        msgRect.size.width = self.tx_width - self.liveMsg.tx_x - self.scheduledTimeView.tx_width - 20;
        self.liveMsg.frame = msgRect;
    }
}

//- (void)updateMsgFrame:(NSString *)msg {
//    CGFloat msgStatusW = [msg sizeWithAttributes:@{NSFontAttributeName:self.msgStatus.font}].width;
//    CGRect msgStatusWRect = self.msgStatus.frame;
//    msgStatusWRect.size.width = msgStatusW;
//    self.msgStatus.frame = msgStatusWRect;
//
//
//    CGRect msgRect = self.chatMsg.frame;
//    msgRect.origin.x = msgStatusWRect.origin.x + msgStatusW;
//    msgRect.size.width = screenSize.width - msgRect.origin.x - 40;
//    self.chatMsg.frame = msgRect;
//}

- (void)startCountdown:(NSInteger)time {
    
    NSInteger countdownTime = [LSMainNotificationManager manager].timeOutNum;
    self.time = time + countdownTime;
    [self countdown];
}

- (void)countdown {
    
    self.countdownTime = [[NSDate date] timeIntervalSince1970];
    
    NSInteger countdownTime = [LSMainNotificationManager manager].timeOutNum;
    
    CGFloat percent = self.scheduledTimeView.frame.size.width / countdownTime;
    
    NSInteger times = self.time - self.countdownTime;
    
    CGRect rect = self.colorView.frame;
    rect.origin.x = 0.0f;
    rect.size.width = self.scheduledTimeView.frame.size.width - ((countdownTime - times) * percent);
    self.colorView.frame = rect;

    if (times <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
        });
    }
    [self performSelector:@selector(countdown) withObject:nil afterDelay:1];
}

#pragma mark - 自动替换表情
- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font {
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

    return attributeString;
    
}

- (UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors andGradientType:(int)gradientType{
    NSMutableArray *ar = [NSMutableArray array];
    
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, bounds.size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(bounds.size.width, 0.0);
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

@end
