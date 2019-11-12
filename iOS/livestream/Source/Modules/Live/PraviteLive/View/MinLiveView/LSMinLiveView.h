//
//  LSMinLiveView.h
//  livestream
//
//  Created by Calvin on 2019/11/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImageView.h"

@protocol LSMinLiveViewDelegate <NSObject>

- (void)minLiveViewDidCloseBtn;

- (void)minLiveViewDidVideo;

@end

@interface LSMinLiveView : UIView

@property (nonatomic, weak) id<LSMinLiveViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet GPUImageView *videoView;
@end
 
