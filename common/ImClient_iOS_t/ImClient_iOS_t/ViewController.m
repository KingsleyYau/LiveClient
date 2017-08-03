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
    self.token = @"RBQP2A17";
    self.userId = @"17";
    self.roomid = @"208";
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
        [urls addObject:@"ws://192.168.88.17:3006"];
        //[urls addObject:@"ws://172.25.32.17:3006"];
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

- (IBAction)fansShutUp:(id)sender {
    if (nil != self.client) {
        [self.client fansShutUp:self.roomid userId:self.userId timeOut:10];
    }
}

- (IBAction)FansKickOff:(id)sender {
    if (nil != self.client) {
        [self.client fansKickOffRoom:self.roomid userId:self.userId];
    }
}

- (IBAction)sendRoomMsg:(id)sender {
    if (nil != self.client) {
        [self.client sendRoomMsg:self.token roomId:self.roomid nickName:@"alex" msg:@"123456"];
    }
}

- (IBAction)sendRoomFav:(id)sender {
    if (nil != self.client) {
        [self.client sendRoomFav:self.roomid token:self.token nickName:@"alex"];
    }
}

- (IBAction)sendRoomGift:(id)sender {
    if (nil != self.client) {
        [self.client sendRoomGift:self.roomid token:self.token nickName:@"alex" giftId:@"123456" giftName:@"testGift" giftNum:2 multi_click:YES multi_click_start:2 multi_click_end:4 multi_click_id:1];
    }
}

- (IBAction)sendRoomToast:(id)sender {
    if (nil != self.client) {
        [self.client sendRoomToast:self.roomid token:self.token nickName:@"alex" msg:@"852147"];
    }
}

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onLogin()");
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onLogout()");
}

- (void)onKickOff:(NSString* _Nonnull)reason
{
    NSLog(@"ViewController::onKickOff()");
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

- (void)onFansShutUp:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onFansShutUp()");
}

- (void)onFansKickOffRoom:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onFansKickOffRoom()");
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

- (void)onRecvShutUpNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName timeOut:(int)timeOut {
    NSLog(@"ViewController::onRecvShutUpNotice()");
}

- (void)onRecvKickOffRoomNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName {
    NSLog(@"ViewController::onRecvKickOffRoomNotice()");
}

- (void)onSendRoomMsg:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onSendRoomMsg()");
}

- (void)onRecvRoomMsg:(NSString* _Nonnull)roomId level:(int)level fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg {
    NSLog(@"ViewController::onRecvRoomMsg()");
}

- (void)onSendRoomFav:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onSendRoomFav()");
}

- (void)onRecvPushRoomFav:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId {
    NSLog(@"ViewController::onRecvPushRoomFav()");
}

- (void)onSendRoomGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg coins:(double)coins {
    NSLog(@"ViewController::onSendRoomGift()");
}

- (void)onRecvRoomGiftNotice:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id {
    NSLog(@"ViewController::onRecvRoomGiftNotice()");
}

- (void)onSendRoomToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg coins:(double)coins {
    NSLog(@"ViewController::onSendRoomToast()");
}

- (void)onRecvRoomToastNotice:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg {
    NSLog(@"ViewController::onRecvRoomToastNotice()");
}

@end
