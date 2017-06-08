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
 点击回到主页按钮
 */
- (IBAction)cancelAction:(id)sender;

@end
