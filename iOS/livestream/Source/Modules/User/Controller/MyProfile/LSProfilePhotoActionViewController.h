//
//  LSProfilePhotoActionViewController.h
//  livestream
//
//  Created by test on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class LSProfilePhotoActionViewController;
@protocol LSProfilePhotoActionViewControllerDelegate <NSObject>
@optional

/**
 
上传完成操作
 @param vc 操作控制器
 */
- (void)lsProfilePhotoActionViewControllerDidFinishPhotoAction:(LSProfilePhotoActionViewController *)vc;
@end

@interface LSProfilePhotoActionViewController : LSViewController
- (void)showPhotoAction:(UIViewController *)vc;
/** 代理 */
@property (nonatomic, weak) id<LSProfilePhotoActionViewControllerDelegate> actionDelegate;
@end

NS_ASSUME_NONNULL_END
