//
//  FlowGateApp1Tests.m
//  FlowGateApp1Tests
//
//  Created by tianb on 4/30/14.
//  Copyright (c) 2014 21cn. All rights reserved.
//

#import <XCTest/XCTest.h>
@interface FlowGateApp1Tests : XCTestCase

@end

@implementation FlowGateApp1Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    WKWebView *w = nil;
    
    
    //初始化SDK
    [FGAgent initWithClientId:clientId appSign:appSign delegate:self];
    //设置手机号码
    [FGAgent setMobile:self.mobile.text];
    //开启代理服务
    [FGAgent startService];
    
    //App监听网络情况,发生变化时通知FGAgent
    [FGAgent networkDidChanged:0];
    
    //App实现delegate的agentDidUpdateProxy方法,以监控代理回调
    -(void)agentDidUpdateProxy:(FGProxyResult *)result
    {
        if (result.result == 0) {//成功
            //更新并保存本地的代理信息
            self.domain.text = result.domain;
            self.port.text = [NSString stringWithFormat:@"%ld",(long)result.port];
            self.proxyString.text = result.proxyString;
            self.expireMins.text = [NSString stringWithFormat:@"%ld",(long)result.expireMins];
        }else{//失败
            [self showErrorMsg:result.msg];
            //清除本地保存的代理信息
        }
    }
    
    //App实现delegate的agentDidReceiveMessages方法,以监控消息回调
    -(void)agentDidReceiveMessages:(FGMsgResult *)result
    {
        if (result.result == 0) {//成功
            NSMutableString *str = [NSMutableString string];
            for(FGMsgItem *item in result.items){
                [str appendFormat:@"%@\n",item.desc];
            }
        }else{//失败
            ...
        }
    }
    
    //App在代理服务期间可以主动请求代理信息
    [FGAgent setNeedUpdateProxy];
    
    
    //关闭代理服务
    [FGAgent stopService];
    
}

@end
