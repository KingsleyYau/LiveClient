//
//  LSSayHiNoReplyCell.m
//  livestream
//
//  Created by Calvin on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiNoReplyCell.h"
#import "LSShadowView.h"
@implementation LSSayHiNoReplyCell

+ (NSString *)cellIdentifier {
    return @"LSSayHiNoReplyCell";
}

+ (NSInteger)cellHeight {
    return 120;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiNoReplyCell *cell = (LSSayHiNoReplyCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiNoReplyCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiNoReplyCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.bgView.layer.cornerRadius = 5;
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
