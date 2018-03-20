//
//  HotTableViewCell.m
//  livestream
//
//  Created by Max on 13-9-5.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import "HotTableViewCell.h"
#import "LiveBundle.h"

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

- (IBAction)normalPrivateBtnClick:(id)sender {
    if ([self.hotCellDelegate respondsToSelector:@selector(hotTableViewCell:didClickNormalPrivateBtn:)]) {
        [self.hotCellDelegate hotTableViewCell:self didClickNormalPrivateBtn:sender];
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
