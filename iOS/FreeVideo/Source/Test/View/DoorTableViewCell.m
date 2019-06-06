//
//  DoorTableViewCell.m
//  livestream
//
//  Created by Max on 13-9-5.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import "DoorTableViewCell.h"
#import "LiveBundle.h"

@implementation DoorTableViewCell
+ (NSString *)cellIdentifier {
    return @"DoorTableViewCell";
}

+ (NSInteger)cellHeight {
    return screenSize.width;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    DoorTableViewCell *cell = (DoorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[DoorTableViewCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"DoorTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.imageViewLoader = [LSImageViewLoader loader];
        cell.imageViewHeader.image = nil;
        cell.labelRoomTitle.text = @"";
        
        cell.onlineImageView.layer.cornerRadius = cell.onlineImageView.frame.size.height * 0.5f;
        cell.onlineImageView.layer.masksToBounds = YES;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
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

- (void)reset {
    self.imageViewHeader.image = nil;
    self.labelRoomTitle.text = @"";
    self.onlineImageView.hidden = YES;
}

@end
