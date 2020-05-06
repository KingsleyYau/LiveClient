//
//  LSMyContactsListCell.m
//  livestream
//
//  Created by Calvin on 2019/6/20.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMyContactsListCell.h"
#import "LSDateTool.h"

typedef enum ContactType {
    ContactType_None = 0,
    ContactType_Book,
    ContactType_Invite,
    ContactType_Chat,
    ContactType_Mail,
}ContactType;

@implementation LSMyContactsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.ladyHead.layer.cornerRadius = self.ladyHead.tx_height/2;
    self.ladyHead.layer.masksToBounds = YES;
    
    self.liveIcon.layer.cornerRadius = self.liveIcon.tx_height/2;
    self.liveIcon.layer.masksToBounds = YES;
    
    self.imageViewLoader = [LSImageViewLoader loader];
}

+ (NSString *)cellIdentifier {
    return @"LSMyContactsListCell";
}

+ (NSInteger)cellHeight {
    return 72;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSMyContactsListCell *cell = (LSMyContactsListCell *)[tableView dequeueReusableCellWithIdentifier:[LSMyContactsListCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSMyContactsListCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)setFavoitesCellMoreView:(LSRecommendAnchorItemObject *)item {
    
    self.nameLabel.text = item.anchorNickName;
    
    [self.imageViewLoader loadImageWithImageView:self.ladyHead options:0 imageUrl:item.anchorAvatar placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
    }];
    
    self.timeLabel.text = [NSString stringWithFormat:@"Last Contacted:%@",[LSDateTool getTime:item.lastCountactTime]];
    
    if (item.onlineStatus == ONLINE_STATUS_LIVE) {
        
        self.onlineIcon.hidden = NO;
        
        // 公开直播间显示Icon
        self.liveIcon.hidden = item.roomType == HTTPROOMTYPE_FREEPUBLICLIVEROOM || item.roomType == HTTPROOMTYPE_CHARGEPUBLICLIVEROOM ? NO : YES;
        
        // 是否有私密邀请的权限权限
        if (item.priv.isHasOneOnOneAuth) {
            [self showSlidingFirType:ContactType_Invite secType:ContactType_Chat];
        } else {
            [self showSlidingFirType:ContactType_Chat secType:ContactType_Mail];
        }
    } else {
        // 不在线
        self.onlineIcon.hidden = YES;
        self.liveIcon.hidden = YES;
          //关闭预约,隐藏按钮
          [self showSlidingFirType:ContactType_None secType:ContactType_Mail];
//        if (item.priv.isHasBookingAuth) {
//            [self showSlidingFirType:ContactType_Mail secType:ContactType_Book];
//        } else {
//            [self showSlidingFirType:ContactType_None secType:ContactType_Mail];
//        }
    }
}

- (void)showSlidingFirType:(ContactType)firType secType:(ContactType)secType {
    self.firstBtn.tag = firType;
    self.secondBtn.tag = secType;
    
    self.firstBtnWidth.constant = 40;
    
    switch (firType) {
        case ContactType_Book:{
            [self.firstBtn setImage:[UIImage imageNamed:@"LS_Mycontacts_Book"] forState:UIControlStateNormal];
        }break;
        case ContactType_Invite:{
            [self.firstBtn setImage:[UIImage imageNamed:@"LS_Mycontacts_Invite"] forState:UIControlStateNormal];
        }break;
        case ContactType_Chat:{
            [self.firstBtn setImage:[UIImage imageNamed:@"LS_Mycontacts_Chat"] forState:UIControlStateNormal];
        }break;
        case ContactType_Mail:{
            [self.firstBtn setImage:[UIImage imageNamed:@"LS_Mycontacts_Mail"] forState:UIControlStateNormal];
        }break;
        default:{
            self.firstBtnWidth.constant = 0;
        }break;
    }
    
    switch (secType) {
        case ContactType_Book:{
            [self.secondBtn setImage:[UIImage imageNamed:@"LS_Mycontacts_Book"] forState:UIControlStateNormal];
        }break;
        case ContactType_Invite:{
            [self.secondBtn setImage:[UIImage imageNamed:@"LS_Mycontacts_Invite"] forState:UIControlStateNormal];
        }break;
        case ContactType_Chat:{
            [self.secondBtn setImage:[UIImage imageNamed:@"LS_Mycontacts_Chat"] forState:UIControlStateNormal];
        }break;
        case ContactType_Mail:{
            [self.secondBtn setImage:[UIImage imageNamed:@"LS_Mycontacts_Mail"] forState:UIControlStateNormal];
        }break;
        default:{
        }break;
    }
}

- (IBAction)clickContactAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self slidingViewBtnDidRow:(ContactType)btn.tag];
}

- (void)slidingViewBtnDidRow:(ContactType)type {
    switch (type) {
        case ContactType_Book:{
            if ([self.cellDelegate respondsToSelector:@selector(myContactListTableViewCellDidClickBookBtn:)]) {
                [self.cellDelegate myContactListTableViewCellDidClickBookBtn:self];
            }
        }break;
        case ContactType_Invite:{
            if ([self.cellDelegate respondsToSelector:@selector(myContactListTableViewCellDidClickInviteBtn:)]) {
                [self.cellDelegate myContactListTableViewCellDidClickInviteBtn:self];
            }
        }break;
        case ContactType_Chat:{
            if ([self.cellDelegate respondsToSelector:@selector(myContactListTableViewCellDidClickChatBtn:)]) {
                [self.cellDelegate myContactListTableViewCellDidClickChatBtn:self];
            }
        }break;
        case ContactType_Mail:{
            if ([self.cellDelegate respondsToSelector:@selector(myContactListTableViewCellDidClickMailBtn:)]) {
                [self.cellDelegate myContactListTableViewCellDidClickMailBtn:self];
            }
        }break;
        default:{
        }break;
    }
}

@end
