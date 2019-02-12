//
//  QNChatLargeEmotionLadyTableViewCell.m
//  dating
//
//  Created by test on 16/9/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatLargeEmotionLadyTableViewCell.h"
#import "Masonry.h"

@implementation QNChatLargeEmotionLadyTableViewCell

+ (NSString *)cellIdentifier {
    return @"QNChatLargeEmotionLadyTableViewCell";
}

+ (NSInteger)cellHeight {
    return 120;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    QNChatLargeEmotionLadyTableViewCell *cell = (QNChatLargeEmotionLadyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNChatLargeEmotionLadyTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNChatLargeEmotionLadyTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.largeEmotionImageView = [QNLargeEmotionShowView largeEmotionShowView];
        [cell.view addSubview:cell.largeEmotionImageView];
        [cell.largeEmotionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell.view);
            make.height.equalTo(cell.view);
            make.left.equalTo(cell.view);
            make.top.equalTo(cell.view);
        }];
        
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
