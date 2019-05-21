//
//  HotTableViewCell.m
//  livestream
//
//  Created by Max on 13-9-5.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import "HotTableViewCell.h"
#import "LiveBundle.h"
#import "LSShadowView.h"
#import <YYText.h>

@implementation HotTableViewCell
+ (NSString *)cellIdentifier {
    return @"HotTableViewCell";
}

+ (NSInteger)cellHeight {
    return screenSize.width;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    HotTableViewCell *cell = (HotTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[HotTableViewCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"HotTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.animationArray = [NSMutableArray array];
        cell.imageViewLoader = [LSImageViewLoader loader];
        cell.imageViewHeader.image = nil;
        cell.labelRoomTitle.text = @"";
        [cell setExclusiveTouch:YES];
        
        cell.sendMailBtn.layer.cornerRadius = cell.sendMailBtn.frame.size.height * 0.5f;
        cell.sendMailBtn.layer.masksToBounds = YES;
        cell.vipPrivateBtn.layer.cornerRadius = cell.vipPrivateBtn.frame.size.height * 0.5f;
        cell.vipPrivateBtn.layer.masksToBounds = YES;
        cell.bookPrivateBtn.layer.cornerRadius = cell.bookPrivateBtn.frame.size.height * 0.5f;
        cell.bookPrivateBtn.layer.masksToBounds = YES;
        cell.chatNowBtn.layer.cornerRadius = cell.chatNowBtn.frame.size.height * 0.5f;
        cell.chatNowBtn.layer.masksToBounds = YES;
        cell.viewPublicFeeBtn.layer.cornerRadius = cell.viewPublicFeeBtn.frame.size.height * 0.5f;
        cell.viewPublicFeeBtn.layer.masksToBounds = YES;
        cell.viewPublicFreeBtn.layer.cornerRadius = cell.viewPublicFreeBtn.frame.size.height * 0.5f;
        cell.viewPublicFreeBtn.layer.masksToBounds = YES;
        
        cell.liveStatusView.layer.cornerRadius = cell.liveStatusView.frame.size.height * 0.5f;
        cell.liveStatusView.layer.masksToBounds = YES;
        
        cell.onlineStatus.layer.cornerRadius = cell.onlineStatus.frame.size.height * 0.5f;
        cell.onlineStatus.layer.masksToBounds = YES;
        
        CGFloat shadowHeight = screenSize.width / 2.5f;
        cell.shadowHeight.constant = shadowHeight;
        
        LSShadowView *shadow = [[LSShadowView alloc] init];
        [shadow showShadowAddView:cell.sendMailBtn];
        
        LSShadowView *shadow1 = [[LSShadowView alloc] init];
        [shadow1 showShadowAddView:cell.vipPrivateBtn];
        
        LSShadowView *shadow2 = [[LSShadowView alloc] init];
        [shadow2 showShadowAddView:cell.bookPrivateBtn];
        
        LSShadowView *shadow3 = [[LSShadowView alloc] init];
        [shadow3 showShadowAddView:cell.chatNowBtn];
        
        LSShadowView *shadow4 = [[LSShadowView alloc] init];
        [shadow4 showShadowAddView:cell.viewPublicFeeBtn];
        
        LSShadowView *shadow5 = [[LSShadowView alloc] init];
        [shadow5 showShadowAddView:cell.viewPublicFreeBtn];
        
        NSString * str = @"";
        CGSize size = cell.titleView.frame.size;
        cell.scrollLabelView = [TXScrollLabelView scrollWithTitle:str type:TXScrollLabelViewTypeLeftRight velocity:1 options:UIViewAnimationOptionCurveEaseInOut];
        cell.scrollLabelView.frame = CGRectMake(0, 0, size.width, size.height);
        cell.scrollLabelView.scrollInset = UIEdgeInsetsMake(0, 10 , 0, 10);
        cell.scrollLabelView.tx_centerX  = SCREEN_WIDTH/2 -30;
        cell.scrollLabelView.scrollSpace = 20;
        cell.scrollLabelView.textAlignment = NSTextAlignmentCenter;
        cell.scrollLabelView.backgroundColor = [UIColor clearColor];
        cell.scrollLabelView.font = [UIFont systemFontOfSize:18];
        [cell.titleView addSubview:cell.scrollLabelView];
        
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor,(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x25000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x00000000).CGColor];
        gradientLayer.locations = @[@0,@0.75,@1.0];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0.0);
        gradientLayer.frame = CGRectMake(0, 0, screenSize.width, shadowHeight);
        [cell.bottomView.layer addSublayer:gradientLayer];

    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
 
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setScrollLabelViewText:(NSString *)text
{
    NSString * str = [NSString stringWithFormat:@"\tSpecial Show: %@",text];
    NSAttributedString * title = [self addShowIconImage:str];
    [self.scrollLabelView setupAttributeTitle:title];
    [self.scrollLabelView beginScrolling];
    
    
//     if (!self.scrollLabelView) {
//         CGSize size = self.titleView.frame.size;
//         self.scrollLabelView = [TXScrollLabelView scrollWithTitle:str type:TXScrollLabelViewTypeLeftRight velocity:1 options:UIViewAnimationOptionCurveEaseInOut];
//         self.scrollLabelView.frame = CGRectMake(0, 0, size.width, size.height);
//         self.scrollLabelView.scrollInset = UIEdgeInsetsMake(0, 10 , 0, 10);
//         self.scrollLabelView.tx_centerX  = SCREEN_WIDTH/2 -30;
//         self.scrollLabelView.scrollSpace = 20;
//         self.scrollLabelView.textAlignment = NSTextAlignmentCenter;
//         self.scrollLabelView.backgroundColor = [UIColor clearColor];
//         self.scrollLabelView.font = [UIFont systemFontOfSize:18];
//         [self.scrollLabelView setupAttributeTitle:title];
//         [self.titleView addSubview:self.scrollLabelView];
//         [self.scrollLabelView beginScrolling];
//     }
}

- (NSAttributedString *)addShowIconImage:(NSString *)text {
 
    //创建富文本
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, attributeString.length)];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attributeString.length)];
    
    //NSTextAttachment可以将要插入的图片作为特殊字符处理
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    //定义图片内容及位置和大小
    attch.image = [UIImage imageNamed:@"LiveShowIcon"];
    attch.bounds = CGRectMake(0, -3, 20, 20);
    //创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    //将图片放在第一位
    [attributeString insertAttributedString:string atIndex:0];
    //用label的attributedText属性来使用富文本
   
    return attributeString;
}


