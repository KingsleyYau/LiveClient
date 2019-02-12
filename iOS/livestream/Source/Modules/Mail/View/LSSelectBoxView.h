//
//  LSSelectBoxView.h
//  livestream
//
//  Created by Randy_Fan on 2018/11/22.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSSelectBoxView;
@protocol LSSelectBoxViewDelegate<NSObject>
@optional
- (void)didClickInbox;
- (void)didClickOutbox;
@end

@interface LSSelectBoxView : UIView

@property (nonatomic, weak) id<LSSelectBoxViewDelegate> delegate;

@end
