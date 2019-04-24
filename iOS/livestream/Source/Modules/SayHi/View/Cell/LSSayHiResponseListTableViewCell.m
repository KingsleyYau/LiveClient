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
    return 73;
}


+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiResponseListTableViewCell *cell = (LSSayHiResponseListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiResponseListTableViewCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSSayHiResponseListTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        if (cell.imageViewLoader == nil) {
            cell.imageViewLoader = [LSImageViewLoader loader];

        }
    }
    
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}


@end
