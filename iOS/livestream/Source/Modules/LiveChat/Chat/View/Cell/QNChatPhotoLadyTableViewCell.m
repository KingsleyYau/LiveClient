//
//  QNChatPhotoLadyTableViewCell.m
//  dating
//
//  Created by test on 16/7/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatPhotoLadyTableViewCell.h"

@implementation QNChatPhotoLadyTableViewCell
+ (NSString *)cellIdentifier {
    return @"QNChatPhotoLadyTableViewCell";
}

+ (NSInteger)cellHeight{
    return 150;
}
+ (id)getUITableViewCell:(UITableView*)tableView {
    QNChatPhotoLadyTableViewCell *cell = (QNChatPhotoLadyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNChatPhotoLadyTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNChatPhotoLadyTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }

    cell.secretPhoto.layer.cornerRadius = 4.0f;
    cell.secretPhoto.layer.masksToBounds = YES;
    cell.secretPhoto.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(secretPhotoClickAction)];
    [cell.secretPhoto addGestureRecognizer:tap];

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
    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatPhotoLadyTableViewCellDidLookPhoto:)]) {
        [self.delegate ChatPhotoLadyTableViewCellDidLookPhoto:self];
    }
}



@end
