//
//  WebViewController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>{
    NSString *_webPath;
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic, retain) NSString  *webPath;
@end
