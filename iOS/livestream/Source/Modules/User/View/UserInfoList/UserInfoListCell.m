//
//  UserInfoListCell.m
//  livestream
//
//  Created by Calvin on 17/10/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "UserInfoListCell.h"
#import "LiveBundle.h"

@implementation UserInfoListCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.levelBtn.layer.cornerRadius = self.levelBtn.frame.size.height / 2;
    self.levelBtn.layer.masksToBounds = YES;

    self.unread.layer.cornerRadius = self.unread.frame.size.width / 2;
    self.unread.layer.masksToBounds = YES;

    self.unIcon.layer.cornerRadius = self.unIcon.frame.size.width / 2;
    self.unIcon.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"UserInfoListCell";
}

+ (NSInteger)cellHeight {
    return 50;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    UserInfoListCell *cell = (UserInfoListCell *)[tableView dequeueReusableCellWithIdentifier:[UserInfoListCell cellIdentifier]];

    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[UserInfoListCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

@end
