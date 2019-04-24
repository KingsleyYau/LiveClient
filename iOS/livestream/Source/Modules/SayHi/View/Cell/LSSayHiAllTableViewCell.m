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
    return 73;
}


+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiAllTableViewCell *cell = (LSSayHiAllTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiAllTableViewCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSSayHiAllTableViewCell cellIdentifier] owner:tableView options:nil];
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
    self.headImage.layer.cornerRadius = self.headImage.frame.size.height * 0.5f;
    self.headImage.layer.masksToBounds = YES;

}



@end
