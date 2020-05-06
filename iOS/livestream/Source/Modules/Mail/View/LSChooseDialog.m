//
//  LSChooseDialog.m
//  livestream
//
//  Created by test on 2020/3/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChooseDialog.h"

@interface LSChooseDialog()

@property (nonatomic,copy) DialogCancelBlock cancelBlock;
@property (nonatomic,copy) DialogActionBlock actionBlock;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *yesLabel;
@property (weak, nonatomic) IBOutlet UIButton *noLabel;


@end

@implementation LSChooseDialog
+ (LSChooseDialog *)dialog {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    LSChooseDialog* view = [nibs objectAtIndex:0];
    
    view.contentView.layer.cornerRadius = 4.0f;
    view.contentView.layer.masksToBounds = YES;
    view.yesLabel.layer.cornerRadius = 22.0f;
    view.yesLabel.layer.masksToBounds = YES;
    view.noLabel.layer.cornerRadius = 22.0f;
    view.noLabel.layer.masksToBounds = YES;
    
    view.yesLabel.layer.borderWidth = 1.0f;
    view.yesLabel.layer.borderColor = COLOR_WITH_16BAND_RGB(0x999999).CGColor;
    view.noLabel.layer.borderWidth = 1.0f;
    view.noLabel.layer.borderColor = COLOR_WITH_16BAND_RGB(0x999999).CGColor;
    

    
    return view;
}

- (void)showDialog:(UIView *)view cancelBlock:(DialogCancelBlock)cancelBlock actionBlock:(DialogActionBlock)actionBlock {
    self.cancelBlock = cancelBlock;
    self.actionBlock = actionBlock;
    
    
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(view);
        }];


    }
}

- (IBAction)cancelCancel:(id)sender {
    if( self.cancelBlock ) {
        self.cancelBlock();
    }
    [self removeFromSuperview];
}

- (IBAction)actionOK:(id)sender {
    if( self.actionBlock ) {
        self.actionBlock();
    }
    [self removeFromSuperview];

}

@end
