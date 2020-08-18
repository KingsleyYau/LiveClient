//
//  LSLadyVideoListCell.h
//  livestream
//
//  Created by Calvin on 2020/8/5.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPremiumVideoinfoItemObject.h"
 
@protocol LSLadyVideoListCellDelegate <NSObject>

- (void)ladyVideoListCellDidFollow:(NSInteger)row;

@end

@interface LSLadyVideoListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) id<LSLadyVideoListCellDelegate> cellDelegate;
+ (NSInteger)cellHeight;
+ (NSString *)cellIdentifier;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)setVideoData:(LSPremiumVideoinfoItemObject*)item;
@end

 
