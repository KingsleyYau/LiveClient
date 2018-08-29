//
//  HangoutInviteTableViewCell.m
//  livestream
//
//  Created by Max on 18-5-15.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import "HangoutInviteTableViewCell.h"

#import "LiveBundle.h"

@implementation HangoutInviteTableViewCell
+ (NSString *)identifier {
    return @"HangoutInviteTableViewCell";
}

+ (NSInteger)height {
    return 56;
}

+ (id)cell:(UITableView *)tableView {
    HangoutInviteTableViewCell *cell = (HangoutInviteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[HangoutInviteTableViewCell identifier]];
    if (nil == cell) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"HangoutInviteTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageViewLoader = [LSImageViewLoader loader];
    
    self.imageViewHeader.image = nil;
    self.labelName.text = @"";
    self.labelDesc.text = @"";
    
//    self.buttonInvite.contentEdgeInsets = UIEdgeInsetsMake(6, 20, 6, 20);
    [self.buttonInvite setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageViewHeader.layer.cornerRadius = self.imageViewHeader.frame.size.height / 2;
    
//    [self.buttonInvite sizeToFit];
    self.buttonInvite.layer.cornerRadius = self.buttonInvite.frame.size.height / 2;
}

@end
