//
//  ViewController.m
//  ImClient_iOS_t
//
//  Created by  Samson on 27/05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#import "ViewController.h"
#import "ImClientOC.h"

@interface ViewController () <IMLiveRoomManagerDelegate>
@property (nonatomic, strong) ImClientOC* client;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* roomid;

- (IBAction)initAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)logoutAction:(id)sender;
- (IBAction)vRoomIn:(id)sender;
- (IBAction)vRoomOut:(id)sender;
- (IBAction)getRoomInfo:(id)sender;
- (IBAction)sendRoomMsg:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.token = @"O9MS5D5Q";
    self.userId = @"25";
    self.roomid = @"172";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createAction:(id)sender {
    if (nil == self.client) {
        self.client = [[ImClientOC alloc] init];
        [self.client addDelegate:self];
    }
}

- (IBAction)releaseAction:(id)sender {
    if (nil != self.client) {
        [self.client removeDelegate:self];
        self.client = nil;
    }
}

- (IBAction)initAction:(id)sender {
    if (nil != self.client) {
        NSMutableArray<NSString*>* urls = [NSMutableArray array];
//        [urls addObject:@"ws://192.168.88.17:3006"];
        [urls addObject:@"ws://172.25.32.17:3006"];
        [self.client initClient:urls];
    }
}

- (IBAction)loginAction:(id)sender {
    if (nil != self.client) {
        //[self.client login:@"17" token:@"L4T9W75Q"];
         [self.client login:@"25" token:self.token];
    }
}

- (IBAction)logoutAction:(id)sender {
    if (nil != self.client) {
        [self.client logout];
    }
}

- (IBAction)vRoomIn:(id)sender {
    if (nil != self.client) {
        [self.client fansRoomIn:self.token roomId:self.roomid];
    }
}

- (IBAction)vRoomOut:(id)sender {
    if (nil != self.client) {
        [self.client fansRoomout:self.token roomId:self.roomid];
    }
}

- (IBAction)getRoomInfo:(id)sender {
    if (nil != self.client) {
        [self.client getRoomInfo:self.token roomId:self.roomid];
    }
}

- (IBAction)sendRoomMsg:(id)sender {
    if (nil != self.client) {
        [self.client sendRoomMsg:self.token roomId:self.roomid nickName:@"alex" msg:@"123456"];
    }
}

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onLogin()");
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onLogout()");
}

- (void)onFansRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl country:(NSString* _Nonnull)country videoUrls:(NSArray<NSString*>* _Nonnull)videoUrls fansNum:(int)fansNum contribute:(int)contribute fansList:(NSArray<RoomTopFanItemObject*>* _Nonnull)fansList {
    NSLog(@"ViewController::onFansRoomIn()");
}

- (void)onFansRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onFansRoomOut()");
}

- (void)onGetRoomInfo:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg fansNum:(int)fansNum contribute:(int)contribute {
    NSLog(@"ViewController::onGetRoomInfo()");
}

- (void)onRecvRoomCloseFans:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName fansNum:(int)fansNum {
    NSLog(@"ViewController::onRecvRoomCloseFans()");
}

- (void)onRecvRoomCloseBroad:(NSString* _Nonnull)roomId fansNum:(int)fansNum income:(int)income newFans:(int)newFans shares:(int)shares duration:(int)duration {
    NSLog(@"ViewController::onRecvRoomCloseBroad()");
}

- (void)onRecvFansRoomIn:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl {
    NSLog(@"ViewController::onRecvFansRoomIn()");
}

- (void)onSendRoomMsg:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onSendRoomMsg()");
}

- (void)onRecvRoomMsg:(NSString* _Nonnull)roomId level:(int)level fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg {
    NSLog(@"ViewController::onRecvRoomMsg()");
}
@end
