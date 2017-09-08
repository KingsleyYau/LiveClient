//
//  SelectCountryController.h
//  livestream
//
//  Created by randy on 17/5/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectCountryController;
@class Country;

@protocol SelectCountryControllerDelegate <NSObject>
@optional

- (void)sendCounty:(Country *)items;

@end

@interface SelectCountryController : KKViewController

@property (nonatomic, strong) id<SelectCountryControllerDelegate>delegate;

@end
