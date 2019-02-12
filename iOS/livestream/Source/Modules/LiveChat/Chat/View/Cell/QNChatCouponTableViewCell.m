//
//  QNChatCouponTableViewCell.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatCouponTableViewCell.h"

@implementation QNChatCouponTableViewCell
+ (NSString *)cellIdentifier {
    return @"QNChatCouponTableViewCell";
}

+ (NSInteger)cellHeight {
    NSInteger height = 64;
    
    return height;
}
+ (id)getUITableViewCell:(UITableView*)tableView {
    QNChatCouponTableViewCell *cell = (QNChatCouponTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNChatCouponTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNChatCouponTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.backgroundImageView.layer.cornerRadius = ([self cellHeight] - 10) / 8.0;
        cell.backgroundImageView.layer.masksToBounds = YES;
    }
    
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
