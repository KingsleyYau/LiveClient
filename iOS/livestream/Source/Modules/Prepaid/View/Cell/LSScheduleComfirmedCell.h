//
//  LSScheduleComfirmedCell.h
//  livestream
//
//  Created by Calvin on 2020/4/16.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSScheduleInviteListItemObject.h"
#import "LSPrePaidManager.h"

@protocol LSScheduleComfirmedCellDelegate <NSObject>

- (void)scheduleComfirmedCellDidStartBtn:(NSInteger)row;

@end

@interface LSScheduleComfirmedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *localLabel;
@property (weak, nonatomic) IBOutlet UIButton *scheduleIDBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *willLabel;
@property (nonatomic, strong) LSImageViewLoader * imageLoader;
@property (weak, nonatomic) id<LSScheduleComfirmedCellDelegate> cellDeleagte;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(LSScheduleInviteListItemObject *)item;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)updateUI:(LSScheduleInviteListItemObject *)item ;
@end

 
