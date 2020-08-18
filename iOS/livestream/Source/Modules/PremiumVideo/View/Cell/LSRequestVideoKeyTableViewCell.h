//
//  LSRequestVideoKeyTableViewCell.h
//  livestream
//
//  Created by Albert on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSUIImageViewTopFit.h"
#import "LSDurationLabel.h"

@protocol LSRequestVideoKeyTableViewCellDelegate <NSObject>

- (void)requestVideoKeyCellCollectBtnOnDid:(NSInteger)row;
- (void)requestVideoKeyCellViewKeyBtnOnDid:(NSInteger)row;
- (void)requestVideoKeyCellUserBtnOnDid:(NSInteger)row;
//- (void)requestVideoKeyCellHeadOnDid:(NSInteger)row;
@end

NS_ASSUME_NONNULL_BEGIN

@interface LSRequestVideoKeyTableViewCell : UITableViewCell

@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;

@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *corverImgView;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImgView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UILabel *expiryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet LSDurationLabel *durationLabel;

@property (weak, nonatomic) IBOutlet UIButton *collectBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewKeyBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewKeyBtnW;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelH;

@property (nonatomic, weak) id <LSRequestVideoKeyTableViewCellDelegate> delegate;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end

NS_ASSUME_NONNULL_END
