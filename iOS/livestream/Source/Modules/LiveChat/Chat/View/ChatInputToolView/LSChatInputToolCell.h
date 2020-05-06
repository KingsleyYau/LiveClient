//
//  LSChatInputToolCell.h
//  livestream
//
//  Created by Calvin on 2020/3/26.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

 

@interface LSChatInputToolCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *iconBtn;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
+ (NSString *)cellIdentifier;
@end
 
