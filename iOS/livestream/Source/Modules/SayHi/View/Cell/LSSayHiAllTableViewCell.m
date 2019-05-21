//
//  LSSayHiAllTableViewCell.m
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiAllTableViewCell.h"

@implementation LSSayHiAllTableViewCell

+ (NSString *)cellIdentifier {
    return @"LSSayHiAllTableViewCell";
}

+ (NSInteger)cellHeight {
    return 82;
}


+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiAllTableViewCell *cell = (LSSayHiAllTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiAllTableViewCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSSayHiAllTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        if (cell.imageViewLoader == nil) {
            cell.imageViewLoader = [LSImageViewLoader loader];
        }
        cell.headImage.layer.cornerRadius = 3.0f;
        cell.headImage.layer.masksToBounds = YES;
        cell.freeIcon.layer.cornerRadius = 2.0f;
        cell.freeIcon.layer.masksToBounds = YES;
    }
    
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)cellUpdateIsHasRead:(NSInteger)unreadNum {
    if (unreadNum > 0) {
        self.backgroundColor = COLOR_WITH_16BAND_RGB(0xFFFECD);
        self.anchorName.font = [UIFont boldSystemFontOfSize:18];
        self.content.font = [UIFont boldSystemFontOfSize:16];
        self.dateTime.font = [UIFont boldSystemFontOfSize:14];
        self.unreadCount.hidden = NO;
        self.unreadCount.text = [NSString stringWithFormat:@"%lu unread",(long)unreadNum];
    }else {
        self.backgroundColor = [UIColor whiteColor];
        self.anchorName.font = [UIFont systemFontOfSize:18];
        self.content.font = [UIFont systemFontOfSize:16];
        self.dateTime.font = [UIFont systemFontOfSize:14];
        self.unreadCount.hidden = YES;
    }
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.freeIcon.backgroundColor = COLOR_WITH_16BAND_RGB(0xFF4747);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.freeIcon.backgroundColor = COLOR_WITH_16BAND_RGB(0xFF4747);
}
@end
