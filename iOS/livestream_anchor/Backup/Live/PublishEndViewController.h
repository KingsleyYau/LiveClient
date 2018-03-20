//
//  PublishEndViewController.h
//  livestream
//
//  Created by Max on 2017/6/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

@interface PublishEndViewController : KKViewController

/**
 *  直播时长
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

/**
 *  钻石数
 */
@property (weak, nonatomic) IBOutlet UILabel *diamondNumLabel;

/**
 *  观众数
 */
@property (weak, nonatomic) IBOutlet UILabel *viewerNumLabel;

/**
 *  新粉丝数
 */
@property (weak, nonatomic) IBOutlet UILabel *fanNewNumLabel;

/**
 *  分享数
 */
@property (weak, nonatomic) IBOutlet UILabel *shareNumLabel;

/**
 *  主播封面
 */
@property (weak, nonatomic) IBOutlet UIImageView *liverCoverImageView;

/**
 *  返回按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *homeBtn;

- (IBAction)twitterAction:(UIButton *)sender;

- (IBAction)faceBookAction:(UIButton *)sender;

- (IBAction)instagramAction:(UIButton *)sender;

/**
 点击回到主页按钮
 
 @param sender <#sender description#>
 */
- (IBAction)cancelAction:(id)sender;

@end
