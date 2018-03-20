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

    self.unread.layer.cornerRadius = self.unread.frame.size.height / 2;
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

- (void)updateCount:(NSInteger)count
{
    self.unread.hidden = YES;
    if (count > 0) {
    self.unread.hidden = NO;
        if (count > 99) {
            self.unread.text =@"99+";
            CGRect rect = self.unread.frame;
            rect.size.width = 25;
            rect.origin.x = self.arrow.frame.origin.x - 35;
            self.unread.frame = rect;
        }
        else
        {
           self.unread.text =[NSString stringWithFormat:@"%ld",count];
            CGRect rect = self.unread.frame;
            rect.size.width = 15;
            rect.origin.x = self.arrow.frame.origin.x - 25;
            self.unread.frame = rect;
        }
    }
}

@end
