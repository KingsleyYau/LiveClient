//
//  LSPhotoClipViewController.h
//  livestream
//
//  Created by test on 2018/1/15.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
@class LSPhotoClipViewController;
@protocol LSPhotoClipViewControllerDelegate <NSObject>
@optional
- (void)lsPhotoClipViewController:(LSPhotoClipViewController *)vc didChoosePhoto:(UIImage *)image;
- (void)lsPhotoClipViewControllerDidcancelChoosePhoto:(LSPhotoClipViewController *)vc;
@end

@interface LSPhotoClipViewController : UIViewController

@property (strong, nonatomic) UIImage *targetImage;

/** 代理 */
@property (nonatomic, weak) id<LSPhotoClipViewControllerDelegate> delegate;
@end
