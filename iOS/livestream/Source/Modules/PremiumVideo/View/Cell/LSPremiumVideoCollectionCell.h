//
//  LSPremiumVideoCollectionCell.h
//  livestream
//
//  Created by Albert on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSUIImageViewTopFit.h"
#import "LSPremiumVideoListItemObject.h"
#import "LSDurationLabel.h"

@protocol LSPremiumVideoCellDelegate <NSObject>

- (void)premiumVideoCellUserBtnOnClicked:(NSInteger)row;
- (void)premiumVideoCellCollectBtnOnClicked:(NSInteger)row;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LSPremiumVideoCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *corverImgView;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImgView;
@property (weak, nonatomic) IBOutlet UIImageView *onlineImgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

//@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet LSDurationLabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introLabelH;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;

@property (weak, nonatomic) IBOutlet UIButton *collectBtn;

@property (weak, nonatomic) id <LSPremiumVideoCellDelegate>delegate;

+(NSString *)cellIdentifier;
-(void)setVideoItemObject:(LSPremiumVideoListItemObject *)obj;

@end

NS_ASSUME_NONNULL_END
