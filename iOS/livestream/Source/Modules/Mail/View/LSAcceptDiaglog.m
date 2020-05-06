//
//  LSAcceptDiaglog.m
//  livestream
//
//  Created by test on 2020/3/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSAcceptDiaglog.h"
#import "LiveUrlHandler.h"
#import "LiveModule.h"
#import "LSShadowView.h"

@implementation LSAcceptDiaglog
+ (LSAcceptDiaglog *)dialog {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    LSAcceptDiaglog* view = [nibs objectAtIndex:0];
    view.contentView.layer.cornerRadius = 4.0f;
    view.contentView.layer.masksToBounds = YES;
    view.actionBtn.layer.cornerRadius = view.actionBtn.layer.frame.size.height * 0.5f;
    view.actionBtn.layer.masksToBounds = YES;
    [[[LSShadowView alloc] init] showShadowAddView:view.actionBtn];
    
    return view;
}

- (void)showAcceptDiaglog:(UIView *)view {

    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(view);
        }];

    }
}


- (IBAction)hideDialogAction:(id)sender {
    [self removeFromSuperview];
}
- (IBAction)writeToMail:(id)sender {
    [self removeFromSuperview];
    if ([self.acceptDelegate respondsToSelector:@selector(lsAcceptDiaglogAccept:)]) {
        [self.acceptDelegate lsAcceptDiaglogAccept:self];
    }

}

@end
