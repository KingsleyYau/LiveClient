//
//  LSChatVideoLadyTableViewCell.m
//  livestream
//
//  Created by Calvin on 2019/3/20.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSChatVideoLadyTableViewCell.h"

@implementation LSChatVideoLadyTableViewCell

+ (NSString *)cellIdentifier {
    return @"LSChatVideoLadyTableViewCell";
}

+ (NSInteger)cellHeight:(BOOL)isCross{
    return isCross?150:180;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatVideoLadyTableViewCell *cell = (LSChatVideoLadyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatVideoLadyTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSChatVideoLadyTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.imageBGView.layer.cornerRadius = 4.0f;
    cell.imageBGView.layer.masksToBounds = YES;
    cell.imageBGView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(secretPhotoClickAction)];
    [cell.imageBGView addGestureRecognizer:tap];
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)secretPhotoClickAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatVideoLadyTableViewCellDid:)]) {
        [self.delegate ChatVideoLadyTableViewCellDid:self];
    }
}


@end
