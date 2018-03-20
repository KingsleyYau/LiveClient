//
//  PreStartPublicAutoInviteTableViewCell.m
//  livestream_anchor
//
//  Created by test on 2018/3/1.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreStartPublicAutoInviteTableViewCell.h"

@implementation PreStartPublicAutoInviteTableViewCell

+ (NSString *)cellIdentifier {
    return @"PreStartPublicAutoInviteTableViewCell";
}

+ (NSInteger)cellHeight {
    return 160;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    PreStartPublicAutoInviteTableViewCell *cell = (PreStartPublicAutoInviteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[PreStartPublicAutoInviteTableViewCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"PreStartPublicAutoInviteTableViewCell" owner:tableView options:nil];
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
    
}
- (IBAction)openAutoInvitation:(UISwitch *)sender {
    if ([self.startPublicAutoInviteDelegate respondsToSelector:@selector(preStartPublicAutoInviteTableViewCell:didOpenAutoInvitation:)]) {
        [self.startPublicAutoInviteDelegate preStartPublicAutoInviteTableViewCell:self didOpenAutoInvitation:sender];
    }
}

@end
