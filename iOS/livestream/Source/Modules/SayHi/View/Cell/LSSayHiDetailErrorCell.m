//
//  LSSayHiDetailErrorCell.m
//  livestream
//
//  Created by Calvin on 2019/5/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiDetailErrorCell.h"

@implementation LSSayHiDetailErrorCell

+ (NSString *)cellIdentifier {
    return @"LSSayHiDetailErrorCell";
}

+ (NSInteger)cellHeight {
    return 128;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiDetailErrorCell *cell = (LSSayHiDetailErrorCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiDetailErrorCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiDetailErrorCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.bgView.layer.cornerRadius = 8;
        cell.bgView.layer.masksToBounds = YES;
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
