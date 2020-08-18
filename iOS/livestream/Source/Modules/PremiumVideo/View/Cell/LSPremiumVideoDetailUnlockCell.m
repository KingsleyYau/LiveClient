//
//  LSPremiumVideoDetailUnlockCell.m
//  livestream
//
//  Created by Calvin on 2020/8/11.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumVideoDetailUnlockCell.h"

@implementation LSPremiumVideoDetailUnlockCell

+ (NSInteger)cellHeight{
    return 116;
}

+ (NSString *)cellIdentifier {
    return @"LSPremiumVideoDetailUnlockCell";
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSPremiumVideoDetailUnlockCell *cell = (LSPremiumVideoDetailUnlockCell *)[tableView dequeueReusableCellWithIdentifier:[LSPremiumVideoDetailUnlockCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPremiumVideoDetailUnlockCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentBGView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x68CA77).CGColor;
    self.contentBGView.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
