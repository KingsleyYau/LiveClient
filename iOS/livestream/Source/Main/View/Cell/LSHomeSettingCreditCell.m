//
//  LSHomeSettingCreditCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/7/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSHomeSettingCreditCell.h"
#import "LiveRoomCreditRebateManager.h"

@implementation LSHomeSettingCreditCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.addBtn.layer.cornerRadius = 5;
    self.addBtn.layer.masksToBounds = YES;
}

+ (NSInteger)cellHeight {
    return 57;
}

+ (NSString *)cellIdentifier {
    return @"LSHomeSettingCreditCell";
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSHomeSettingCreditCell *cell = (LSHomeSettingCreditCell *)[tableView dequeueReusableCellWithIdentifier:[LSHomeSettingCreditCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSHomeSettingCreditCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)showMyCredits {
    self.creditsLabel.text = [NSString stringWithFormat:@"Balance：%.2f",[LiveRoomCreditRebateManager creditRebateManager].mCredit];
    [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        if (success) {
            self.creditsLabel.text = [NSString stringWithFormat:@"Balance：%.2f",credit];
        }
    }];
}

- (IBAction)addCrteditsAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pushToCreditsVC)]) {
        [self.delegate pushToCreditsVC];
    }
}

@end
