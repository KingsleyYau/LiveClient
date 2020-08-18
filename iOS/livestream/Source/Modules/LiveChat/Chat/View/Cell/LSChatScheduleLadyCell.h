//
//  LSChatScheduleLadyCell.h
//  livestream
//
//  Created by Calvin on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPrepaidCardView.h"
#import "LSPrepaidAcceptCardView.h"
#import "QNMessage.h"

 @protocol LSChatScheduleLadyCellDelegate <NSObject>

- (void)chatScheduleladyCellDidAccept:(NSInteger)row;
- (void)chatScheduleladyCellDidDurationRow:(NSInteger)row;

- (void)chatScheduleladyCellHidenDetalis:(NSInteger)row;
- (void)chatScheduleladyCellShowDetalis:(NSInteger)row;
- (void)chatScheduleladyCellDidOpenScheduleList;
- (void)chatScheduleladyCellDidLearnHowWorks;
 @end

@interface LSChatScheduleLadyCell : UITableViewCell <LSPrepaidCardViewDelegate,LSPrepaidAcceptCardViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *cardCellView;
@property (weak, nonatomic) IBOutlet UIView *acceptCellView;

@property (strong, nonatomic) LSPrepaidCardView *cardView;
@property (strong, nonatomic) LSPrepaidAcceptCardView *acceptView;
@property (weak, nonatomic) id<LSChatScheduleLadyCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardViewW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptViewW;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(BOOL)isMore isAcceptView:(BOOL)isAccept;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)updateCardData:(QNMessage *)item ladyName:(NSString *)name;
- (void)updateAcceptData:(QNMessage *)item;
@end
 
