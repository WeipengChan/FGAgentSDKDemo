//
//  MyUrlProtocol.m
//  FlowGateApp1
//
//  Created by mairuifeng on 14-11-11.
//  Copyright (c) 2014年 21cn. All rights reserved.
//

#import "MyUrlProtocol.h"
#import "FGAgent.h"
#import "AppDelegate.h"
@interface MyUrlProtocol ()
@property (nonatomic, strong) NSURLConnection *connection;
@property(nonatomic,strong)NSURLSession *session;
//@property(nonatomic,strong)NSString *defaultUA;
@end

@implementation MyUrlProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL b = NO;
    //if ([FGAgent currValidAgentResult]) {
        if ([NSURLProtocol propertyForKey:@"FGUserAgentSet" inRequest:request] == nil){
            b = YES;
        }
    //}
    //NSLog(@"=====canInitWithRequest:%@, %@",@(b),request);
    return b;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

//- (NSString *)getDefaultUserAgent
//{
//    if (self.defaultUA) {
//        return [self.defaultUA copy];
//    }
//    NSString *userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
//    NSLog(@"=============default User-Agent:%@",userAgent);
//    return userAgent;
//}

-(void)setUserAgent:(NSMutableURLRequest *)request
{
    if (ApplicationDelegate.currProxy) {
        NSString *ua = [FGAgent defaultUA];
        //zhpticg(token/key/timestamp/version)
        NSMutableString *userAgent = [NSMutableString stringWithFormat:@"%@ %@",ua,ApplicationDelegate.currProxy.proxyString];
        [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    
}

- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    
    
    NSLog(@"=====startLoading:thd=%@, self=%@, req=%@",[NSThread currentThread],self,newRequest);
    
    
    
    // Here we set the User Agent
    //[newRequest setValue:@"Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.2 Safari/537.36 Kifi/1.0f" forHTTPHeaderField:@"User-Agent"];
    
    //设置报头
    [self setUserAgent:newRequest];
    
    //设置代理
    [self setPoxyForNSURLRequest:(NSMutableURLRequest * )newRequest];
    
    
    
    
    [NSURLProtocol setProperty:@YES forKey:@"FGUserAgentSet" inRequest:newRequest];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
    
    //self.connection
   // newRequest addValue:<#(NSString *)#> forHTTPHeaderField:<#(NSString *)#>
    
    
    
    if(ApplicationDelegate.currProxy) {
        NSString *domain = ApplicationDelegate.currProxy.domain;
        NSInteger port  = ApplicationDelegate.currProxy.port;
        NSDictionary *proxy = @{(NSString*)kCFStreamPropertyHTTPProxyHost: domain,
                                (NSString*)kCFStreamPropertyHTTPProxyPort: @(port)};
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        conf.connectionProxyDictionary = proxy;
        self.session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
        NSLog(@"=========make up session with proxy domain:%@, port:%ld",domain,(long)port);
    } else{
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
        NSLog(@"=========make up session without proxy");
    }
    
    
    
    
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:newRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"=====dataTask complete error=%@",error);
        if (error) {
            [self.client URLProtocol:self didFailWithError:error];
        }else{
            
            
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
            NSLog(@"=========URLProtocolDidFinishLoading");
        }
    }];
    [dataTask resume];
    
}

- (void)stopLoading
{
    NSLog(@"=====stopLoading:%@",self.request);
    //if(self.connection)[self.connection cancel];
    if (self.session) {
        [self.session invalidateAndCancel];
    }
    
}



#pragma mark - NSURLSessionDataDelegate methods
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"=====URLSession didReceiveResponse");
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    NSLog(@"=====URLSession didBecomeDownloadTask");
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"=====URLSession didReceiveData");
    [self.client URLProtocol:self didLoadData:data];
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSLog(@"=====URLSession willCacheResponse");
}


#pragma mark - NSURLSessionDataDelegate methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"=====connection didReceiveData");
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"=====connection didFailWithError");
    [self.client URLProtocol:self didFailWithError:error];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"=====connection didReceiveResponse");
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"=====connection connectionDidFinishLoading");
    [self.client URLProtocolDidFinishLoading:self];
    self.connection = nil;
}
@end
