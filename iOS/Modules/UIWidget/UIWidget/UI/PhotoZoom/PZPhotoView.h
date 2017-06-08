//
//  PZPhotoView.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PZPhotoViewDelegate;

@interface PZPhotoView : UIScrollView

@property (assign, nonatomic) IBOutlet id<PZPhotoViewDelegate> photoViewDelegate;

/** 展示模式 */
@property (nonatomic,assign) UIViewContentMode imageViewContentMode;

- (void)prepareForReuse;
- (void)setImage:(UIImage *)image;

- (void)updateZoomScale:(CGFloat)newScale;
- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center;


@end

@protocol PZPhotoViewDelegate <NSObject>

@optional

- (void)photoViewDidSingleTap:(PZPhotoView *)photoView;
- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView;
- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView;
- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView;

@end
