//
//  LSVideoProgressView.h
//  dating
//
//  Created by Calvin on 17/6/29.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSVideoProgressViewDelegate <NSObject>
- (void)videoProgressViewIsPlaying:(BOOL)isPause;
@end

@interface LSVideoProgressView : UIView
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *beginLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) id <LSVideoProgressViewDelegate> delegate;
- (void)setPlayButtonSelected;
@end
