//
//  QNChatLargeEmotionSelfTableViewCell.m
//  dating
//
//  Created by test on 16/9/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatLargeEmotionSelfTableViewCell.h"
#import "Masonry.h"

@implementation QNChatLargeEmotionSelfTableViewCell

+ (NSString *)cellIdentifier {
    return @"QNChatLargeEmotionSelfTableViewCell";
}
+ (NSInteger)cellHeight {
    return 120;
}
+ (id)getUITableViewCell:(UITableView*)tableView {
    QNChatLargeEmotionSelfTableViewCell *cell = (QNChatLargeEmotionSelfTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNChatLargeEmotionSelfTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNChatLargeEmotionSelfTableViewCell cellIdentifier] owner:tableView options:nil];
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

- (IBAction)retryBtnClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatLargeEmotionSelfTableViewCell:DidClickRetryBtn:)]) {
        [self.delegate chatLargeEmotionSelfTableViewCell:self DidClickRetryBtn:sender];
    }
}


@end
