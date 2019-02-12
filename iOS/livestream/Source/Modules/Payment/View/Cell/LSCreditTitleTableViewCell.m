//
//  CommonTitleTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSCreditTitleTableViewCell.h"

@implementation LSCreditTitleTableViewCell
+ (NSString *)cellIdentifier {
    return @"LSCreditTitleTableViewCell";
}

+ (NSInteger)cellHeight {
    return 56;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSCreditTitleTableViewCell *cell = (LSCreditTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSCreditTitleTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSCreditTitleTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.titleLabel.text = @"";
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
