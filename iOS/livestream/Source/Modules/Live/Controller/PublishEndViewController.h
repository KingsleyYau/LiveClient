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
@property (weak, nonatomic) IBOutlet UIButton *timeButton;

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



- (IBAction)faceBookAction:(UIButton *)sender;

/**
 点击回到主页按钮
 
 @param sender <#sender description#>
 */
- (IBAction)cancelAction:(id)sender;

@end
