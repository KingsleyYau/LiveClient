//
//  CountryCodeViewController.h
//  livestream
//
//  Created by Calvin on 17/9/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Country.h"

@protocol CountryCodeViewControllerDelegate <NSObject>

- (void)countryCode:(Country *)item;

@end

@interface CountryCodeViewController : UIViewController

@property (nonatomic, weak) id<CountryCodeViewControllerDelegate> delegate;
@end
