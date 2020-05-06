//
//  LSScheduleAcceptCell.h
//  livestream
//
//  Created by Calvin on 2020/4/16.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSScheduleInviteListItemObject.h"
#import "LSPrePaidManager.h"

@protocol LSScheduleAcceptCellDelegate <NSObject>

- (void)scheduleAcceptCellDidAcceptBtn:(NSInteger)row;
- (void)scheduleAcceptCellDidViewBtn:(NSInteger)row;

@end

@interface LSScheduleAcceptCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *localLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;
@property (nonatomic, strong) LSImageViewLoader * imageLoader;
@property (weak, nonatomic) id<LSScheduleAcceptCellDelegate> cellDelegate;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)updateUI:(LSScheduleInviteListItemObject*)item;

@end

 
