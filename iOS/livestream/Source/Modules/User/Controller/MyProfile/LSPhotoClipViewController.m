//
//  LSPhotoClipViewController.m
//  livestream
//
//  Created by test on 2018/1/15.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSPhotoClipViewController.h"
#import "LSClipShapeLayer.h"
#import "LSPanGestureRecognizer.h"

@interface LSPhotoClipViewController ()
@property(strong, nonatomic) UIImageView *bigImageView;
@property(strong, nonatomic) UIView *cropView;
@property (strong, nonatomic) UIView *loadActivityView;
/** 取消 */
@property (nonatomic, strong) UIButton* cancelBtn;
/** 确定 */
@property (nonatomic, strong) UIButton* chooseBtn;
/** 控制中心的view */
@property (nonatomic, strong) UIView* actionView;
/** 分割线*/
@property (nonatomic, strong) UIView* lineView;
// 图片 view 原始 frame
@property(assign, nonatomic) CGRect originalFrame;
// 裁剪区域属性
@property(assign, nonatomic) CGFloat cropAreaX;
@property(assign, nonatomic) CGFloat cropAreaY;
@property(assign, nonatomic) CGFloat cropAreaWidth;
@property(assign, nonatomic) CGFloat cropAreaHeight;
@property(nonatomic, assign) CGFloat clipHeight;
@property(nonatomic, assign) CGFloat clipWidth;
@end

@implementation LSPhotoClipViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
//    self.clipWidth = SCREEN_WIDTH - 30;
//    self.clipHeight = self.clipWidth * 10 / 8;
    self.clipWidth = SCREEN_WIDTH;
    self.clipHeight = SCREEN_WIDTH;
    self.cropAreaX = (SCREEN_WIDTH - self.clipWidth)/2;
    self.cropAreaY = (SCREEN_HEIGHT - self.clipHeight)/2;
    self.cropAreaWidth = self.clipWidth;
    self.cropAreaHeight = self.clipHeight;
    self.bigImageView.image = self.targetImage;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    
    [self.view addSubview:self.cropView];
    [self.view addSubview:self.bigImageView];
    [self.view addSubview:self.actionView];
    [self.actionView addSubview:self.cancelBtn];
    [self.actionView addSubview:self.chooseBtn];
    [self.actionView addSubview:self.lineView];
    [self setupLoadingActivityView];

    
    [self.actionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.offset(60);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.actionView);
        make.height.offset(0.5);
    }];
    
    [self.cropView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.actionView).offset(0);
    }];
    
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.actionView).offset(15);
        make.centerY.equalTo(self.actionView);
    }];
    
    [self.chooseBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.actionView).offset(-15);
        make.centerY.equalTo(self.actionView);
    }];
    
    CGFloat tempWidth = 0.0;
    CGFloat tempHeight = 0.0;
    
    if (self.targetImage.size.width / self.cropAreaWidth <= self.targetImage.size.height / self.cropAreaHeight) {
        tempWidth = self.cropAreaWidth;
        tempHeight = (tempWidth / self.targetImage.size.width) * self.targetImage.size.height;
    } else if (self.targetImage.size.width/self.cropAreaWidth > self.targetImage.size.height / self.cropAreaHeight) {
        tempHeight = self.cropAreaHeight;
        tempWidth = (tempHeight / self.targetImage.size.height) * self.targetImage.size.width;
    }
  
    [self.bigImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cropAreaX - (tempWidth - self.cropAreaWidth)/2);
        make.top.mas_equalTo(self.cropAreaY - (tempHeight - self.cropAreaHeight)/2);
        make.width.mas_equalTo(tempWidth);
        make.height.mas_equalTo( tempHeight);
    }];
    
    self.originalFrame = CGRectMake(self.cropAreaX - (tempWidth - self.cropAreaWidth)/2, self.cropAreaY - (tempHeight - self.cropAreaHeight)/2, tempWidth, tempHeight);
    [self addAllGesture];
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setUpCropLayer];
    [self.view bringSubviewToFront:self.actionView];
    [self.view bringSubviewToFront:self.chooseBtn];
    [self.view bringSubviewToFront:self.cancelBtn];
    [self.view bringSubviewToFront:self.loadActivityView];
}

-(void)addAllGesture {
    // 捏合手势
    UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPinGesture:)];
    [self.view addGestureRecognizer:pinGesture];
    
    // 拖动手势
    LSPanGestureRecognizer *panGesture = [[LSPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDynamicPanGesture:) inview:self.cropView];
    [self.cropView addGestureRecognizer:panGesture];
}

