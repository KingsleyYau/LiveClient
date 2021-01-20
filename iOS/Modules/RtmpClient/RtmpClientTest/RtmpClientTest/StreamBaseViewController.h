//
//  StreamBaseViewController.h
//  RtmpClientTest
//
//  Created by Max on 2020/10/26.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StreamBaseViewController : UIViewController
- (BOOL)isDarkStyle;
- (void)toast:(NSString *)msg;
- (void)showImage:(UIImage *)image fromView:(UIView *)fromView;
@end

NS_ASSUME_NONNULL_END
