//
//  LSMessageCell.m
//  livestream
//
//  Created by Calvin on 2018/6/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMessageCell.h"

@implementation LSMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headView.layer.cornerRadius = self.headView.frame.size.height/2;
    self.headView.layer.masksToBounds = YES;
    
    self.readCount.layer.cornerRadius = self.readCount.frame.size.height/2;
    self.readCount.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"LSMessageCell";
}

+ (NSInteger)cellHeight {
    return 65;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSMessageCell *cell = (LSMessageCell *)[tableView dequeueReusableCellWithIdentifier:[LSMessageCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSMessageCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

@end
