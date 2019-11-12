//
//  PrivateDriveView.h
//  livestream
//
//  Created by test on 2019/9/6.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudienceModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface PrivateDriveView : UIView
@property (nonatomic, strong) AudienceModel *model;
- (void)showCarAnimation:(CGPoint)point;
@end

NS_ASSUME_NONNULL_END
