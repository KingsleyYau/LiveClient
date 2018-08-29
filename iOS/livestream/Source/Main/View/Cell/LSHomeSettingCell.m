//
//  LSHomeSettingCell.m
//  livestream
//
//  Created by Calvin on 2018/6/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSHomeSettingCell.h"

@implementation LSHomeSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.redLabel.layer.cornerRadius = self.redLabel.frame.size.height / 2;
    self.redLabel.layer.masksToBounds = YES;
    
    self.unreadView.layer.cornerRadius = self.unreadView.frame.size.height / 2;
    self.unreadView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSInteger)cellHeight {
    return 50;
}

+ (NSString *)cellIdentifier {
    return @"LSHomeSettingCell";
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSHomeSettingCell *cell = (LSHomeSettingCell *)[tableView dequeueReusableCellWithIdentifier:[LSHomeSettingCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSHomeSettingCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
//        UIView *selectedBackgroundView = [[UIView alloc] init];
//        selectedBackgroundView.backgroundColor = Color(238, 243, 249, 1);
//        cell.selectedBackgroundView = selectedBackgroundView;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.unreadView.hidden = YES;
        cell.redLabel.hidden = YES;
        
    }
    return cell;
}

- (void)showUnreadNum:(int)num {
    if (num) {
        if (num > 99) {
            self.unreadLabel.text =@"99+";
        }
        else {
            self.unreadLabel.text = [NSString stringWithFormat:@"%d",num];
        }
        
        self.unreadView.hidden = NO;
        self.redLabel.hidden = YES;
    } else {
        self.unreadView.hidden = YES;
        self.redLabel.hidden = YES;
    }
}

- (void)showUnreadPoint:(int)num {
    if (num) {
        self.unreadView.hidden = YES;
        self.redLabel.hidden = NO;
    } else {
        self.unreadView.hidden = YES;
        self.redLabel.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.unreadView.backgroundColor = Color(255, 53, 0, 1);
    self.redLabel.backgroundColor = Color(255, 53, 0, 1);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.unreadView.backgroundColor = Color(255, 53, 0, 1);
    self.redLabel.backgroundColor = Color(255, 53, 0, 1);
}

@end
