//
//  RoomStyleItem.h
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomStyleItem : NSObject
/**聊天列表本人名字颜色*/
@property (nonatomic, strong) UIColor *myNameColor;

/**聊天列表用户名字颜色*/
@property (nonatomic, strong) UIColor *userNameColor;

/**聊天列表主播名字颜色*/
@property (nonatomic, strong) UIColor *liverNameColor;

/**聊天列表用户名字背景颜色*/
@property (nonatomic, strong) UIColor *userNameBackColor;

/**聊天列表主播名字背景颜色*/
@property (nonatomic, strong) UIColor *liverNameBackColor;

/**聊天列表主播标签图片*/
@property (nonatomic, strong) UIImage *liverTypeImage;

/**聊天列表接收文本颜色*/
@property (nonatomic, strong) UIColor *chatStrColor;
/**聊天列表文本底部背景*/
@property (nonatomic, strong) UIColor *chatBackgroundViewColor;

/**聊天列表发送礼物文本颜色*/
@property (nonatomic, strong) UIColor *sendStrColor;
/**送礼文本底部背景*/
@property (nonatomic, strong) UIColor *sendBackgroundViewColor;

/**试聊券文本颜色*/
@property (nonatomic, strong) UIColor *firstFreeStrColor;
/**试聊券文本底部背景*/
@property (nonatomic, strong) UIColor *firstFreeBackgroundViewColor;

/**聊天列表关注提示颜色*/
@property (nonatomic, strong) UIColor *followStrColor;
/**公告提示颜色*/
@property (nonatomic, strong) UIColor *announceStrColor;
/**公告提示文本底部背景*/
@property (nonatomic, strong) UIColor *announceBackgroundViewColor;

/**警告提示颜色*/
@property (nonatomic, strong) UIColor *warningStrColor;
/**警告提示文本底部背景*/
@property (nonatomic, strong) UIColor *warningBackgroundViewColor;

/**座驾入场提示颜色*/
@property (nonatomic, strong) UIColor *riderStrColor;
/**座驾入场文本底部背景*/
@property (nonatomic, strong) UIColor *riderBackgroundViewColor;

/**座驾背景颜色*/
@property (nonatomic, strong) UIColor *riderBgColor;

/**座驾文本颜色*/
@property (nonatomic, strong) UIColor *driverStrColor;

/**连击礼物背景*/
@property (nonatomic, strong) UIImage *comboViewBgImage;

/**弹幕背景颜色*/
@property (nonatomic, strong) UIColor *barrageBgColor;

/**购票标志*/
@property (nonatomic, strong) UIImage * buyTicketImage;
@end
