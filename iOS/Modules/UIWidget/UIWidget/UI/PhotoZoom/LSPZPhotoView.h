//
//  PZPhotoView.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSPZPhotoViewDelegate;
@interface LSPZPhotoView : UIScrollView
@property (assign, nonatomic) IBOutlet id<LSPZPhotoViewDelegate> photoViewDelegate;
@property (nonatomic, assign) UIViewContentMode imageViewContentMode;

- (void)prepareForReuse;
- (void)setImage:(UIImage *)image;
- (void)updateZoomScale:(CGFloat)newScale;
- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center;
@end

@protocol LSPZPhotoViewDelegate <NSObject>
@optional
- (void)photoViewDidSingleTap:(LSPZPhotoView *)photoView;
- (void)photoViewDidDoubleTap:(LSPZPhotoView *)photoView;
- (void)photoViewDidTwoFingerTap:(LSPZPhotoView *)photoView;
- (void)photoViewDidDoubleTwoFingerTap:(LSPZPhotoView *)photoView;
@end
