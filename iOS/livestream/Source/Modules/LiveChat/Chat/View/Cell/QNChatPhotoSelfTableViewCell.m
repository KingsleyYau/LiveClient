//
//  QNChatPhotoSelfTableViewCell.m
//  dating
//
//  Created by test on 16/7/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatPhotoSelfTableViewCell.h"

@implementation QNChatPhotoSelfTableViewCell

+ (NSString *)cellIdentifier {
    return @"QNChatPhotoSelfTableViewCell";
}

+ (NSInteger)cellHeight:(BOOL)isCross {
    return isCross?120:160;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    QNChatPhotoSelfTableViewCell *cell = (QNChatPhotoSelfTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNChatPhotoSelfTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNChatPhotoSelfTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.secretPhoto.layer.cornerRadius = 4.0f;
    cell.secretPhoto.layer.masksToBounds = YES;
    
    cell.secretPhoto.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(secretSelfPhotoClickAction)];
    [cell.secretPhoto addGestureRecognizer:tap];
    
    return cell;
}

- (IBAction)retryBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatPhotoSelfTableViewCellDidClickRetryBtn:)]) {
        [self.delegate ChatPhotoSelfTableViewCellDidClickRetryBtn:self];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)secretSelfPhotoClickAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatPhotoSelfTableViewCellDidLookPhoto:)]) {
        [self.delegate ChatPhotoSelfTableViewCellDidLookPhoto:self];
    }
}


@end
