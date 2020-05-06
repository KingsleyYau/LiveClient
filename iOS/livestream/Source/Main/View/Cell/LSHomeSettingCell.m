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
    
    self.contentLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x333333) orDark:[UIColor whiteColor]];
    
    self.imageLoader = [LSImageViewLoader loader];
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
            self.unreadLabel.text = @"99+";
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
    if (self.offIcon.hidden) {
        [self.offIcon removeFromSuperview];
    }
}

- (void)showWillShowSoon:(BOOL)isSoon {
    self.logoIcon.hidden = NO;
    if (isSoon) {
        self.logoIcon.image = [UIImage imageNamed:@"Setting_Soon"];
    }else {
        self.logoIcon.image = [UIImage imageNamed:@"Setting_Clock"];
    }
}

- (void)showChatListUnreadNum:(int)num {
    if (num > 0) {
        if (num > 99) {
            self.unreadLabel.text = @"99+";
        }
        else {
            self.unreadLabel.text = [NSString stringWithFormat:@"%d",num];
        }
        
        self.unreadView.hidden = NO;
        // 是否显示
        self.redLabel.hidden = YES;
    } else if(num < 0) {
        self.unreadView.hidden = YES;
        self.unreadLabel.text = @"";
        // 是否显示红点
        self.redLabel.hidden = NO;
    }else {
        self.unreadView.hidden = YES;
        self.redLabel.hidden = YES;
    }
    if (self.offIcon.hidden) {
        [self.offIcon removeFromSuperview];
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
    if (self.offIcon.hidden) {
        [self.offIcon removeFromSuperview];
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