- (void)handleDynamicPanGesture:(LSPanGestureRecognizer *)panGesture {
    UIView * view = self.bigImageView;
    CGPoint translation = [panGesture translationInView:view.superview];
    // 滑动过程中进行位置改变
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
        [panGesture setTranslation:CGPointZero inView:view.superview];
    }
    // 滑动结束后进行位置修正
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGRect currentFrame = view.frame;
        if (currentFrame.origin.x >= self.cropAreaX) {
            currentFrame.origin.x = self.cropAreaX;
        }
        if (currentFrame.origin.y >= self.cropAreaY) {
            currentFrame.origin.y = self.cropAreaY;
        }
        if (currentFrame.size.width + currentFrame.origin.x < self.cropAreaX + self.cropAreaWidth) {
            CGFloat movedLeftX = fabs(currentFrame.size.width + currentFrame.origin.x - (self.cropAreaX + self.cropAreaWidth));
            currentFrame.origin.x += movedLeftX;
        }
        if (currentFrame.size.height + currentFrame.origin.y < self.cropAreaY + self.cropAreaHeight) {
            CGFloat moveUpY = fabs(currentFrame.size.height + currentFrame.origin.y - (self.cropAreaY + self.cropAreaHeight));
            currentFrame.origin.y += moveUpY;
        }
        [UIView animateWithDuration:0.3 animations:^{
            [view setFrame:currentFrame];
        }];
    }
    
}

-(void)handleCenterPinGesture:(UIPinchGestureRecognizer *)pinGesture {
    CGFloat scaleRation = 3;
    UIView * view = self.bigImageView;
    
    // 缩放开始与缩放中
    if (pinGesture.state == UIGestureRecognizerStateBegan || pinGesture.state == UIGestureRecognizerStateChanged) {
        // 移动缩放中心到手指中心
        CGPoint pinchCenter = [pinGesture locationInView:view.superview];
        CGFloat distanceX = view.frame.origin.x - pinchCenter.x;
        CGFloat distanceY = view.frame.origin.y - pinchCenter.y;
        CGFloat scaledDistanceX = distanceX * pinGesture.scale;
        CGFloat scaledDistanceY = distanceY * pinGesture.scale;
        CGRect newFrame = CGRectMake(view.frame.origin.x + scaledDistanceX - distanceX, view.frame.origin.y + scaledDistanceY - distanceY, view.frame.size.width * pinGesture.scale, view.frame.size.height * pinGesture.scale);
        view.frame = newFrame;
        pinGesture.scale = 1;
    }
    
    // 缩放结束
    if (pinGesture.state == UIGestureRecognizerStateEnded) {
        CGFloat ration =  view.frame.size.width / self.originalFrame.size.width;
        // 缩放过大
        if (ration > 5) {
            CGRect newFrame = CGRectMake(0, 0, self.originalFrame.size.width * scaleRation, self.originalFrame.size.height * scaleRation);
            view.frame = newFrame;
        }
        // 缩放过小
        if (ration < 0.25) {
            view.frame = self.originalFrame;
        }

        // 对图片进行位置修正
        CGRect resetPosition = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        
        if (resetPosition.origin.x >= self.cropAreaX) {
            resetPosition.origin.x = self.cropAreaX;
        }
        if (resetPosition.origin.y >= self.cropAreaY) {
            resetPosition.origin.y = self.cropAreaY;
        }
        if (resetPosition.size.width + resetPosition.origin.x < self.cropAreaX + self.cropAreaWidth) {
            CGFloat movedLeftX = fabs(resetPosition.size.width + resetPosition.origin.x - (self.cropAreaX + self.cropAreaWidth));
            resetPosition.origin.x += movedLeftX;
        }
        if (resetPosition.size.height + resetPosition.origin.y < self.cropAreaY + self.cropAreaHeight) {
            CGFloat moveUpY = fabs(resetPosition.size.height + resetPosition.origin.y - (self.cropAreaY + self.cropAreaHeight));
            resetPosition.origin.y += moveUpY;
        }
        view.frame = resetPosition;
        // 对图片缩放进行比例修正，防止过小
        if (self.cropAreaX < self.bigImageView.frame.origin.x
            || ((self.cropAreaX + self.cropAreaWidth) > self.bigImageView.frame.origin.x + self.bigImageView.frame.size.width)
            || self.cropAreaY < self.bigImageView.frame.origin.y
            || ((self.cropAreaY + self.cropAreaHeight) > self.bigImageView.frame.origin.y + self.bigImageView.frame.size.height)) {
            view.frame = self.originalFrame;
        }
    }
}

