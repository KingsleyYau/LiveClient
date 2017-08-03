//
//  MsgTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LevelView.h"
#import "MsgItem.h"

@interface MsgTableViewCell : UITableViewCell

@property (nonatomic, strong) YYLabel *messageLabel;

@property (nonatomic, strong) LevelView *lvView;

@property (nonatomic, assign) CGFloat messageLabelWidth;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString;
+ (NSString *)textPreDetail;

- (void)updataChatMessage:(MsgItem *)item;

@end
