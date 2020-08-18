//
//  LSPremiumTipsTableViewCell.h
//  livestream
//
//  Created by Albert on 2020/8/5.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSPremiumRequestFooterView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSPremiumTipsTableViewCell : UITableViewCell

@property (strong, nonatomic) LSPremiumRequestFooterView *mainView;

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *richLabel;

@property (weak, nonatomic) NSLayoutConstraint *tipsLabelH;
@property (weak, nonatomic) NSLayoutConstraint *richLabelH;

+(NSString *)cellIdentifier;
+ (id)getUITableViewCell:(UITableView*)tableView;
-(void)setTipText:(NSString *)txt;

@end

NS_ASSUME_NONNULL_END
