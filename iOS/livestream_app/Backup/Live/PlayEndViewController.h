//
//  PlayEndViewController.h
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

#import "ImageViewLoader.h"

@interface PlayEndViewController : KKViewController

/**
 *   主播头像
 */
@property (nonatomic, weak) IBOutlet UIImageViewTopFit* imageViewHeader;
@property (nonatomic, strong) ImageViewLoader* imageViewHeaderLoader;

/**
 *   主播昵称
 */
@property (weak, nonatomic) IBOutlet UILabel *liverNameLabel;
/**
 *   观众人数
 */
@property (weak, nonatomic) IBOutlet UILabel *viewverLabel;
/**
 *   关注按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
/**
 *   返回主页按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *homepageBtn;

/**
 *   推荐主播头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *hotLiverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *hotLiverImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *hotLiverImageView3;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewerCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreLabel;
@property (weak, nonatomic) IBOutlet UILabel *hotLiverNameLabel1;
@property (weak, nonatomic) IBOutlet UILabel *hotLiverNameLabel2;
@property (weak, nonatomic) IBOutlet UILabel *hotLiverNameLabel3;

/**
 *   主播封面
 */
@property (weak, nonatomic) IBOutlet UIImageView *liverCoverImageView;

/**
 *   底部更多视图
 */
@property (weak, nonatomic) IBOutlet UIView *bottomMoreView;

/**
 点击回到主页按钮
 */
- (IBAction)cancelAction:(id)sender;

/**
 关注主播按钮
 */
- (IBAction)followLiverAction:(id)sender;

- (IBAction)sharefaceBookAction:(id)sender;

- (IBAction)shareTwitterAction:(id)sender;

- (IBAction)shareInstagrmAction:(id)sender;

@end
