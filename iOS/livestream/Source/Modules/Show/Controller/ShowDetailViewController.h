//
//  ShowDetailViewController.h
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSProgramItemObject.h"
#import "LSWKWebViewController.h"
@interface ShowDetailViewController : LSWKWebViewController

@property (nonatomic, strong) LSProgramItemObject * item;
@end
