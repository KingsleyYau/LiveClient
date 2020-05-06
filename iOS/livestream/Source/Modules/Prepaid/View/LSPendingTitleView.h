//
//  LSPendingTitleView.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSPendingTitleView : UIView

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIView *numView;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *pendLabel;


+ (CGFloat)viewHeight;

@end

NS_ASSUME_NONNULL_END
