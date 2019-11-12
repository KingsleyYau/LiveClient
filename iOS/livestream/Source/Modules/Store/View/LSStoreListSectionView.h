//
//  LSStoreListSectionView.h
//  livestream
//
//  Created by Calvin on 2019/10/9.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSStoreListSectionView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)updateContent:(NSString *)str isShowFreeCard:(BOOL)isShow;
@end

 
