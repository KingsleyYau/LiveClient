//
//  LSGiftInfoView.h
//  livestream
//
//  Created by Calvin on 2019/9/9.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSGiftInfoView;
@protocol LSGiftInfoViewDelegate <NSObject>
@optional;
- (void)didCloseGiftInfoView:(LSGiftInfoView *)infoView;
@end

@interface LSGiftInfoView : UIView
 
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *infoHeadBgImageView;

@property (weak, nonatomic) id<LSGiftInfoViewDelegate> delegate;

@end

