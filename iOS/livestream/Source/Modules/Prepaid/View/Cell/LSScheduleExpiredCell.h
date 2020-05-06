//
//  LSScheduleExpiredCell.h
//  livestream
//
//  Created by Calvin on 2020/4/16.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSScheduleInviteListItemObject.h"
#import "LSPrePaidManager.h"
@interface LSScheduleExpiredCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *localLabel;
@property (nonatomic, strong) LSImageViewLoader * imageLoader;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)updateUI:(LSScheduleInviteListItemObject*)item;
@end

 
