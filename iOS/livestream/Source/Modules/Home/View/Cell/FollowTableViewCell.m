//
//  FollowTableViewCell.m
//  livestream
//
//  Created by test on 2017/9/8.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "FollowTableViewCell.h"
#import "LiveBundle.h"

@implementation FollowTableViewCell

+ (NSString *)cellIdentifier {
    return @"FollowTableViewCell";
}

+ (NSInteger)cellHeight {
    return 0;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    FollowTableViewCell *cell = (FollowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[FollowTableViewCell cellIdentifier]];
    if ( nil == cell ) {
        
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"FollowTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
           cell.imageViewLoader = [LSImageViewLoader loader];
//        cell.imageViewLoader = nil;
    }
    cell.imageViewHeader.image = nil;
    cell.labelRoomTitle.text = @"";
    cell.onlineView.layer.cornerRadius = cell.onlineView.frame.size.height * 0.5f;
    cell.onlineView.layer.masksToBounds = YES;
    cell.interest1.layer.cornerRadius = cell.interest1.frame.size.height * 0.5f;
    cell.interest1.layer.masksToBounds = YES;


    
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
    UIImageView *animationView = self.vipPrivateBtn.imageView;
    animationView.animationImages = self.animationArray;
    animationView.animationRepeatCount = 0;
    animationView.animationDuration = 1;
    [animationView startAnimating];
}


- (IBAction)viewPublicfreeBtnClick:(id)sender {
    if ([self.followCellDelegate respondsToSelector:@selector(followTableViewCell:didClickViewPublicFreeBtn:)]) {
        [self.followCellDelegate followTableViewCell:self didClickViewPublicFreeBtn:sender];
    }
    
}
- (IBAction)bookPrivateBtnClick:(id)sender {
    if ([self.followCellDelegate respondsToSelector:@selector(followTableViewCell:didClickBookPrivateBtn:)]) {
        [self.followCellDelegate followTableViewCell:self didClickBookPrivateBtn:sender];
    }
}
- (IBAction)normalPrivateBtnClick:(id)sender {
    if ([self.followCellDelegate respondsToSelector:@selector(followTableViewCell:didClickNormalPrivateBtn:)]) {
        [self.followCellDelegate followTableViewCell:self didClickNormalPrivateBtn:sender];
    }
}
- (IBAction)vipPrivateBtnClick:(id)sender {
    if ([self.followCellDelegate respondsToSelector:@selector(followTableViewCell:didClickVipPrivateBtn:)]) {
        [self.followCellDelegate followTableViewCell:self didClickVipPrivateBtn:sender];
    }
}
- (IBAction)viewPublicFeeBtnClick:(id)sender {
    if ([self.followCellDelegate respondsToSelector:@selector(followTableViewCell:didClickViewPublicFeeBtn:)]) {
        [self.followCellDelegate followTableViewCell:self didClickViewPublicFeeBtn:sender];
    }
}
@end
