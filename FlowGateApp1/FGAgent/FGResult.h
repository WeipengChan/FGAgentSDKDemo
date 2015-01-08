//
//  FGResult.h
//  FlowgateSDK
//
//  Created by mairuifeng on 14-10-24.
//  Copyright (c) 2014年 21CN Corporation Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark - FGResult
@interface FGResult : NSObject
@property(nonatomic,assign)NSInteger result;
@property(nonatomic,strong)NSString *msg;
@property(nonatomic,strong)NSString *mobile;

+(id)resultWithDictionary:(NSDictionary *)dic;
-(id)initWithDictionary:(NSDictionary *)dic;
@end

#pragma mark - FGProxyResult
@interface FGProxyResult : FGResult
@property(nonatomic,strong)NSString *domain;
@property(nonatomic,assign)NSInteger port;
@property(nonatomic,strong)NSString *proxyString;//格式: zhpticg(token/key/timeStamp/version)
@property(nonatomic,assign)NSInteger expireMins;//超时时间,单位分钟

-(id)initWithDictionary:(NSDictionary *)dic andAppSign:(NSString *)appSign andVersion:(NSString *)version;
@end

#pragma mark - FGOrderResult
@interface FGOrderResult : FGResult
@property(nonatomic,strong)NSString *total;//总流量,单位KB
@property(nonatomic,strong)NSString *used;//已使用流量,单位KB
@end

#pragma mark - FGMsgResult
@interface FGMsgItem : NSObject
@property(nonatomic,strong)NSString *code;//消息代码
@property(nonatomic,strong)NSString *desc;//消息内容
@property(nonatomic,strong)NSString *content1;//消息扩展内容1
@property(nonatomic,strong)NSString *content2;//消息扩展内容2
@property(nonatomic,strong)NSString *createTime;//创建时间
@end

@interface FGMsgResult : FGResult
@property(nonatomic,strong)NSMutableArray *items;
@end

//#pragma mark - FGFlowResult
//@interface FGFlowItem : NSObject
//@property(nonatomic,strong)NSString *itemDate;//日期,格式:yyyy-MM-dd
//@property(nonatomic,strong)NSString *used;//使用的流量,单位KB
//@end
//
//@interface FGFlowResult : FGResult
//@property(nonatomic,strong)NSMutableArray *items;
//@end

