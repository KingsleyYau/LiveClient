//
//  QNChatSmallEmotionLadyTableViewCell.m
//  dating
//
//  Created by test on 16/11/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatSmallEmotionLadyTableViewCell.h"

@implementation QNChatSmallEmotionLadyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"QNChatSmallEmotionLadyTableViewCell";
}

+ (NSInteger)cellHeight {
    return 120;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    QNChatSmallEmotionLadyTableViewCell *cell = (QNChatSmallEmotionLadyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNChatSmallEmotionLadyTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNChatSmallEmotionLadyTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];

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

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