- (IBAction)viewPublicfreeBtnClick:(id)sender {
    if ([self.hotCellDelegate respondsToSelector:@selector(hotTableViewCell:didClickViewPublicFreeBtn:)]) {
        [self.hotCellDelegate hotTableViewCell:self didClickViewPublicFreeBtn:sender];
    }
    
}

- (IBAction)bookPrivateBtnClick:(id)sender {
    if ([self.hotCellDelegate respondsToSelector:@selector(hotTableViewCell:didClickBookPrivateBtn:)]) {
        [self.hotCellDelegate hotTableViewCell:self didClickBookPrivateBtn:sender];
    }
}


- (IBAction)vipPrivateBtnClick:(id)sender {
    if ([self.hotCellDelegate respondsToSelector:@selector(hotTableViewCell:didClickVipPrivateBtn:)]) {
        [self.hotCellDelegate hotTableViewCell:self didClickVipPrivateBtn:sender];
    }
}

- (IBAction)viewPublicFeeBtnClick:(id)sender {
    if ([self.hotCellDelegate respondsToSelector:@selector(hotTableViewCell:didClickViewPublicFeeBtn:)]) {
        [self.hotCellDelegate hotTableViewCell:self didClickViewPublicFeeBtn:sender];
    }
}
- (IBAction)chatNowBtnClick:(id)sender {
    if ([self.hotCellDelegate respondsToSelector:@selector(hotTableViewCell:didClickViewChatNowBtn:)]) {
        [self.hotCellDelegate hotTableViewCell:self didClickViewChatNowBtn:sender];
    }
}

- (IBAction)sendNowBtnClick:(id)sender {
    if ([self.hotCellDelegate respondsToSelector:@selector(hotTableViewCell:didClickViewSendMailBtn:)]) {
        [self.hotCellDelegate hotTableViewCell:self didClickViewSendMailBtn:sender];
    }
}

- (IBAction)focusBtnDid:(UIButton *)sender {
    if ([self.hotCellDelegate respondsToSelector:@selector(hotTableViewCell:didClickViewFocusBtn:)]) {
        [self.hotCellDelegate hotTableViewCell:self didClickViewFocusBtn:sender];
    }
}

- (IBAction)sayhiBtnDid:(UIButton *)sender {
    if ([self.hotCellDelegate respondsToSelector:@selector(hotTableViewCell:didClickViewSayHiBtn:)]) {
        [self.hotCellDelegate hotTableViewCell:self didClickViewSayHiBtn:sender];
    }
}

@end
