//
//  LiveHeadView.h
//  livestream_anchor
//
//  Created by randy on 2018/2/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LiveHeadView;
@protocol LiveHeadViewDelegate <NSObject>
@optional

- (void)liveHeadCloseAction:(LiveHeadView *)liveHeadView;
- (void)liveHeadChangeCameraAction:(LiveHeadView *)liveHeadView;

@end

@interface LiveHeadView : UIView

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;

@property (weak, nonatomic) id<LiveHeadViewDelegate> delegate;

@end
