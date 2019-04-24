//
//  TalentMsgCell.m
//  livestream
//
//  Created by Calvin on 2018/5/29.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "TalentMsgCell.h"
#import "LSImageViewLoader.h"
@implementation TalentMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.bgView.layer.cornerRadius = 5;
    self.bgView.layer.masksToBounds = YES;
}

+ (NSString *)cellIdentifier {
    return @"TalentMsgCell";
}

+ (NSInteger)cellHeight {
    return 74;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    TalentMsgCell *cell = (TalentMsgCell *)[tableView dequeueReusableCellWithIdentifier:[TalentMsgCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[TalentMsgCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)updateMsg:(MsgItem *)msg {
 
    [[LSImageViewLoader loader]loadImageFromCache:self.headView options:0 imageUrl:msg.honorUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_HangOut"] finishHandler:^(UIImage *image) {
    }];
    
    self.infoLabel.text = msg.text;
}

- (IBAction)talentMsgTap:(UITapGestureRecognizer *)sender {
    if ([self.talentCellDelegate respondsToSelector:@selector(talentMsgCellDid)]) {
        [self.talentCellDelegate talentMsgCellDid];
    }
}

@end
