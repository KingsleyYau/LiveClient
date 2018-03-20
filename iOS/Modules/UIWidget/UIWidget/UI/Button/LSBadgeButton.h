//
//  LSBadgeButton.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSBadgeButton : UIButton {

}
@property (nonatomic, copy) NSString *badgeValue;
@property (nonatomic, strong) UIImage* imageBadge;
@property (nonatomic, copy) NSString * unreadCount;
@property (nonatomic, copy) NSString* contentTitle;
@end
