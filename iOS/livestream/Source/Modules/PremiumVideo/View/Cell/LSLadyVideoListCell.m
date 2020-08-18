//
//  LSLadyVideoListCell.m
//  livestream
//
//  Created by Calvin on 2020/8/5.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSLadyVideoListCell.h"
#import "LSImageViewLoader.h"
@interface LSLadyVideoListCell ()
@property (nonatomic, strong) LSImageViewLoader * imageViewLoader;
@end

@implementation LSLadyVideoListCell

+ (NSInteger)cellHeight {
    return 117;
}

+ (NSString *)cellIdentifier {
    return @"LSLadyVideoListCell";
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSLadyVideoListCell *cell = (LSLadyVideoListCell *)[tableView dequeueReusableCellWithIdentifier:[LSLadyVideoListCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSLadyVideoListCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imageViewLoader = [LSImageViewLoader loader];
    
    self.coverImage.layer.cornerRadius = 3;
    self.coverImage.layer.masksToBounds = YES;
    
    self.titleLabel.layer.cornerRadius = 3;
    self.titleLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setVideoData:(LSPremiumVideoinfoItemObject*)item {
        
    [self.imageViewLoader loadImageWithImageView:self.coverImage options:0 imageUrl:item.coverUrlPng placeholderImage:nil finishHandler:nil];
    
    self.titleLabel.text = item.title;
    
    self.subLabel.text = item.describe;
    
    self.timeLabel.text = [self convertTime:item.duration];
    
    if (item.isInterested) {
        [self.followBtn setImage:[UIImage imageNamed:@"Ls_Video_Followed"] forState:UIControlStateNormal];
    }else {
        [self.followBtn setImage:[UIImage imageNamed:@"Ls_Video_Follow"] forState:UIControlStateNormal];
    }
}

- (IBAction)followBtnDid:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"Ls_Video_Followed"] forState:UIControlStateNormal];
    }else {
        [sender setImage:[UIImage imageNamed:@"Ls_Video_Follow"] forState:UIControlStateNormal];
    }
    
    if ([self.cellDelegate respondsToSelector:@selector(ladyVideoListCellDidFollow:)]) {
        [self.cellDelegate ladyVideoListCellDidFollow:self.tag];
    }
}

- (NSString *)convertTime:(CGFloat)second {
    // 相对格林时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showTimeNew = [formatter stringFromDate:date];
    return showTimeNew;
}
@end
