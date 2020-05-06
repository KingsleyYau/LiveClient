//
//  LSScheduleActionCell.m
//  livestream
//
//  Created by test on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleActionCell.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LSShadowView.h"
@interface LSScheduleActionCell()
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptReplyBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherAction;
@property (weak, nonatomic) IBOutlet UIButton *replyMailBtn;

@property (strong, nonatomic) LSHttpLetterDetailItemObject *mailItem;
@property (strong, nonatomic) LSScheduleInviteDetailItemObject *detailItem;
@end

@implementation LSScheduleActionCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupUI];

}

// 总显示高度
+ (CGFloat)cellTotalHeight {
    return 180;
}

// 一个按钮高度
+ (CGFloat)cellOneBtnHeight {
    return 96;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSScheduleActionCell *cell = (LSScheduleActionCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleActionCell cellIdentifier]];
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSScheduleActionCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

+ (NSString *)cellIdentifier {
    return @"LSScheduleActionCell";
}


- (void)setupUI {
    self.acceptBtn.layer.cornerRadius = self.acceptBtn.frame.size.height * 0.5f;
    self.acceptBtn.layer.masksToBounds = YES;
    LSShadowView *shadow1 = [[LSShadowView alloc] init];
    [shadow1 showShadowAddView:self.acceptBtn];
    
    
    self.acceptReplyBtn.layer.cornerRadius = self.acceptReplyBtn.frame.size.height * 0.5f;
    self.acceptReplyBtn.layer.masksToBounds = YES;
    self.acceptReplyBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x999999).CGColor;
    self.acceptReplyBtn.layer.borderWidth = 1;
    
    self.replyMailBtn.layer.cornerRadius = self.replyMailBtn.frame.size.height * 0.5f;
    self.replyMailBtn.layer.masksToBounds = YES;
    LSShadowView *shadow2 = [[LSShadowView alloc] init];
    [shadow2 showShadowAddView:self.replyMailBtn];
    
    self.oneOnOneBtn.layer.cornerRadius = self.oneOnOneBtn.frame.size.height * 0.5f;
    self.oneOnOneBtn.layer.masksToBounds = YES;
    LSShadowView *shadow3 = [[LSShadowView alloc] init];
    [shadow3 showShadowAddView:self.oneOnOneBtn];
    self.oneOnOneBtn.hidden = YES;
    
    NSString *otherTitle = @"Other options";
    NSMutableAttributedString *otherTitleAtts = [[NSMutableAttributedString alloc] initWithString:otherTitle attributes:@{
        NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],
        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x666666),
        NSUnderlineColorAttributeName : COLOR_WITH_16BAND_RGB(0x666666)
    }];
    [self.otherAction setAttributedTitle:otherTitleAtts forState:UIControlStateNormal];
}

// 更新信件详情内容
- (void)updateMailScheduelUI:(LSHttpLetterDetailItemObject *)item {
    self.mailItem = item;
    self.oneOnOneBtn.hidden = YES;
    if (item.scheduleInfo.status != LSSCHEDULEINVITESTATUS_PENDING) {
        self.acceptBtn.hidden = YES;
        self.acceptReplyBtn.hidden = YES;
        self.otherAction.hidden = YES;
        self.replyMailBtn.hidden = NO;
    }else {
        self.acceptBtn.hidden = NO;
        self.acceptReplyBtn.hidden = NO;
        self.otherAction.hidden = NO;
        self.replyMailBtn.hidden = YES;
    }
}


// 更新预约详情内容
- (void)updateScheduelDetailUI:(LSScheduleInviteDetailItemObject *)item {
    self.detailItem = item;
    if (item.status == LSSCHEDULEINVITESTATUS_PENDING) {
        self.acceptBtn.hidden = NO;
        self.acceptReplyBtn.hidden = NO;
        self.otherAction.hidden = NO;
        self.replyMailBtn.hidden = YES;
        self.oneOnOneBtn.hidden = YES;
    } else {
        self.acceptBtn.hidden = YES;
        self.acceptReplyBtn.hidden = YES;
        self.otherAction.hidden = YES;
        self.replyMailBtn.hidden = YES;
        self.oneOnOneBtn.hidden = YES;
        if (item.status == LSSCHEDULEINVITESTATUS_CONFIRMED && !item.isActive && item.startTime - [[NSDate date] timeIntervalSince1970] < 0) {
            self.oneOnOneBtn.hidden = NO;
        }
    }
}


// 更多操作
- (IBAction)otherAction:(UIButton *)sender {
    if ([self.actionDelegate respondsToSelector:@selector(lsScheduleActionCell:didClickOther:)]) {
        [self.actionDelegate lsScheduleActionCell:self didClickOther:sender];
    }
}

// 接受处理
- (IBAction)acceptAction:(UIButton *)sender {
    if ([self.actionDelegate respondsToSelector:@selector(lsScheduleActionCell:didAcceptSchedule:)]) {
        [self.actionDelegate lsScheduleActionCell:self didAcceptSchedule:sender];
    }
    
}

// 接受并回复处理
- (IBAction)acceptReplyAction:(UIButton *)sender {
    if ([self.actionDelegate respondsToSelector:@selector(lsScheduleActionCell:didAcceptScheduleByReplyMail:)]) {
        [self.actionDelegate lsScheduleActionCell:self didAcceptScheduleByReplyMail:sender];
    }
}

// 回信操作
- (IBAction)replyMailAction:(id)sender {
    NSURL *url = [[LiveUrlHandler shareInstance] createSendmailByanchorId:self.mailItem.anchorId anchorName:self.mailItem.anchorNickName emfiId:self.mailItem.letterId];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

// 直接私密
- (IBAction)oneOnOneAction:(id)sender {
    // TODO:点击立即付费豪华私密
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorName:self.anchorName anchorId:self.detailItem.anchorId roomType:LiveRoomType_Private];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

@end