// 裁剪图片并调用
- (UIImage *)cropImage {
    CGFloat imageScale = MIN(self.bigImageView.frame.size.width/self.targetImage.size.width, self.bigImageView.frame.size.height/self.targetImage.size.height);
    CGFloat cropX = (self.cropAreaX - self.bigImageView.frame.origin.x)/imageScale;
    CGFloat cropY = (self.cropAreaY - self.bigImageView.frame.origin.y)/imageScale;
    CGFloat cropWidth = self.cropAreaWidth/imageScale;
    CGFloat cropHeight = self.cropAreaHeight/imageScale;
    
    UIImage *fixImage =  [self.targetImage fixOrientation];
    CGRect cropRect = CGRectMake(cropX, cropY, cropWidth, cropHeight);
    CGImageRef sourceImageRef = [fixImage CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

- (void)setUpCropLayer {
    self.cropView.layer.sublayers = nil;
    LSClipShapeLayer * layer = [[LSClipShapeLayer alloc] init];
    CGRect cropframe = CGRectMake(self.cropAreaX, self.cropAreaY, self.cropAreaWidth, self.cropAreaHeight);
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.cropView.frame cornerRadius:0];
    UIBezierPath * cropPath = [UIBezierPath bezierPathWithRect:cropframe];
    [path appendPath:cropPath];
    layer.path = path.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [[UIColor clearColor] CGColor];
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.frame = self.cropView.bounds;
    [layer setCropAreaLeft:self.cropAreaX CropAreaTop:self.cropAreaY CropAreaRight:self.cropAreaX + self.cropAreaWidth CropAreaBottom:self.cropAreaY + self.cropAreaHeight];
    [self.cropView.layer addSublayer:layer];
    [self.view bringSubviewToFront:self.cropView];
}


#pragma mark - lazy
- (UIImageView *)bigImageView {
    if (!_bigImageView) {
        _bigImageView = [[UIImageView alloc] init];
        _bigImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bigImageView;
}

- (UIView *)cropView {
    if (!_cropView) {
        _cropView = [[UIView alloc] init];
    }
    return _cropView;
}


- (UIView *)actionView {
    if (!_actionView) {
        _actionView = [[UIView alloc] init];
        _actionView.backgroundColor = [UIColor blackColor];
    }
    return _actionView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = COLOR_WITH_16BAND_RGB(0xAAAAAA);
    }
    return _lineView;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnDidClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)chooseBtn {
    if (!_chooseBtn) {
        _chooseBtn = [[UIButton alloc] init];
        [_chooseBtn setTitle:@"Save" forState:UIControlStateNormal];
        [_chooseBtn addTarget:self action:@selector(chooseBtnDidClickChoose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chooseBtn;
}

#pragma mark - action
- (void)cancelBtnDidClickCancel:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(lsPhotoClipViewControllerDidcancelChoosePhoto:)]) {
        [self.delegate lsPhotoClipViewControllerDidcancelChoosePhoto:self];
    }
}


- (void)chooseBtnDidClickChoose:(UIButton *)sender {
    UIImage *newImage = [self cropImage];
    [self showLoadingView];
    if ([self.delegate respondsToSelector:@selector(lsPhotoClipViewController:didChoosePhoto:withLoadingView:)]) {
        [self.delegate lsPhotoClipViewController:self didChoosePhoto:newImage withLoadingView:self.loadActivityView];
    }
    
}
- (void)setupLoadingActivityView {
    UIView *loadActivityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    
    loadActivityView.layer.cornerRadius = 5.0f;
    loadActivityView.layer.masksToBounds = YES;
    loadActivityView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    UIActivityIndicatorView *loadingActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [loadActivityView addSubview:loadingActivity];
    
    
    self.loadActivityView = loadActivityView;
    
    
    loadingActivity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [loadingActivity startAnimating];
    
    [self.view addSubview:self.loadActivityView];

    [self.loadActivityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(@80);
    }];
    self.loadActivityView.hidden = YES;
}

- (void)showLoadingView {
    self.loadActivityView.hidden = NO;
    self.view.userInteractionEnabled = NO;
}

@end
