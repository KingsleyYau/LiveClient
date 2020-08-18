//
//  LSChatScheduleLadyCell.m
//  livestream
//
//  Created by Calvin on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChatScheduleLadyCell.h"
#import "LSShadowView.h"

@implementation LSChatScheduleLadyCell

+ (NSString *)cellIdentifier {
    return @"LSChatScheduleLadyCell";
}

+ (NSInteger)cellHeight:(BOOL)isMore isAcceptView:(BOOL)isAccept {
    
    if (isAccept) {
        if (isMore) {
            return SCREEN_WIDTH == 320?490:480;
        }
        return 310;
    }
    else {
        if (isMore) {
            return SCREEN_WIDTH == 320?490:480;
        }
        return 286;
    }
    
    return 310;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatScheduleLadyCell *cell = (LSChatScheduleLadyCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatScheduleLadyCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSChatScheduleLadyCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (SCREEN_WIDTH == 320) {
        self.cardViewW.constant = 260;
        self.acceptViewW.constant = 260;
    }else {
        self.cardViewW.constant = 290;
        self.acceptViewW.constant = 290;
    }
    
    self.cardView = [[LSPrepaidCardView alloc]init];
    [self.cardCellView addSubview:self.cardView];
    
    [self.cardView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardCellView);
        make.left.equalTo(self.cardCellView);
        make.width.equalTo(self.cardCellView);
        make.bottom.equalTo(self.cardCellView);
    }];
    
    self.acceptView = [[LSPrepaidAcceptCardView alloc]init];
    [self.acceptCellView addSubview:self.acceptView];
    
    [self.acceptView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.acceptCellView);
        make.left.equalTo(self.acceptCellView);
        make.width.equalTo(self.acceptCellView);
        make.bottom.equalTo(self.acceptCellView);
    }];
    
    self.acceptView.layer.cornerRadius = 8;
    self.acceptView.layer.masksToBounds = YES;
    LSShadowView * view1 = [[LSShadowView alloc]init];
    [view1 showShadowAddView:self.acceptView];
    
    self.cardView.layer.cornerRadius = 8;
    self.cardView.layer.masksToBounds = YES;
    LSShadowView * view = [[LSShadowView alloc]init];
    [view showShadowAddView:self.cardView];
    
    self.acceptView.delegate = self;
    self.cardView.delegate = self;
}

- (void)updateAcceptData:(QNMessage *)item {
    self.acceptCellView.hidden = NO;
    self.cardCellView.hidden = YES;
    [self.acceptView updateUI:item];
}

- (void)updateCardData:(QNMessage *)item ladyName:(NSString *)name{
    self.acceptCellView.hidden = YES;
    self.cardCellView.hidden = NO;
    [self.cardView updateUI:item ladyName:name];
}

#pragma mark - AcceptViewDeleagte
- (void)prepaidAcceptCardViewDidAcceptBtn {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellDidAccept:)]) {
        [self.cellDelegate chatScheduleladyCellDidAccept:self.tag];
    }
}

- (void)prepaidAcceptCardViewHidenDetalis {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellHidenDetalis:)]) {
        [self.cellDelegate chatScheduleladyCellHidenDetalis:self.tag];
    }
}

- (void)prepaidAcceptCardViewShowDetalis {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellShowDetalis:)]) {
        [self.cellDelegate chatScheduleladyCellShowDetalis:self.tag];
    }
}

- (void)prepaidAcceptCardViewDidDuration {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellDidDurationRow:)]) {
        [self.cellDelegate chatScheduleladyCellDidDurationRow:self.tag];
    }
}

- (void)prepaidAcceptCardViewDidOpenScheduleList {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellDidOpenScheduleList)]) {
        [self.cellDelegate chatScheduleladyCellDidOpenScheduleList];
    }
}

- (void)prepaidAcceptCardViewDidLearnHowWorks {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellDidLearnHowWorks)]) {
        [self.cellDelegate chatScheduleladyCellDidLearnHowWorks];
    }
}

#pragma - mark - CardViewDelegate
- (void)prepaidCardViewHidenDetalis {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellHidenDetalis:)]) {
        [self.cellDelegate chatScheduleladyCellHidenDetalis:self.tag];
    }
}

- (void)prepaidCardViewShowDetalis {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellShowDetalis:)]) {
        [self.cellDelegate chatScheduleladyCellShowDetalis:self.tag];
    }
}

- (void)prepaidCardViewDidLearnHowWorks {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellDidLearnHowWorks)]) {
        [self.cellDelegate chatScheduleladyCellDidLearnHowWorks];
    }
}

- (void)prepaidCardViewDidOpenScheduleList {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleladyCellDidOpenScheduleList)]) {
        [self.cellDelegate chatScheduleladyCellDidOpenScheduleList];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
