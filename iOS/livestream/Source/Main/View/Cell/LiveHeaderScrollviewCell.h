//
//  LiveHeaderScrollviewCell.h
//  ScrollviewDemo
//
//  Created by zzq on 2018/2/8.
//  Copyright © 2018年 zzq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveHeaderScrollviewCell : UICollectionViewCell
/**标题**/
@property (weak, nonatomic) IBOutlet UILabel *mainLB;
/**底部划线**/
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
/**未读红点**/
@property (weak, nonatomic) IBOutlet UILabel *redLabel;


+ (NSString *)cellIdentifier;
@end
