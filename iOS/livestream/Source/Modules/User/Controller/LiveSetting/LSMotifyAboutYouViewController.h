//
//  MotifyAboutYouViewController.h
//  dating
//
//  Created by test on 2018/9/18.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@class LSMotifyAboutYouViewController;
@protocol LSMotifyAboutYouViewControllerDelegate <NSObject>
@optional
- (void)lsMotifyAboutYouViewControllerDidMotifyResume:(LSMotifyAboutYouViewController *)vc;

@end

@interface LSMotifyAboutYouViewController :LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UITextView *aboutYouTextView;
@property (weak, nonatomic) IBOutlet UILabel *aboutYouPlaceholderLabel;
/** 关于内容 */
@property (nonatomic, copy) NSString *aboutYouContent;
/** 代理 */
@property (nonatomic, weak) id<LSMotifyAboutYouViewControllerDelegate> motifyDelegate;
@end
