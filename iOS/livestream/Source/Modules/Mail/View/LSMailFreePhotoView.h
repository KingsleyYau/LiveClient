//
//  LSMailFreePhotoView.h
//  livestream
//
//  Created by Randy_Fan on 2019/1/8.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSMailFreePhotoView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

- (void)activiViewIsShow:(BOOL)isShow;

@end
