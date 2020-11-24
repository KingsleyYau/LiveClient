//
//  StreamToastView.h
//  RtmpClientTest
//
//  Created by Max on 2020/11/17.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StreamToastView : UIView
+ (instancetype)view;
@property (weak) IBOutlet UILabel *msgLabel;
@end

NS_ASSUME_NONNULL_END
