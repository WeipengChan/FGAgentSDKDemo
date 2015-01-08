//
//  DownloadViewController.m
//  FlowGateApp1
//
//  Created by mairuifeng on 14-10-30.
//  Copyright (c) 2014年 21cn. All rights reserved.
//

#import "DownloadViewController.h"
#import "FGAgent.h"
#import "AppDelegate.h"
#import "MyUrlProtocol.h"
#define _3M_FILE @"http://img002.21cnimg.com/photos/album/20141031/s660x308/9F6D747EF8CCDD72F82A53C9A249E4F3.jpg"

#define _50M_FILE @"http://w.x.baidu.com/alading/anquan_soft_down_normal/12350"
#define _100M_FILE @"http://w.x.baidu.com/alading/anquan_soft_down_normal/22772"
//#define IMG_FILE @"http://p1.pichost.me/i/40/1639665.png"
#define IMG_FILE @"http://img002.21cnimg.com/photos/album/20141031/s660x308/9F6D747EF8CCDD72F82A53C9A249E4F3.jpg"
@interface DownloadViewController ()
@property(nonatomic,weak) IBOutlet UITextField *url;
@property(nonatomic,weak) IBOutlet UILabel *progress;
@property(nonatomic,weak) IBOutlet UILabel *status;
@property (strong, atomic) NSURLSessionDownloadTask *task;
@property (strong, atomic) NSData *partialData;
@property(nonatomic,strong)NSURLSession *session;

@property(nonatomic,strong)NSString *defaultUA;

@property(nonatomic,assign)NSInteger currStatus;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    //[self makeupSession];
    [self setImageUrl:nil];
    
    self.defaultUA = [self getDefaultUserAgent];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self makeupSession];
    [NSURLProtocol registerClass:[MyUrlProtocol class]];
    
}

-(void)test
{
    [NSURLSessionConfiguration backgroundSessionConfiguration:@"abc.com"];
}

-(void)makeupSession
{
    FGLog(@"========makeupSession:%@",ApplicationDelegate.currProxy);
    if(ApplicationDelegate.currProxy) {
        NSString *domain = ApplicationDelegate.currProxy.domain;
        NSInteger port = ApplicationDelegate.currProxy.port;
        NSDictionary *proxy = @{(NSString*)kCFStreamPropertyHTTPProxyHost: domain,(NSString*)kCFStreamPropertyHTTPProxyPort:@(port)};
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        conf.connectionProxyDictionary = proxy;
        self.session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
        NSLog(@"=========make up session with proxy domain:%@, port:%ld",domain,(long)port);
    } else{
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
        NSLog(@"=========make up session without proxy");
    }
}

- (NSString *)getDefaultUserAgent
{
    NSString *userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSLog(@"=============default User-Agent:%@",userAgent);
    return userAgent;
}

-(void)setUserAgent:(NSMutableURLRequest *)request
{
    if (ApplicationDelegate.currProxy) {
        //zhpticg(token/key/timestamp/version)
        NSMutableString *userAgent = [NSMutableString stringWithFormat:@"%@ %@",self.defaultUA,ApplicationDelegate.currProxy.proxyString];
        [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
}

-(void)dismissKeyboard:(id)sender
{
    [self.url resignFirstResponder];
}

-(void)resetTask
{
    self.currStatus = 0;
    self.progress.text = @"0%";
    self.status.text = @"准备就绪";
    if(self.task){
        [self.task cancel];
        self.task = nil;
    }
    if (self.partialData) {
        self.partialData = nil;
    }
}

- (IBAction)set3MUrl:(id)sender
{
    self.url.text = _3M_FILE;
    [self resetTask];
}

- (IBAction)set50MUrl:(id)sender
{
    self.url.text = _50M_FILE;
    [self resetTask];
}


- (IBAction)set100MUrl:(id)sender
{
    self.url.text = _100M_FILE;
    [self resetTask];
}

- (IBAction)setImageUrl:(id)sender
{
    self.url.text = IMG_FILE;
    [self resetTask];
}

-(void)alert:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)start:(id)sender
{
    //[self resetTask];
    if (self.currStatus == 0) {
        self.currStatus = 1;
    }else{
        //[self alert:@"下载进行中"];
        return;
    }
    NSString *downloadUrl = self.url.text;
    if (downloadUrl == nil || [downloadUrl isEqualToString:@""]) {
        [self alert:@"请输入下载的url"];
        return;
    }
    NSLog(@"=============download:%@",downloadUrl);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    //[self setHeaderToRequest:request];
    [self setUserAgent:request];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
//  
//    
//    self.task = [self.session downloadTaskWithRequest:request];
//    [self.task resume];
    self.status.text = @"正在下载";
}
#pragma mark - NSURLSessionDataDelegate methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"=====connection didReceiveData");
  //  [self.client URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"=====connection didFailWithError");
   // [self.client URLProtocol:self didFailWithError:error];
   // self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"=====connection didReceiveResponse");
  //  [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"=====connection connectionDidFinishLoading");
 //   [self.client URLProtocolDidFinishLoading:self];
 //   self.connection = nil;
}
- (IBAction)pause:(id)sender
{
    if (self.currStatus == 1) {
        self.currStatus = 2;
    }else{
        return;
    }
    self.status.text = @"暂停下载";
    if (self.task) {
        [self.task cancelByProducingResumeData:^(NSData *resumeData) {
            NSLog(@"================cancelByProducingResumeData");
            self.partialData = resumeData;
            self.task = nil;
        }];
        NSLog(@"================cancelByProducingResumeData2");
    }
}

- (IBAction)resume:(id)sender
{
    if (self.currStatus == 2) {
        self.currStatus = 1;
    }else{
        //[self alert:@""];
        return;
    }
    NSLog(@"===data:%@",self.partialData);
    if (!self.task) {
        if (self.partialData) {
            self.task = [self.session downloadTaskWithResumeData:self.partialData];
        } else {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url.text]];
            //[self setHeaderToRequest:request];
            [self setUserAgent:request];
            self.task = [self.session downloadTaskWithRequest:request];
        }
    }
    
    self.status.text = @"继续下载";
    [self.task resume];
}

-(NSURL*)createDirectoryForDownloadItemFromURL:(NSURL*)location {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *docDir = urls[0];
    return [docDir URLByAppendingPathComponent:[location lastPathComponent]];
}

-(BOOL)copyTempFileAtURL:(NSURL*)location destination:(NSURL*)destination {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:destination error:nil];
    [fileManager copyItemAtURL:location toURL:destination error:&error];
    
    if (error) {
        NSLog(@"copyTempFileAtURL Error: %@",error);
    }
    
    return nil == error;
}

#pragma mark - NSURLSessionDownloadDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {

    NSLog(@"=========didFinishDownloadingToURL:%@",location);
    
    NSURL *destination = [self createDirectoryForDownloadItemFromURL:location];
    BOOL success = [self copyTempFileAtURL:location destination:destination];
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progress.text = @"100%";
            self.status.text = @"下载完成";
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.progress.text = @"100%";
            self.status.text = @"下载失败";
        });
        NSLog(@"download error!");
    }
    self.task = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"============didWriteData");
    double current = totalBytesWritten / (double)totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progress.text = [NSString stringWithFormat:@"%0.0f%%",100*current];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"============didResumeAtOffset");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
