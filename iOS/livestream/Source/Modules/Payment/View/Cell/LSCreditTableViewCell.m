//
//  CommonCreditTableViewCell.m
//  dating
//
//  Created by test on 16/7/1.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSCreditTableViewCell.h"

@implementation LSCreditTableViewCell

+ (NSString *)cellIdentifier {
    return @"LSCreditTableViewCell";
}

+ (NSInteger)cellHeight {
    return 74;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSCreditTableViewCell *cell = (LSCreditTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSCreditTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSCreditTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.bgView.layer.cornerRadius = 8.0f;
    cell.bgView.layer.masksToBounds = YES;
    cell.creditBtn.layer.cornerRadius = 8.0f;
    cell.creditBtn.layer.masksToBounds = YES;
    cell.titleLabel.text = @"";
    [cell.creditBtn setTitle:@"0.0" forState:UIControlStateNormal];

    
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
