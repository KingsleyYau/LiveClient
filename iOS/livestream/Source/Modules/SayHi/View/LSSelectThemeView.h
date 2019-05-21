//
//  LSSelectThemeView.h
//  livestream
//
//  Created by Randy_Fan on 2019/4/26.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSayHiManager.h"

@class LSSelectThemeView;
@protocol LSSelectThemeViewDelegate <NSObject>
- (void)didSelectItemAtIndexPath:(LSSayHiThemeItemObject *)item;
@end

@interface LSSelectThemeView : UIView
@property (weak, nonatomic) id<LSSelectThemeViewDelegate> delegate;

- (void)loadThemeCollection:(NSMutableArray <LSSayHiThemeItemObject *>*)themes selectIndex:(NSInteger)selectIndex;

@end


