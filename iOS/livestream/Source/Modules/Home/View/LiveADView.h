//
//  LiveADView.h
//  livestream
//
//  Created by Calvin on 2017/10/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

 
@protocol LiveADViewDelegate<NSObject>

- (void)liveADViewBannerURL:(NSString *)url title:(NSString *)title;
@end

@interface LiveADView : UIView 

@property (nonatomic, weak) id<LiveADViewDelegate> delegate;

- (void)loadAD;
@end
