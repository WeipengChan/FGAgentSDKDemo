                               //
//  MainViewController.m
//  FlowGateApp1
//
//  Created by mairuifeng on 14-10-28.
//  Copyright (c) 2014年 21cn. All rights reserved.
//

#import "MainViewController.h"
#import "Reachability.h"
#import "AppDelegate.h"
@interface MainViewController ()
@property(nonatomic,weak) IBOutlet UITextField *mobile;
//@property(nonatomic,weak) IBOutlet UITextField *tk;
//@property(nonatomic,weak) IBOutlet UITextField *ts;
//@property(nonatomic,weak) IBOutlet UITextField *ks;
@property(nonatomic,weak) IBOutlet UITextField *captcha;
@property(nonatomic,weak) IBOutlet UITextField *domain;
@property(nonatomic,weak) IBOutlet UITextField *port;
@property(nonatomic,weak) IBOutlet UITextField *proxyString;
@property(nonatomic,weak) IBOutlet UITextField *expireMins;

@property(nonatomic,weak) IBOutlet UISwitch *devSwitch;
@property(nonatomic,weak) IBOutlet UISwitch *wifiSwitch;
@property(nonatomic,weak) IBOutlet UISwitch *wifiDebugSwitch;

@property(nonatomic,weak) IBOutlet UITableView *table;

@property(nonatomic,weak) IBOutlet UILabel *totalKB;
@property(nonatomic,weak) IBOutlet UILabel *usedKB;

@property(nonatomic,strong) NSMutableArray *flowHistoryItems;

@property (strong, nonatomic) Reachability *reachability;


@property(nonatomic,weak) IBOutlet UILabel *errorMsg;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.hidden = YES;
    self.mobile.text = @"18928852002";
   // self.mobile.text = @"13326872007";
   // self.mobile.text = @"18900001111";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    NSString *clientId = @"test";
    NSString *appSign = @"com.chinatelecom.189mail";
    //初始化SDK
    [FGAgent initWithClientId:clientId appSign:appSign delegate:self];
    //监听网络
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    //self.reachability = [Reachability reachabilityForInternetConnection];
    self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [self.reachability startNotifier];
    
    self.devSwitch.on = YES;
    self.wifiSwitch.on = YES;
    
    [FGAgent enableTestMode:self.devSwitch.isOn];
    [FGAgent enableWifiDebugMode:self.wifiSwitch.isOn];
    

}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    FGLog(@"===========network did change:%ld",(long)status);
    if (status == NotReachable) {
        [FGAgent networkDidChanged:0];
    } else if(status == ReachableViaWiFi) {
        [FGAgent networkDidChanged:1];
    } else if (status == ReachableViaWWAN) {
        [FGAgent networkDidChanged:2];
    }
}

//有推送消息时调用
-(void)agentDidReceiveMessages:(FGMsgResult *)result
{
    FGLog(@"==============agentDidReceiveMessages");
    if (result.result == 0) {
        NSMutableString *str = [NSMutableString string];
        for(FGMsgItem *item in result.items){
            [str appendFormat:@"%@\n",item.desc];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alert:str title:@"收到消息"];
        });
    }
}
//更新代理消息时调用
-(void)agentDidUpdateProxy:(FGProxyResult *)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        FGLog(@"==============agentDidUpdateProxy,msg:%@",result.msg);
        if (result.result == 0) {
            self.domain.text = result.domain;
            self.port.text = [NSString stringWithFormat:@"%ld",(long)result.port];
            self.proxyString.text = result.proxyString;
            self.expireMins.text = [NSString stringWithFormat:@"%ld",(long)result.expireMins];
            //保存当前代理,以便后续使用
            ApplicationDelegate.currProxy = result;
            
            FGLog(@"==============agentDidUpdateProxy,ApplicationDelegate.currProxy:%@",ApplicationDelegate.currProxy);
            [self showErrorMsg:[NSString stringWithFormat:@"代理更新成功,过期时间:%ld分钟",(long)result.expireMins]];
        }else{
            //使当前代理失效
            ApplicationDelegate.currProxy = nil;
            FGLog(@"error:%@",result.msg);
            [self showErrorMsg:result.msg];
        }
    });
    
}

