//
//  DoorStreamViewController.m
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DoorStreamViewController.h"

#import "GPUImage.h"

#import "LiveStreamSession.h"
#import "LiveStreamPlayer.h"

#import "LSRequestManager.h"
#import "LSFileCacheManager.h"

#include <json/json/json.h>
#include <httpclient/HttpRequest.h>

class RequestGetRoomCallbackImp;

@interface DoorStreamViewController () <LiveStreamPlayerDelegate>
@property (assign) RequestGetRoomCallbackImp *requestGetRoomCallback;

@property (weak) IBOutlet GPUImageView *playerPreview;
@property (strong) LiveStreamPlayer *player;
@property (strong) NSString *playUrl;
@property (strong) NSArray *urlArray;
@property (strong) NSString *playStreamName;

@property (weak) IBOutlet UITextField *playUrlTextField;
@property (weak) IBOutlet UILabel *requestResultLabel;

@end

@implementation DoorStreamViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.isShowNavBar = NO;
}

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.requestGetRoomCallback = new RequestGetRoomCallbackImp(self);
    
    // 初始化播放
    self.player = [LiveStreamPlayer instance];
    self.player.playView = self.playerPreview;
    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatio;
    self.player.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self getRoom];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 停止流
    [self stop:nil];

    // 允许锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 播放控制
- (IBAction)play:(id)sender {
    [self.player playUrl:self.playUrl recordFilePath:@"" recordH264FilePath:@"" recordAACFilePath:@""];
}

- (IBAction)stop:(id)sender {
    [self.player stop];
}

- (IBAction)refresh:(id)sender {
    [self stop:nil];
    [self getRoom];
}

- (IBAction)record:(id)sender {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *recordFilePath = [NSString stringWithFormat:@"%@/%@-%@.flv", recordDir, self.playStreamName, dateString];
    
    [self stop:nil];
    [self.player playUrl:self.playUrl recordFilePath:recordFilePath recordH264FilePath:@"" recordAACFilePath:@""];
}

- (void)playerOnConnect:(LiveStreamPlayer * _Nonnull)player {
    NSLog(@"DoorStreamViewController::playerOnConnect( url : %@ )", player.url);
}

- (void)playerOnDisconnect:(LiveStreamPlayer * _Nonnull)player {
    NSLog(@"DoorStreamViewController::playerOnDisconnect( url : %@ )", player.url);
}

#pragma mark - 请求接口
- (void)getRoom {
    NSString *url = @"https://www.charmlive.com/manList/v1/getOnlineRoomList?is_ajax=1";
    NSString *param = [NSString stringWithFormat:@"{\"anchor_id\":\"%@\"}", self.item.userId];
    
    HttpEntiy mEntiy;
    mEntiy.AddHeader("Accept", "application/json");
    mEntiy.AddHeader("Content-type", "application/json");
    mEntiy.SetNoHeader();
    mEntiy.SetRawData([param UTF8String]);
    
    HttpRequest *request = new HttpRequest();
    request->SetCallback(self.requestGetRoomCallback);
    request->StartRequest([url UTF8String], mEntiy);
}

- (void)parsePlayUrl {
    NSString *playUrl = @"";
    if( self.urlArray.count > 0 ) {
        for(NSString *url in self.urlArray) {
            if( [url containsString:@"/play_flash/"] ) {
                NSArray *hostArray = [url componentsSeparatedByString:@":"];
                if( hostArray.count > 1 ) {
                    NSString *host = [NSString stringWithFormat:@"%@:%@", hostArray[0], hostArray[1]];
                    NSArray *nameArray = [url componentsSeparatedByString:@"/play_flash/"];
                    
                    if( nameArray.count > 0 ) {
                        NSString *name = [nameArray lastObject];
                        self.playStreamName = name;
                        playUrl = [NSString stringWithFormat:@"%@:4000/cdn_standard/%@", host, name];
                        break;
                    }
                }
            }
            
            if( [url containsString:@"/play_standard/"] ) {
                NSArray *hostArray = [url componentsSeparatedByString:@":"];
                if( hostArray.count > 1 ) {
                    NSString *host = [NSString stringWithFormat:@"%@:%@", hostArray[0], hostArray[1]];
                    NSArray *nameArray = [url componentsSeparatedByString:@"/play_standard/"];
                    
                    if( nameArray.count > 0 ) {
                        NSString *name = [nameArray lastObject];
                        self.playStreamName = name;
                        playUrl = [NSString stringWithFormat:@"%@:4000/cdn_standard/%@", host, name];
                        break;
                    }
                }
            }
            
        }
    }
    
    self.playUrlTextField.text = playUrl;
    self.playUrl = playUrl;
}

class RequestGetRoomCallbackImp : public IHttpRequestCallback {
public:
    RequestGetRoomCallbackImp(DoorStreamViewController *vc){
        mVC = vc;
    };
    ~RequestGetRoomCallbackImp(){};
    void OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size) {
        Json::Value root;
        Json::Reader reader;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mVC.requestResultLabel.text = [NSString stringWithUTF8String:buf];
        });
        
        if( reader.parse(buf, root, false) ) {
            Json::Value data = root["data"];
            if( data.isObject() ) {
                Json::Value roomList = data["roomlist"];
                if( roomList.isArray() && roomList.size() > 0 ) {
                    Json::Value room = roomList[(int)0];
                    if( room["roomid"].isInt() ) {
                        int roomId = room["roomid"].asInt();
                        Json::Value roomUrl = room["roomurl"];
                        if( roomUrl.isArray() ) {
                            NSMutableArray *mutArray = [NSMutableArray array];
                            for(int i = 0; i < roomUrl.size(); i++) {
                                string url = roomUrl[(int)i].asString();
                                NSString *urlString = [NSString stringWithUTF8String:url.c_str()];
                                [mutArray addObject:urlString];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                mVC.requestResultLabel.text = [NSString stringWithUTF8String:buf];
                                mVC.urlArray = [[NSArray alloc] initWithArray:mutArray copyItems:YES];
                                [mVC parsePlayUrl];
                                [mVC play:nil];
                            });
                        }
                    }
                }
            }
            
        } else {
            
        }
    };
    void OnReceiveBody(HttpRequest* request, const char* buf, int size) {
    };
private:
    __weak typeof(DoorStreamViewController) *mVC;
};

@end
