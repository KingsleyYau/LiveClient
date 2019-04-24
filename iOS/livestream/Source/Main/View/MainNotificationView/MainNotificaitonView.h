//
//  MainNotificaitonView.h
//  livestream
//
//  Created by Calvin on 2019/1/18.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

 

@interface MainNotificaitonView : UIView

@property (nonatomic, strong) NSArray * items;
- (void)reloadData;

- (void)deleteCollectionViewRow;
@end

 
