//
//  StreamTitleView.h
//  RtmpClientTest
//
//  Created by Max on 2020/11/17.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StreamTitleView : UIView
+ (instancetype)view;
@property (weak) IBOutlet UIImageView *logoImageView;
@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UIActivityIndicatorView *activityView;
@end

NS_ASSUME_NONNULL_END
