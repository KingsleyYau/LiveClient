//
//  BaseViewController.h
//  Cartoon
//
//  Created by Max on 2021/5/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
/**
 界面是否第一次显示
 */
@property (assign, readonly) BOOL viewDidAppearEver;
/**
 界面是否正在显示
 */
@property (assign, readonly) BOOL viewIsAppear;
- (void)toast:(NSString *)msg;
- (void)showLoading;
- (void)hideLoading;
- (BOOL)isDarkStyle;
- (void)showImage:(UIImage *)image fromView:(UIView *)fromView;
@end

NS_ASSUME_NONNULL_END
