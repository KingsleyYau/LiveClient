//
//  OpenCameraTipDialog.m
//  livestream
//
//  Created by Calvin on 2019/6/10.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "OpenCameraTipDialog.h"
#import "LSShadowView.h"
#import "BEMCheckBox.h"
#import "LSImageViewLoader.h"
#import "LSLoginManager.h"
@interface OpenCameraTipDialog ()
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *ladyHeadImage;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *meHeadImage;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) IBOutlet UIButton *noBtn;
@property (nonatomic, strong) LSImageViewLoader * ladyImageLoader;
@property (nonatomic, strong) LSImageViewLoader * meImageLoader;
@property (strong) void(^cancelBlock)();
@property (strong) void(^actionBlock)();
@end

@implementation OpenCameraTipDialog


+ (OpenCameraTipDialog *)dialogTip {
    
    static OpenCameraTipDialog *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
        view = [nibs objectAtIndex:0];
        view.layer.cornerRadius = 5.0f;
        view.layer.masksToBounds = YES;
        
        view.checkBox.onAnimationType = BEMAnimationTypeBounce;
        view.checkBox.offAnimationType = BEMAnimationTypeBounce;
        view.checkBox.boxType = BEMBoxTypeSquare;
        view.checkBox.tintColor = [UIColor lightGrayColor];
        view.checkBox.onTintColor = Color(29, 239, 232, 1.0);//[UIColor greenColor];
        view.checkBox.onFillColor = Color(29, 239, 232, 1.0);//[UIColor greenColor];
        view.checkBox.onCheckColor = [UIColor whiteColor];
        view.checkBox.animationDuration = 0.3;
        
        view.ladyHeadImage.layer.cornerRadius = view.ladyHeadImage.tx_height/2;
        view.ladyHeadImage.layer.masksToBounds = YES;
        
        view.meHeadImage.layer.cornerRadius = view.meHeadImage.tx_height/2;
        view.meHeadImage.layer.masksToBounds = YES;
        
        view.noBtn.layer.borderWidth = 0.5f;
        view.noBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        view.noBtn.layer.cornerRadius = 5.0f;
        view.noBtn.layer.masksToBounds = YES;
        
        view.yesBtn.layer.cornerRadius = 5.0f;
        view.yesBtn.layer.masksToBounds = YES;
        
        LSShadowView * yesView = [[LSShadowView alloc]init];
        [yesView showShadowAddView:view.yesBtn];
        
        LSShadowView * noView = [[LSShadowView alloc]init];
        [noView showShadowAddView:view.noBtn];
        
        view.isShow = NO;
    });
    return view;
}

- (void)showDialog:(UIView *)view andLadyPhoto:(NSString *)ladyPhoto cancelBlock:(void(^)())cancelBlock actionBlock:(void(^)())actionBlock {

    self.cancelBlock = cancelBlock;
    self.actionBlock = actionBlock;
    
    self.meImageLoader = [LSImageViewLoader loader];
    [self.meImageLoader loadImageFromCache:self.meHeadImage options:0 imageUrl:[LSLoginManager manager].loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"] finishHandler:^(UIImage *image) {
    }];
    
    
    self.ladyImageLoader = [LSImageViewLoader loader];
    [self.ladyImageLoader loadImageFromCache:self.ladyHeadImage options:0 imageUrl:ladyPhoto placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
        
    }];
    
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    self.frame = CGRectMake(SCREEN_WIDTH/2 - self.tx_width/2, SCREEN_HEIGHT/2 - self.tx_height/2 - 44, self.tx_width, self.tx_height);
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
