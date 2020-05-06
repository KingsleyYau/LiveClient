//
//  LSAcceptDiaglog.h
//  livestream
//
//  Created by test on 2020/3/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LSAcceptDiaglog;
@protocol LSAcceptDiaglogDelegate <NSObject>
@optional
- (void)lsAcceptDiaglogAccept:(LSAcceptDiaglog *)view;

@end

@interface LSAcceptDiaglog : UIView
/** 主播id */
@property (nonatomic, copy) NSString *anchorId;
/** 主播名称 */
@property (nonatomic, copy) NSString *anchorName;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
/** 代理 */
@property (nonatomic, weak) id<LSAcceptDiaglogDelegate> acceptDelegate;
+ (LSAcceptDiaglog *)dialog;
- (void)showAcceptDiaglog:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
