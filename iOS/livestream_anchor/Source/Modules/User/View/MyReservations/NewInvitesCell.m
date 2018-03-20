//
//  NewInvitesCell.m
//  livestream
//
//  Created by Calvin on 17/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "NewInvitesCell.h"
#import "LiveBundle.h"

@implementation NewInvitesCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.comfirmBtn.layer.cornerRadius = 5;
    self.comfirmBtn.layer.masksToBounds = YES;

    self.declineBtn.layer.cornerRadius = 5;
    self.declineBtn.layer.masksToBounds = YES;

    self.headImage.layer.cornerRadius = self.headImage.frame.size.width / 2;
    self.headImage.layer.masksToBounds = YES;

    self.redIcon.layer.cornerRadius = self.redIcon.frame.size.width / 2;
    self.redIcon.layer.masksToBounds = YES;
    
    self.giftsView.layer.cornerRadius = self.giftsView.frame.size.height/2;
    self.giftsView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"NewInvitesCell";
}

+ (NSInteger)cellHeight {
    return 110;
}

+ (id)getUITableViewCell:(UITableView *)tableView forRow:(NSInteger)row {
    NewInvitesCell *cell = (NewInvitesCell *)[tableView dequeueReusableCellWithIdentifier:[NewInvitesCell cellIdentifier]];

    if (nil == cell) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[NewInvitesCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.haedTap.view.tag = row;
        cell.comfirmBtn.tag = row;
        cell.declineBtn.tag = row;
    }

    return cell;
}

- (IBAction)declineBtnDid:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(myReservationsDeclineBtnDidForRow:)]) {
        [self.delegate myReservationsDeclineBtnDidForRow:sender.tag];
    }
}

- (IBAction)comfirmBtnDid:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(myReservationsComfirmBtnDidForRow:)]) {
        [self.delegate myReservationsComfirmBtnDidForRow:sender.tag];
    }
}

- (IBAction)headTap:(UITapGestureRecognizer *)sender {
    
    if ([self.delegate respondsToSelector:@selector(myReservationsHeadDidForRow:)]) {
        [self.delegate myReservationsHeadDidForRow:sender.view.tag];
    }
}

- (void)updateNameFrame
{
    CGSize size = [self.nameLabel.text sizeWithAttributes:@{NSFontAttributeName:self.nameLabel.font}];
    
    CGRect nameRect = self.nameLabel.frame;
    nameRect.size.width = size.width;
    self.nameLabel.frame = nameRect;
    
    CGRect levelRect = self.giftsView.frame;
    levelRect.origin.x = nameRect.origin.x + nameRect.size.width + 10;
    self.giftsView.frame = levelRect;
}

#pragma mark 时间格式转换
- (NSString *)getTime:(NSInteger)time {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"MMM dd. HH:mm"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];
    
    return timeStr;
}
@end
