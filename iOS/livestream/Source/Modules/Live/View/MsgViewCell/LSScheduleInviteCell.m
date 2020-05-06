//
//  LSScheduleInviteCell.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/16.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleInviteCell.h"
#import "LSShadowView.h"

@interface LSScheduleInviteCell()<LSPrepaidCardViewDelegate,LSPrepaidAcceptCardViewDelegate>
@property (nonatomic, assign) BOOL isMinimum;
@end

@implementation LSScheduleInviteCell

+ (NSString *)cellIdentifier {
    return @"LSScheduleInviteCell";
}

+ (NSInteger)cellHeight:(BOOL)isMore isAcceptView:(BOOL)isAccept isMinimum:(BOOL)isMinimum {
    CGFloat height = 0;
    if (isMinimum) {
        height = 63;
    } else {
        if (isAccept) {
            height = 317;
            if (isMore) {
                height = SCREEN_WIDTH < 375 ? 500 : 480;
            }
        } else {
            height = 294;
            if (isMore) {
                height = SCREEN_WIDTH < 375 ? 500 : 480;
            }
        }
    }
    return height;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSScheduleInviteCell *cell = (LSScheduleInviteCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleInviteCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSScheduleInviteCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.cardSubView = [[LSPrepaidCardView alloc] init];
        cell.cardSubView.delegate = cell;
        [cell.cardView addSubview:cell.cardSubView];
        [cell.cardSubView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.cardView);
        }];
        cell.acceptSubView = [[LSPrepaidAcceptCardView alloc] init];
        cell.acceptSubView.delegate = cell;
        [cell.acceptView addSubview:cell.acceptSubView];
        [cell.acceptSubView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.acceptView);
        }];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.nameView.layer.cornerRadius = 5;
    self.nameView.layer.masksToBounds = YES;
    
    self.minimumView.layer.cornerRadius = 8;
    self.minimumView.layer.masksToBounds = YES;
    
    self.cardView.layer.cornerRadius = 8;
    self.cardView.layer.masksToBounds = YES;
    LSShadowView * view = [[LSShadowView alloc] init];
    [view showShadowAddView:self.cardView];
    
    self.acceptView.layer.cornerRadius = 8;
    self.acceptView.layer.masksToBounds = YES;
    LSShadowView * view1 = [[LSShadowView alloc] init];
    [view1 showShadowAddView:self.acceptView];
}

- (void)updateAcceptData:(MsgItem *)item {
    self.isMinimum = item.isMinimu;
    self.nameView.backgroundColor = COLOR_WITH_16BAND_RGB(0x00cc66);
    self.sendNameLabel.text = item.sendName;
    self.atNameLabel.text = item.toName;
    self.acceptView.hidden = NO;
    self.cardView.hidden = YES;
    self.minimumView.hidden = YES;
    [self.acceptSubView updateInfo:item];
}

- (void)updateCardData:(MsgItem *)item anchorName:(NSString *)anchorName {
    self.isMinimum = item.isMinimu;
    self.sendNameLabel.text = item.sendName;
    self.atNameLabel.text = item.toName;
    if (item.usersType == UsersType_Liver) {
        self.nameView.backgroundColor = COLOR_WITH_16BAND_RGB(0x00cc66);
    } else {
        self.nameView.backgroundColor = COLOR_WITH_16BAND_RGB(0xff9901);
    }
    self.minimumView.hidden = YES;
    self.acceptView.hidden = YES;
    self.cardView.hidden = NO;
    [self.cardSubView updataInfo:item ladyName:anchorName];
}

- (void)showMinimumView:(MsgItem *)item {
    self.isMinimum = item.isMinimu;
    self.sendNameLabel.text = item.sendName;
    self.atNameLabel.text = item.toName;
    if (item.usersType == UsersType_Liver) {
        self.nameView.backgroundColor = COLOR_WITH_16BAND_RGB(0x00cc66);
    } else {
        self.nameView.backgroundColor = COLOR_WITH_16BAND_RGB(0xff9901);
    }
    self.minimumView.hidden = NO;
    self.acceptView.hidden = YES;
    self.cardView.hidden = YES;
}

- (IBAction)minimumDid:(id)sender {
    self.isMinimum = !self.isMinimum;
    if (self.isMinimum) {
        self.minimumBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        self.minimumBtn.imageView.transform = CGAffineTransformIdentity;
    }
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellDidMinimum:isMinimum:)]) {
        [self.delegate liveScheduleInviteCellDidMinimum:self isMinimum:self.isMinimum];
    }
}

#pragma mark - LSPrepaidCardViewDelegate
- (void)prepaidCardViewHidenDetalis {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellHidenDetalis:)]) {
        [self.delegate liveScheduleInviteCellHidenDetalis:self];
    }
}

- (void)prepaidCardViewShowDetalis {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellShowDetalis:)]) {
        [self.delegate liveScheduleInviteCellShowDetalis:self];
    }
}

- (void)prepaidCardViewDidLearnHowWorks {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellDidLearnHowWorks)]) {
        [self.delegate liveScheduleInviteCellDidLearnHowWorks];
    }
}

- (void)prepaidCardViewDidOpenScheduleList {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellDidOpenScheduleList)]) {
        [self.delegate liveScheduleInviteCellDidOpenScheduleList];
    }
}

#pragma mark - LSPrepaidAcceptCardViewDelegate
- (void)prepaidAcceptCardViewDidAcceptBtn {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellDidAccept:)]) {
        [self.delegate liveScheduleInviteCellDidAccept:self];
    }
}

- (void)prepaidAcceptCardViewHidenDetalis {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellHidenDetalis:)]) {
        [self.delegate liveScheduleInviteCellHidenDetalis:self];
    }
}

- (void)prepaidAcceptCardViewShowDetalis {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellShowDetalis:)]) {
        [self.delegate liveScheduleInviteCellShowDetalis:self];
    }
}

- (void)prepaidAcceptCardViewDidDuration {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellDidDurationRow:)]) {
        [self.delegate liveScheduleInviteCellDidDurationRow:self];
    }
}

- (void)prepaidAcceptCardViewDidOpenScheduleList {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellDidOpenScheduleList)]) {
        [self.delegate liveScheduleInviteCellDidOpenScheduleList];
    }
}

- (void)prepaidAcceptCardViewDidLearnHowWorks {
    if ([self.delegate respondsToSelector:@selector(liveScheduleInviteCellDidLearnHowWorks)]) {
        [self.delegate liveScheduleInviteCellDidLearnHowWorks];
    }
}

@end
