//
//  CustomUIView.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//
#import "CustomUIView.h"

@implementation UIView (Custom)
- (void)removeAllSubviews{
    NSArray *subViews = self.subviews;
    for(UIView *view in subViews){
        [view removeFromSuperview];
    }
}
@end
