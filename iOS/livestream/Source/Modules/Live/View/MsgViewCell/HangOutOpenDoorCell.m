//
//  HangOutOpenDoorCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangOutOpenDoorCell.h"
#import "LSImageViewLoader.h"
#import "LiveModule.h"

#define ISIphoneFive [UIScreen mainScreen].bounds.size.height < 600 ? YES : NO

@implementation HangOutOpenDoorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:nil];
        HangOutOpenDoorCell *cell = [nib objectAtIndex:0];
        cell.backgroundColorView.layer.cornerRadius = 5;
        cell.backgroundColorView.layer.masksToBounds = YES;
        self = cell;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    if (ISIphoneFive) {
        self.hangoutBtnWidth.constant = DESGIN_TRANSFORM_3X(self.hangoutBtnWidth.constant);
    }
    self.hangoutBtn.layer.cornerRadius = self.hangoutBtn.frame.size.height / 2;
    self.openBtn.layer.cornerRadius = self.openBtn.frame.size.height / 2;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}

- (IBAction)hangoutAction:(id)sender {
    if ([self.delagate respondsToSelector:@selector(inviteHangoutAnchor:)]) {
        [self.delagate inviteHangoutAnchor:self.msgItem];
    }
}

- (IBAction)openAction:(id)sender {
    if ([self.delagate respondsToSelector:@selector(agreeAnchorKnock:)]) {
        [self.delagate agreeAnchorKnock:self.msgItem];
    }
}

- (void)updataChatMessage:(MsgItem *)item {
    self.msgItem = item;
    if (item.msgType == MsgType_Knock) {
        [[LSImageViewLoader loader] refreshCachedImage:self.headImageView options:SDWebImageRefreshCached imageUrl:item.knockItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_HangOut"]];
        self.nameLabel.text = item.knockItem.nickName;
        self.ageLabel.text = [NSString stringWithFormat:@"%dyrs / ",item.knockItem.age];
        self.countryLabel.text = item.knockItem.country;
        self.hangoutBtn.hidden = YES;
        self.openBtn.hidden = NO;
        
    } else if (item.msgType == MsgType_Recommend) {
        [[LSImageViewLoader loader] refreshCachedImage:self.headImageView options:SDWebImageRefreshCached imageUrl:item.recommendItem.friendPhotoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_HangOut"]];
        self.nameLabel.text = item.recommendItem.friendNickName;
        self.ageLabel.text = [NSString stringWithFormat:@"%dyrs / ",item.recommendItem.friendAge];
        self.countryLabel.text = item.recommendItem.friendCountry;
        self.openBtn.hidden = YES;
        self.hangoutBtn.hidden = NO;
    }
}

+ (NSString *)cellIdentifier {
    return @"HangOutOpenDoorCell";
}

@end
