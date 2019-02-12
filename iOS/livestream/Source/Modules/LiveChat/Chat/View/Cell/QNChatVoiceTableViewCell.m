//
//  QNChatVoiceTableViewCell.m
//  dating
//
//  Created by Calvin on 17/4/25.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "QNChatVoiceTableViewCell.h"

@implementation QNChatVoiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"QNChatVoiceTableViewCell";
}

+ (NSInteger)cellHeight{
    return 56;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    QNChatVoiceTableViewCell *cell = (QNChatVoiceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNChatVoiceTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNChatVoiceTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.redView.layer.cornerRadius = cell.redView.frame.size.width/2;
        cell.redView.layer.masksToBounds = YES;
        cell.palyButton.layer.cornerRadius = cell.palyButton.frame.size.height/2;
        cell.palyButton.layer.masksToBounds = YES;
    }
    
    return cell;
}

- (IBAction)palyButton:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"ChatVoiceSelf_pauseIcon"] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(palyVoice:)]) {
            [self.delegate palyVoice:self.tag];
        }
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"LS_ChatVoiceSelf_PlayIcon"] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(stopVoice:)]) {
            [self.delegate stopVoice:self.tag];
        }
    }
}

- (void)setPalyButtonImage:(BOOL)isPaly
{
    self.palyButton.selected = isPaly;
    if (isPaly) {
        [self.palyButton setImage:[UIImage imageNamed:@"LS_ChatVoiceSelf_ pauseIcon"] forState:UIControlStateNormal];
    }
    else
    {
        [self.palyButton setImage:[UIImage imageNamed:@"LS_ChatVoiceSelf_PlayIcon"] forState:UIControlStateNormal];
    }
}


- (void)setPalyButtonTime:(int)time
{
    [self.palyButton setTitle:[NSString stringWithFormat:@"%d\"",time] forState:UIControlStateNormal];
}
@end
