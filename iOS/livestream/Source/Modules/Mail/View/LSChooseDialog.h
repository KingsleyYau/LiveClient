//
//  LSChooseDialog.h
//  livestream
//
//  Created by test on 2020/3/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^DialogCancelBlock)(void);
typedef void (^DialogActionBlock)(void);
@interface LSChooseDialog : UIView
+ (LSChooseDialog *)dialog;
- (void)showDialog:(UIView *)view cancelBlock:(DialogCancelBlock)cancelBlock actionBlock:(DialogActionBlock)actionBlock;
@end

NS_ASSUME_NONNULL_END
