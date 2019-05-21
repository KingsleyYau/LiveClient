//
//  LSSayHiDetailAddCreditsCell.h
//  livestream
//
//  Created by Calvin on 2019/5/5.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSSayHiDetailAddCreditsCellDelegate <NSObject>

- (void)sayHiDetailAddCreditsCellBtnDid;

@end

@interface LSSayHiDetailAddCreditsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLbael;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) id<LSSayHiDetailAddCreditsCellDelegate> cellDelegate;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)setLadyName:(NSString *)name;
@end
