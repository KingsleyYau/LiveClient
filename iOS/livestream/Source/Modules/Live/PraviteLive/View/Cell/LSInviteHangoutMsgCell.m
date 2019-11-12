//
//  LSInviteHangoutMsgCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSInviteHangoutMsgCell.h"
#import "LSImageViewLoader.h"

@interface LSInviteHangoutMsgCell ()

@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@end

@implementation LSInviteHangoutMsgCell

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSInviteHangoutMsgCell *cell = (LSInviteHangoutMsgCell *)[tableView dequeueReusableCellWithIdentifier:[LSInviteHangoutMsgCell cellIdentifier]];
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSInviteHangoutMsgCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageLoader = [LSImageViewLoader loader];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.hangoutBtn.layer.cornerRadius = self.hangoutBtn.frame.size.height / 2;
    self.hangoutBtn.layer.masksToBounds = YES;
    self.backgroundColorView.layer.cornerRadius = 5;
    self.backgroundColorView.layer.masksToBounds = YES;
}

- (void)upDataInviteMessage:(MsgItem *)item {
    self.item = item;
    
    [self.imageLoader loadImageFromCache:self.headImageView
                                     options:SDWebImageRefreshCached
                                    imageUrl:item.recommendItem.friendPhotoUrl
                            placeholderImage:
     [UIImage imageNamed:@"Default_Img_Lady_HangOut"] finishHandler:nil];
    
    self.inviteLabel.text = item.text;
    self.nameLabel.text = item.recommendItem.friendNickName;
    self.ageLabel.text = [NSString stringWithFormat:@"%dyrs / ",item.recommendItem.friendAge];
    self.countryLabel.text = item.recommendItem.friendCountry;
}

- (IBAction)inviteHangout:(id)sender {
    if ([self.delagate respondsToSelector:@selector(inviteHangoutAnchor:)]) {
        [self.delagate inviteHangoutAnchor:self.item];
    }
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.headImageView sd_cancelCurrentImageLoad];
    self.headImageView.image = nil;
}

@end
