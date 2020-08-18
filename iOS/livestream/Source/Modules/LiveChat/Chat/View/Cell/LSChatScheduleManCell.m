//
//  LSChatScheduleManCell.m
//  livestream
//
//  Created by Calvin on 2020/4/10.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChatScheduleManCell.h"
#import "LSShadowView.h"
@implementation LSChatScheduleManCell

+ (NSString *)cellIdentifier {
    return @"LSChatScheduleManCell";
}

+ (NSInteger)cellHeight:(BOOL)isMore{
    if (isMore) {
        return SCREEN_WIDTH == 320?490:480;
    }
    return 286;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatScheduleManCell *cell = (LSChatScheduleManCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatScheduleManCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSChatScheduleManCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (SCREEN_WIDTH == 320) {
        self.cardViewW.constant = 260;
    }else {
        self.cardViewW.constant = 290;
    }

      self.cardView = [[LSPrepaidCardView alloc]init];
      [self.cardCellView addSubview:self.cardView];
    
    self.cardView.layer.cornerRadius = 8;
    self.cardView.layer.masksToBounds = YES;
    
    LSShadowView * view = [[LSShadowView alloc]init];
    [view showShadowAddView:self.cardView];
    
    self.cardView.delegate = self;
    
      [self.cardView mas_updateConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.cardCellView);
          make.left.equalTo(self.cardCellView);
          make.width.equalTo(self.cardCellView);
          make.bottom.equalTo(self.cardCellView);
      }];
}

- (void)updateCardData:(QNMessage *)item ladyName:(NSString *)name{
    [self.cardView updateUI:item ladyName:name];
}

- (void)prepaidCardViewHidenDetalis {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleManCellHidenDetalis:)]) {
        [self.cellDelegate chatScheduleManCellHidenDetalis:self.tag];
    }
}

- (void)prepaidCardViewShowDetalis {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleManCellShowDetalis:)]) {
        [self.cellDelegate chatScheduleManCellShowDetalis:self.tag];
    }
}

- (void)prepaidCardViewDidLearnHowWorks {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleManCellDidLearnHowWorks)]) {
        [self.cellDelegate chatScheduleManCellDidLearnHowWorks];
    }
}

- (void)prepaidCardViewDidOpenScheduleList {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleManCellDidOpenScheduleList)]) {
        [self.cellDelegate chatScheduleManCellDidOpenScheduleList];
    }
}

- (IBAction)retryBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(chatScheduleManCellDidRetryBtn:)]) {
        [self.cellDelegate chatScheduleManCellDidRetryBtn:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
