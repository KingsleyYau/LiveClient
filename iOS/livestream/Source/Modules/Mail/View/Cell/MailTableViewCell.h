//
//  MailTableViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/11/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSHttpLetterListItemObject.h"

typedef enum {
    MAIL_NONE = 0,
    MAIL_GREETING,
    MAIL_INBOX
}MailType;

@interface MailTableViewCell : UITableViewCell

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView *)tableView;
- (void)updataMailCell:(LSHttpLetterListItemObject *)obj type:(MailType)type;
- (void)updataOutBoxMailCell:(LSHttpLetterListItemObject *)obj;
@end
