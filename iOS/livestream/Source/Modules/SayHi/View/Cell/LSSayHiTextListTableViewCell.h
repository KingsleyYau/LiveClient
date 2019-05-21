//
//  LSSayHiTextListTableViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/4/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSSayHiTextListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (assign, nonatomic) BOOL isSelect;

+ (NSString *)cellIdentifier;

+ (id)getUITableViewCell:(UITableView *)tableView;

- (void)setupTextContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