-(void)agentSeviceDidStart:(FGResult *)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        FGLog(@"==============agentSeviceDidStart:%@",result.msg);
        if (result.result == 0) {
            [self showErrorMsg:@"服务已开启"];
        }else{
            [self showErrorMsg:[NSString stringWithFormat:@"服务开启失败:%@",result.msg]];
        }
    });
}
-(void)agentSeviceDidStop:(FGResult *)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        FGLog(@"==============agentSeviceDidStop:%@",result.msg);
        //使当前代理失效
        ApplicationDelegate.currProxy = nil;
        if (result.result == 0) {
            [self showErrorMsg:@"服务已停止"];
        }else{
            [self showErrorMsg:[NSString stringWithFormat:@"服务停止失败:%@",result.msg]];
        }
    });
}

-(void)showErrorMsg:(NSString *)msg
{
    self.errorMsg.text = msg;
    [self performSelector:@selector(hideErrorMsg) withObject:nil afterDelay:3];
}

-(void)hideErrorMsg
{
    self.errorMsg.text = @"";
}

-(void)dismissKeyboard:(id)sender
{
    [self.mobile resignFirstResponder];
    [self.domain resignFirstResponder];
    [self.port resignFirstResponder];
    [self.proxyString resignFirstResponder];
    [self.expireMins resignFirstResponder];
    [self.captcha resignFirstResponder];
}

-(void)alert:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)alert:(NSString *)msg title:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)startService:(id)sender
{
    [FGAgent setMobile:self.mobile.text];
    [FGAgent startService];
}

- (IBAction)stopService:(id)sender
{
    self.domain.text = @"";
    self.port.text = @"";
    self.proxyString.text = @"";
    self.expireMins.text = @"";
    //关闭代理服务
    [FGAgent stopService];
}

- (IBAction)setNeedUpdateProxy:(id)sender
{
    [FGAgent setNeedUpdateProxy];
}


-(IBAction)inValidToken:(id)sender
{
    [FGAgent invalidCurrProxyWithMobile:self.mobile.text result:^(FGResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.result == 0) {
                self.domain.text = @"";
                self.port.text = @"";
                self.proxyString.text = @"";
                self.expireMins.text = @"";
                //使当前代理失效
                ApplicationDelegate.currProxy = nil;
                [self alert:@"请求成功"];
            }else{
                [self alert:result.msg];
            }
        });
    }];
}


-(IBAction)sendCaptcha:(id)sender
{
    [FGAgent sendCaptchaToMobile:self.mobile.text result:^(FGResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.result == 0) {
                [self alert:@"短信发送成功"];
            }else{
                [self alert:result.msg];
            }
        });
    }];
}


-(IBAction)checkCaptcha:(id)sender
{
    [FGAgent checkCaptcha:self.captcha.text withMobile:self.mobile.text result:^(FGResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.result == 0) {
                [self alert:@"验证成功"];
            }else{
                [self alert:result.msg];
            }
        });
    }];
}

-(IBAction)getOrder:(id)sender
{
    [FGAgent getOrderWithMobile:self.mobile.text result:^(FGOrderResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.result == 0) {
                self.totalKB.text = [NSString stringWithFormat:@"共有 %@K",result.total];
                self.usedKB.text = [NSString stringWithFormat:@"已用 %@K",result.used];
                [self showErrorMsg:@"查询流量成功"];
            }else{
                [self alert:result.msg];
            }
        });
    }];
}

-(IBAction)getFlowHistory:(id)sender
{
    //暂时不公开这个api
//    [FGAgent getFlowHistoryWithMobile:self.mobile.text fromDate:@"2014-10-1" toDate:@"2014-10-29" result:^(FGFlowResult *result) {
//        if (result.result == 0) {
//            if (result.items && [result.items count] > 0) {
//                self.flowHistoryItems = [result.items mutableCopy];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.table.hidden = NO;
//                    [self.table reloadData];
//                });
//            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self alert:@"没有记录"];
//                });
//            }
//        }else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self alert:result.msg];
//            });
//        }
//    }];
}

- (IBAction)testModeAction:(UISwitch *)sender {
    [FGAgent enableTestMode:sender.isOn];
}

- (IBAction)wifiModeAction:(UISwitch *)sender {
    [FGAgent enableWifiDebugMode:sender.isOn];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.flowHistoryItems) {
        return [self.flowHistoryItems count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor redColor];
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
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
