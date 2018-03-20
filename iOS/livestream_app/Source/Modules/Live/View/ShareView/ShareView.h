//
//  ShareView.h
//  livestream
//
//  Created by randy on 2017/12/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareView;
@protocol ShareViewDelegate <NSObject>
- (void)facebookShareAction:(ShareView *)shareView;
- (void)copyLinkShareAction:(ShareView *)shareView;
- (void)moreShareAction:(ShareView *)shareView;
@end

@interface ShareView : UIView

@property (nonatomic, weak) id<ShareViewDelegate> delagate;

@end
