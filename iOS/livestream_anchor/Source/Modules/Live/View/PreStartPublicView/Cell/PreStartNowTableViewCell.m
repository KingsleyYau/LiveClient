//
//  PreStartNowTableViewCell.m
//  livestream_anchor
//
//  Created by test on 2018/3/1.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreStartNowTableViewCell.h"

@implementation PreStartNowTableViewCell

+ (NSString *)cellIdentifier {
    return @"PreStartNowTableViewCell";
}

+ (NSInteger)cellHeight {
    return 70;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    PreStartNowTableViewCell *cell = (PreStartNowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[PreStartNowTableViewCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"PreStartNowTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];


    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.startBtn.layer.cornerRadius = self.startBtn.frame.size.height * 0.5f;
    self.startBtn.layer.masksToBounds = YES;
    self.startBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
}

- (IBAction)startBroadcast:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    if ([self.startNowDelegate respondsToSelector:@selector(preStartNowTableViewCell:didStartBroadcast:)]) {
        [self.startNowDelegate preStartNowTableViewCell:self didStartBroadcast:sender];
    }
}

@end
