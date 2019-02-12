//
//  ManDetailTableViewCell.h
//  dating
//
//  Created by test on 2017/4/28.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSManDetailTableViewCell;
@protocol LSManDetailTableViewCellDelegate <NSObject>

@optional
- (void)lsManDetailTableViewCell:(LSManDetailTableViewCell *)cell didClickEditBtnIndex:(NSInteger)index;

@end



@interface LSManDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *detailMsg;
@property (weak, nonatomic) IBOutlet UILabel *manDetail;


/** 编辑信息数组 */
@property (nonatomic, copy) NSArray* manProfileEditMsg;
/** 代理 */
@property (nonatomic, weak) id<LSManDetailTableViewCellDelegate> manDetailDelegate;

//标识符
+ (NSString *)cellIdentifier;
/* 高度 */
+ (NSInteger)cellHeight;
//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView;

@end
