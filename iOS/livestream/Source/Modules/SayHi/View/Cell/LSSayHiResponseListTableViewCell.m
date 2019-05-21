//
//  LSSayHiResponseListTableViewCell.m
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiResponseListTableViewCell.h"


@implementation LSSayHiResponseListTableViewCell


+ (NSString *)cellIdentifier {
    return @"LSSayHiResponseListTableViewCell";
}

+ (NSInteger)cellHeight {
    return 82;
}


+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiResponseListTableViewCell *cell = (LSSayHiResponseListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiResponseListTableViewCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSSayHiResponseListTableViewCell cellIdentifier] owner:tableView options:nil];
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

- (void)cellUpdateIsHasRead:(BOOL)isRead {
    if (isRead) {
        self.backgroundColor = [UIColor whiteColor];
        self.anchorName.font = [UIFont systemFontOfSize:18];
        self.contentLabel.font = [UIFont systemFontOfSize:16];
        self.dateTime.font = [UIFont systemFontOfSize:14];
    }else {
        self.backgroundColor = COLOR_WITH_16BAND_RGB(0xFFFECD);
        self.anchorName.font = [UIFont boldSystemFontOfSize:18];
        self.contentLabel.font = [UIFont boldSystemFontOfSize:16];
        self.dateTime.font = [UIFont boldSystemFontOfSize:14];
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
