//
//  TalentOnDemandCell.m
//  livestream
//
//  Created by Calvin on 17/9/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TalentOnDemandCell.h"
#import "LiveBundle.h"

@implementation TalentOnDemandCell
+ (NSString *)cellIdentifier {
    return @"TalentOnDemandCell";
}

+ (NSInteger)cellHeight {
    return 45;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.requestBtn.layer.cornerRadius = 5;
    self.requestBtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    TalentOnDemandCell *cell = (TalentOnDemandCell *)[tableView dequeueReusableCellWithIdentifier:[TalentOnDemandCell cellIdentifier]];

    if (nil == cell) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[TalentOnDemandCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

@end
