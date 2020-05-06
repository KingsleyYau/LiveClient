//
//  LSScheduleStatusTipCell.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/17.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleStatusTipCell.h"
#import "LSShadowView.h"

@interface LSScheduleStatusTipCell()
@property (nonatomic, strong) MsgItem *item;
@end

@implementation LSScheduleStatusTipCell

+ (NSString *)cellIdentifier {
    return @"LSScheduleStatusTipCell";
}

+ (CGFloat)cellHeight {
    return 110;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSScheduleStatusTipCell *cell = (LSScheduleStatusTipCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleStatusTipCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSScheduleStatusTipCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.item = [[MsgItem alloc] init];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    LSShadowView * view = [[LSShadowView alloc]init];
    [view showShadowAddView:self.bgView];
}

- (void)updataInfo:(MsgItem *)msgItem {
    self.item = msgItem;
    
    NSAttributedString *tip;
    NSMutableAttributedString *checkTip = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"Request") attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838)}];
    NSAttributedString *idStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"ScheduleID"),msgItem.scheduleMsg.privScheId] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x666666)}];
    NSAttributedString *here = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"Here") attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x1e9efb),NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
    
    
    if (msgItem.scheduleType == ScheduleType_Confirmed) {
        tip = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"Accepted_Tip") attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838)}];
        self.bgView.backgroundColor = COLOR_WITH_16BAND_RGB(0xf1fff2);
        self.tipLabel.textColor = COLOR_WITH_16BAND_RGB(0x04C456);
        self.tipBgImageView.hidden = NO;
        self.tipImageView.image = [UIImage imageNamed:@"LS_Schedule_AcceptIcon"];
        if (msgItem.usersType == UsersType_Me) {
            self.tipLabel.text = NSLocalizedStringFromSelf(@"REQUEST_CONFIRMED");
        } else {
            self.tipLabel.text = NSLocalizedStringFromSelf(@"INVITE_CONFIRMED");
        }
    } else {
        tip = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"Declined_Tip") attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838)}];
        self.bgView.backgroundColor = COLOR_WITH_16BAND_RGB(0xfff7f2);
        self.tipLabel.textColor = COLOR_WITH_16BAND_RGB(0xff8837);
        self.tipBgImageView.hidden = YES;
        self.tipImageView.image = [UIImage imageNamed:@"LS_Schedule_Decline"];
        if (msgItem.usersType == UsersType_Me) {
            self.tipLabel.text = NSLocalizedStringFromSelf(@"REQUEST_DECLINED");
        } else {
            self.tipLabel.text = NSLocalizedStringFromSelf(@"INVITE_DECLINED");
        }
    }
    [checkTip appendAttributedString:idStr];
    [checkTip appendAttributedString:tip];
    [checkTip appendAttributedString:here];
    self.checkLabel.attributedText = checkTip;
}

- (IBAction)checkDtails:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pushScheduleInviteDetail:)]) {
        [self.delegate pushScheduleInviteDetail:self.item];
    }
}


@end
