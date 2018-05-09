//
//  HotTableViewCell.m
//  livestream
//
//  Created by Max on 13-9-5.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import "HotTableViewCell.h"
#import "LiveBundle.h"
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

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:124.0/255.0 alpha:1].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        gradientLayer.locations = @[@0.0, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0.0);
        gradientLayer.frame = CGRectMake(0, 0, screenSize.width, cell.bottomView.bounds.size.height);
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
     if (!self.scrollLabelView) {
         CGSize size = self.titleView.frame.size;
         NSString * str = [NSString stringWithFormat:@"\tSpecial Show: %@",text];
        NSAttributedString * title = [self addShowIconImage:str];
        self.scrollLabelView = [TXScrollLabelView scrollWithTitle:str type:TXScrollLabelViewTypeLeftRight velocity:1 options:UIViewAnimationOptionCurveEaseInOut];
        self.scrollLabelView.frame = CGRectMake(0, 0, size.width, size.height);
         self.scrollLabelView.scrollInset = UIEdgeInsetsMake(0, 10 , 0, 10);
         self.scrollLabelView.tx_centerX  = SCREEN_WIDTH/2 -30;
         self.scrollLabelView.scrollSpace = 20;
         self.scrollLabelView.textAlignment = NSTextAlignmentCenter;
         self.scrollLabelView.backgroundColor = [UIColor clearColor];
         [self.scrollLabelView setupAttributeTitle:title];
         [self.titleView addSubview:self.scrollLabelView];
         [self.scrollLabelView beginScrolling];
    }
}

- (NSAttributedString *)addShowIconImage:(NSString *)text {
 
    //创建富文本
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, attributeString.length)];
    
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

@end
