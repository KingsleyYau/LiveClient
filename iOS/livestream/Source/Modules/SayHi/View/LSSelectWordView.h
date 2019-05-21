//
//  LSSelectWordView.h
//  livestream
//
//  Created by Randy_Fan on 2019/4/26.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSayHiManager.h"

@interface LSSayHiTextListItem : NSObject
@property (nonatomic, strong) LSSayHiTextItemObject *textItem;
@property (nonatomic, assign) CGFloat cellHeight;
@end

@class LSSelectWordView;
@protocol LSSelectWordViewDelegate <NSObject>
- (void)didSelectRowAtIndexPath:(LSSayHiTextListItem *)item;
@end

@interface LSSelectWordView : UIView

@property (weak, nonatomic) id<LSSelectWordViewDelegate> delegate;

- (void)loadWordTableView:(NSMutableArray <LSSayHiTextListItem *>*)texts selectIndex:(NSInteger)selectIndex;

@end


