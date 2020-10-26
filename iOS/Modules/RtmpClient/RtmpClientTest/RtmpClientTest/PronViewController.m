//
//  PronViewController.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/23.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "PronViewController.h"
#import "AppDelegate.h"
@interface PronViewController ()
@property (weak) IBOutlet StreamWebView *webView;
@property (weak) IBOutlet UIButton *downloadBtn;

@property (strong) NSMutableDictionary *urlDict;
@property (strong) NSMutableDictionary *urlCheckDict;

@property (weak) IBOutlet UITextField *textFieldAddress;
@property (strong) NSURLSession *session;
@end

@implementation PronViewController
- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 界面处理
    self.title = @"Browser";
    self.urlDict = [NSMutableDictionary dictionary];
    self.urlCheckDict = [NSMutableDictionary dictionary];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<Back" style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];

    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.hidden = YES;
    self.downloadBtn.enabled = NO;

    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    NSString *urlString = @"";
    self.textFieldAddress.text = urlString;
    //    [self goAction:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)backAction:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)goAction:(UIButton *)sender {
    self.urlDict = [NSMutableDictionary dictionary];
    self.urlCheckDict = [NSMutableDictionary dictionary];
    self.downloadBtn.enabled = NO;

    NSString *urlString = self.textFieldAddress.text;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.webView loadRequest:request];
}

- (IBAction)checkDownloadURL {
    [self.webView evaluateJavaScript:@"quality_480p"
                   completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                       self.urlCheckDict[@"480P"] = @(1);
                       if (!error) {
                           NSLog(@"PronViewController::downloadAction( [480P] ), %@", response);
                           self.urlDict[@"480P"] = response;
                       }
                       [self check];
                   }];
    [self.webView evaluateJavaScript:@"quality_720p"
                   completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                       self.urlCheckDict[@"720P"] = @(1);
                       if (!error) {
                           NSLog(@"PronViewController::downloadAction( [720P] ), %@", response);
                           self.urlDict[@"720P"] = response;
                       }
                       [self check];
                   }];
    [self.webView evaluateJavaScript:@"quality_1080p"
                   completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                       self.urlCheckDict[@"1080P"] = @(1);
                       if (!error) {
                           NSLog(@"PronViewController::downloadAction( [1080P] ), %@", response);
                           self.urlDict[@"1080P"] = response;
                       }
                       [self check];
                   }];
}

- (void)check {
    if (self.urlCheckDict.count == 3) {
        self.downloadBtn.enabled = YES;
    }
}

- (IBAction)downloadAction:(UIButton *)sender {
    NSString *urlString = self.urlDict[@"1080P"];
    if (urlString.length == 0) {
        urlString = self.urlDict[@"720P"];
    }
    if (urlString.length == 0) {
        urlString = self.urlDict[@"480P"];
    }

    NSLog(@"PronViewController::download(), %@", urlString);
    if (urlString.length >= 0) {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:req];
        [task resume];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSString *unit = @"B";
    NSInteger size = totalBytesExpectedToWrite;
    if (size / 1024 > 1) {
        size /= 1024;
        unit = @"K";

        if (size / 1024 > 1) {
            size /= 1024;
            unit = @"M";
        }

        if (size / 1024 > 1) {
            size /= 1024;
            unit = @"G";
        }
    }

    float percent = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@"PronViewController::didWriteData(), (%ld%@)%.0f%%", size, unit, percent * 100);
    self.title = [NSString stringWithFormat:@"(%ld%@)%.0f%%", size, unit, percent * 100];
    
    if ([self.delegate respondsToSelector:@selector(downloadTaskPercent:)]) {
        [self.delegate downloadTaskPercent:self.title];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"PronViewController::didResumeAtOffset(), fileOffset: %lld, expectedTotalBytes: %lld", fileOffset, expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *ouputDir = [NSString stringWithFormat:@"%@/download", cacheDir];
    NSString *ouputFile = [NSString stringWithFormat:@"%@/%@", ouputDir, downloadTask.response.suggestedFilename];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    [fm createDirectoryAtPath:ouputDir withIntermediateDirectories:YES attributes:nil error:&error];
    [fm moveItemAtURL:location toURL:[NSURL fileURLWithPath:ouputFile] error:&error];
    NSLog(@"PronViewController::didFinishDownloadingToURL(), %@", downloadTask.response.suggestedFilename);
    self.title = self.webView.title;
    
    if ([self.delegate respondsToSelector:@selector(downloadTaskPercent:)]) {
        [self.delegate downloadTaskPercent:@""];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"PronViewController::didCompleteWithError(), %@", error);
    self.title = self.webView.title;
    
    if ([self.delegate respondsToSelector:@selector(downloadTaskPercent:)]) {
        [self.delegate downloadTaskPercent:@""];
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    NSLog(@"PronViewController::didBecomeInvalidWithError(), %@", error);
    self.title = self.webView.title;
    
    if ([self.delegate respondsToSelector:@selector(downloadTaskPercent:)]) {
        [self.delegate downloadTaskPercent:@""];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"PronViewController::decidePolicyForNavigationAction()");
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"PronViewController::didStartProvisionalNavigation()");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"PronViewController::decidePolicyForNavigationResponse()");
    decisionHandler(WKNavigationResponsePolicyAllow);
    [self checkDownloadURL];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"PronViewController::didFailProvisionalNavigation(), error: %@", error);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"PronViewController::didCommitNavigation()");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"PronViewController::didFinishNavigation()");
    [self checkDownloadURL];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"PronViewController::didFailNavigation(), error:%@", error);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"PronViewController:webViewWebContentProcessDidTerminate()");
}

@end
