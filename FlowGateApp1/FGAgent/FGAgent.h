//
//  FGAgent.h
//  FlowgateSDK
//
//  Created by mairuifeng on 14-10-27.
//  Copyright (c) 2014年 21CN Corporation Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FGResult.h"

@protocol FGAgentDelegate <NSObject>
@optional
//服务开启后调用
-(void)agentSeviceDidStart:(FGResult *)result;
//服务关闭后调用
-(void)agentSeviceDidStop:(FGResult *)result;
//返回代理信息时调用
-(void)agentDidUpdateProxy:(FGProxyResult *)proxyResult;
//有推送消息时调用
-(void)agentDidReceiveMessages:(FGMsgResult *)msgResult;
@end


@interface FGAgent : NSObject
//初始化
+(void)initWithClientId:(NSString *)clientId appSign:(NSString *)appSign delegate:(id<FGAgentDelegate>)delegate;
//设置手机号码
+(void)setMobile:(NSString *)mobile;
//开启服务
+(void)startService;
//关闭服务
+(void)stopService;
//如果服务已经开启,发起一次更新请求
+(void)setNeedUpdateProxy;
//开启测试模式
+(void)enableTestMode:(BOOL)enabled;
//开启WIFI调试模式
+(void)enableWifiDebugMode:(BOOL)enabled;
//网络状态回调
+(void)networkDidChanged:(NSInteger)_networkStatus;
//获取订购信息
+(void)getOrderWithMobile:(NSString *)mobile result:(void (^)(FGOrderResult *result))responseBlock;
//获取流量使用历史
//+(void)getFlowHistoryWithMobile:(NSString *)mobile fromDate:(NSString *)beginDate toDate:(NSString *)endDate result:(void (^)(FGFlowResult *result))responseBlock;
//发送短信验证码
+(void)sendCaptchaToMobile:(NSString *)mobile result:(void (^)(FGResult *result))responseBlock;
//查验短信验证码
+(void)checkCaptcha:(NSString *)captcha withMobile:(NSString *)mobile result:(void (^)(FGResult *result))responseBlock;
//注销当前token,使当前的代理信息失效
+(void)invalidCurrProxyWithMobile:(NSString *)mobile result:(void (^)(FGResult *result))responseBlock;
//返回缺省的UserAgent
+(NSString *)defaultUA;


@end
