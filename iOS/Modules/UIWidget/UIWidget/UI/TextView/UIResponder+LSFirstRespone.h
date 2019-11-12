//
//  UIResponder+LSFirstRespone.h
//  UIWidget
//
//  Created by test on 2019/10/21.
//  Copyright © 2019 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (LSFirstRespone)
+ (id)lsKeyboardCurrentFirstResponder;
@end

NS_ASSUME_NONNULL_END
