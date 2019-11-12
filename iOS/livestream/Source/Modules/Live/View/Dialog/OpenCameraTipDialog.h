//
//  OpenCameraTipDialog.h
//  livestream
//
//  Created by Calvin on 2019/6/10.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface OpenCameraTipDialog : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet BEMCheckBox *checkBox;
@property (nonatomic, assign) BOOL isShow;

+ (OpenCameraTipDialog *)dialogTip;
- (void)showDialog:(UIView *)view andLadyPhoto:(NSString *)ladyPhoto cancelBlock:(void(^)())cancelBlock actionBlock:(void(^)())actionBlock;
@end
 
