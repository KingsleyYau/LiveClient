//
//  LSSendSayHiViewController.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSendSayHiViewController.h"
#import "LSSayHiDialogViewController.h"

#import "LSShadowView.h"
#import "IntroduceView.h"

#import "LSSayHiIsCanSendRequest.h"
#import "LSSayHiSendSayHiRequest.h"
#import "LSSessionRequestManager.h"

#import "LSImageViewLoader.h"
#import "LSLoginManager.h"
#import "LSSayHiManager.h"


@interface LSSendSayHiViewController ()<WKUIDelegate, WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *themeImageView;
@property (weak, nonatomic) IBOutlet IntroduceView *webView;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (weak, nonatomic) IBOutlet UIImageView *freeIcon;

@property (strong, nonatomic) LSSessionRequestManager *sessionManager;

@property (strong, nonatomic) LSImageViewLoader *imageLoader;

@property (strong, nonatomic) LSSayHiManager *sayHiManager;

@end

@implementation LSSendSayHiViewController

- (void)dealloc {
    NSLog(@"LSSendSayHiViewController::dealloc()");
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.imageLoader = [LSImageViewLoader loader];
    
    self.sayHiManager = [LSSayHiManager manager];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.submitBtn.layer.cornerRadius = self.submitBtn.frame.size.height / 2;
    self.submitBtn.layer.masksToBounds = YES;
    LSShadowView *shadowView = [[LSShadowView alloc] init];
    [shadowView showShadowAddView:self.submitBtn];
    
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 界面展示
    if (self.sayHiManager.item) {
        [self.imageLoader loadImageWithImageView:self.themeImageView options:0 imageUrl:self.sayHiManager.item.bigImage placeholderImage:nil finishHandler:^(UIImage *image) {
            
        }];
        [self loadMailContentWebView:self.sayHiManager.item.text toName:self.anchorName from:[LSLoginManager manager].loginItem.nickName];
    } else {
        WeakObject(self, weakSelf);
        [self.sayHiManager getSayHiConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResourceConfigItemObject *item) {
            if (success) {
                LSSayHiThemeItemObject *thmemObj = item.themeList.firstObject;
                LSSayHiTextItemObject *textObj = item.textList.firstObject;
                [weakSelf.sayHiManager setLastSayHiConfigItem:thmemObj.themeId bigImg:thmemObj.bigImg textId:textObj.textId text:textObj.text];
                [weakSelf.imageLoader loadImageWithImageView:weakSelf.themeImageView options:0 imageUrl:weakSelf.sayHiManager.item.bigImage placeholderImage:nil finishHandler:^(UIImage *image) {
                    
                }];
                [weakSelf loadMailContentWebView:weakSelf.sayHiManager.item.text toName:weakSelf.anchorName from:[LSLoginManager manager].loginItem.nickName];
            }
        }];
    }
}

- (void)loadMailContentWebView:(NSString *)contentStr toName:(NSString *)toName from:(NSString *)from {
    NSRange startRange;     // 截取初始位置
    NSRange endRange;       // 截取结束位置
    NSRange range;          // 截取部分的位置
    NSString *result;       // 截取部分的内容
    NSString *tempContent;  // 替换后HTML内容
    
    NSString *path = [[LiveBundle mainBundle] pathForResource:@"SayHi" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // 替换toName
    startRange = [html rangeOfString:@"<font>To</font> "];
    endRange = [html rangeOfString:@"</div>"];
    range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    result = [html substringWithRange:range];
    tempContent = [html stringByReplacingOccurrencesOfString:result withString:toName];
    // 替换内容
    startRange = [tempContent rangeOfString:@"<div class=\"text\">"];
    endRange = [tempContent rangeOfString:@"</div>"];
    range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    result = [tempContent substringWithRange:range];
    tempContent = [tempContent stringByReplacingOccurrencesOfString:result withString:contentStr];
    // 替换fromName
    startRange = [tempContent rangeOfString:@"<font>From</font> "];
    endRange = [tempContent rangeOfString:@"</div>"];
    range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    result = [tempContent substringWithRange:range];
    tempContent = [tempContent stringByReplacingOccurrencesOfString:result withString:contentStr];
    
    NSURL *url = [[LiveBundle mainBundle] URLForResource:@"SayHi.html" withExtension:nil];
    [self.webView loadHTMLString:tempContent baseURL:url];
}

#pragma mark - HTTP请求
- (void)checkCanSayHi:(NSString *)anchorId {
    WeakObject(self, weakSelf);
    LSSayHiIsCanSendRequest *request = [[LSSayHiIsCanSendRequest alloc] init];
    request.anchorId = anchorId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, BOOL isCanSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSendSayHiViewController::LSSayHiIsCanSendRequest([检测对该主播是否可发送sayhi] success : %@, errnum : %d, errmsg : %@, isCanSend : %d )", BOOL2SUCCESS(success), errnum, errmsg, isCanSend);
            if (success) {
                if (isCanSend) {
                    [weakSelf sendSayHiRequest:anchorId];
                } else {
                    
                }
            } else {
                
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)sendSayHiRequest:(NSString *)anchorId {
//    WeakObject(self, weakSelf);
    LSSayHiSendSayHiRequest *request = [[LSSayHiSendSayHiRequest alloc] init];
    request.anchorId = anchorId;
    request.themeId = self.sayHiManager.item.themeId;
    request.textId = self.sayHiManager.item.textId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *sayHiId, NSString *loiId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSendSayHiViewController::sendSayHiRequest([发送SayHi] success : %@, errnum : %d, errmsg : %@, sayHiId : %@, loiId : %@)",BOOL2SUCCESS(success),errnum,errmsg,sayHiId,loiId);
            if (success) {
                
            } else {
                switch (errnum) {
                    case HTTP_LCC_ERR_SAYHI_ANCHOR_ALREADY_SEND_LOI:{
                        // 发过意向信
                    }break;
                    
                    case HTTP_LCC_ERR_SAYHI_MAN_ALREADY_SEND_SAYHI:{
                        // 发过SayHi
                    }break;
                        
                    case HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_REPLY:{
                        // 总量限制-有主播回复
                    }break;
                        
                    case HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_UNREPLY:{
                        // 总量限制-无主播回复
                    }break;
                        
                    default:{
                    }break;
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (IBAction)editAction:(id)sender {
    
}

- (IBAction)sumbitAction:(id)sender {
    
}


@end
