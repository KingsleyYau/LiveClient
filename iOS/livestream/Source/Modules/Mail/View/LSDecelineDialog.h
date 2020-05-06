//
//  LSDecelineDialog.h
//  livestream
//
//  Created by test on 2020/3/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LSDecelineDialog;
@protocol LSDecelineDialogDelegate <NSObject>
@optional
- (void)lsDecelineDialogDecline:(LSDecelineDialog *)view;

@end

@interface LSDecelineDialog : UIView
/** 主播id */
@property (nonatomic, copy) NSString *anchorId;
/** 主播名称 */
@property (nonatomic, copy) NSString *anchorName;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
/** 代理 */
@property (nonatomic, weak) id<LSDecelineDialogDelegate> decilineDelegate;
+ (LSDecelineDialog *)dialog;
- (void)showDecelineDialog:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
