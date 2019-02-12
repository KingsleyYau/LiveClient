//
//  PremiumMembershipTableViewCell.m
//  dating
//
//  Created by Calvin on 17/4/11.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSPremiumMembershipTableViewCell.h"

@implementation LSPremiumMembershipTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//标识符
+ (NSString *)cellIdentifier{
    return @"LSPremiumMembershipTableViewCell";
}
//高度
+ (NSInteger)cellHeight{
    return 80;
}


//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView {
    LSPremiumMembershipTableViewCell *cell = (LSPremiumMembershipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSPremiumMembershipTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSPremiumMembershipTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.bgView.layer.cornerRadius = 4.0f;
    cell.bgView.layer.masksToBounds = YES;

    return cell;
}
@end
