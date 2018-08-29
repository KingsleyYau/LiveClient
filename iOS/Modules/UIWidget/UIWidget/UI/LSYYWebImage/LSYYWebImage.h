//
//  LSYYWebImage.h
//  LSYYWebImage <https://github.com/ibireme/LSYYWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

#if __has_include(<LSYYWebImage/LSYYWebImage.h>)
FOUNDATION_EXPORT double LSYYWebImageVersionNumber;
FOUNDATION_EXPORT const unsigned char LSYYWebImageVersionString[];
#import <LSYYWebImage/LSYYImageCache.h>
#import <LSYYWebImage/LSYYWebImageOperation.h>
#import <LSYYWebImage/LSYYWebImageManager.h>
#import <LSYYWebImage/UIImage+LSYYWebImage.h>
#import <LSYYWebImage/UIImageView+LSYYWebImage.h>
#import <LSYYWebImage/UIButton+LSYYWebImage.h>
#import <LSYYWebImage/CALayer+LSYYWebImage.h>
#else
#import "LSYYImageCache.h"
#import "LSYYWebImageOperation.h"
#import "LSYYWebImageManager.h"
#import "UIImage+LSYYWebImage.h"
#import "UIImageView+LSYYWebImage.h"
#import "UIButton+LSYYWebImage.h"
#import "CALayer+LSYYWebImage.h"
#endif

#if __has_include(<LSYYImage/LSYYImage.h>)
#import <LSYYImage/LSYYImage.h>
#elif __has_include(<LSYYWebImage/LSYYImage.h>)
#import <LSYYWebImage/LSYYImage.h>
#import <LSYYWebImage/LSYYFrameImage.h>
#import <LSYYWebImage/LSYYSpriteSheetImage.h>
#import <LSYYWebImage/LSYYImageCoder.h>
#import <LSYYWebImage/LSYYAnimatedImageView.h>
#else
#import "LSYYImage.h"
#import "LSYYFrameImage.h"
#import "LSYYSpriteSheetImage.h"
#import "LSYYImageCoder.h"
#import "LSYYAnimatedImageView.h"
#endif

#if __has_include(<LSYYCache/LSYYCache.h>)
#import <LSYYCache/LSYYCache.h>
#elif __has_include(<LSYYWebImage/LSYYCache.h>)
#import <LSYYWebImage/LSYYCache.h>
#import <LSYYWebImage/LSYYMemoryCache.h>
#import <LSYYWebImage/LSYYDiskCache.h>
#import <LSYYWebImage/LSYYKVStorage.h>
#else
#import "LSYYCache.h"
#import "LSYYMemoryCache.h"
#import "LSYYDiskCache.h"
#import "LSYYKVStorage.h"
#endif

