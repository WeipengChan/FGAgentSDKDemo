//
//  ViewController.m
//  FlowGateApp1
//
//  Created by tianb on 4/30/14.
//  Copyright (c) 2014 21cn. All rights reserved.
//
//#import "RegexKitLite.h"


//#import "FlowGateSDK.h"


#import "ViewController.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "TestViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSString *bundle;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *timeStamp;

@property (strong, nonatomic) Reachability * netReach;

@property (strong, nonatomic) IBOutlet UILabel *lblToken;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (strong, nonatomic) IBOutlet UILabel *lblGetSmsCode;
@property (strong, nonatomic) IBOutlet UITextField *txtSmsCode;
@property (strong, nonatomic) IBOutlet UILabel *lblKey;
@property (weak, nonatomic) IBOutlet UILabel *lblCheckSms;
@property (weak, nonatomic) IBOutlet UILabel *lblExpireToken;

@property (nonatomic,assign) int i_offset;
@property (nonatomic,assign) int i_textFieldY;
@property (nonatomic,assign) int i_textFieldHeight;

@property (weak, nonatomic) IBOutlet UILabel *lblFlowInfo;

@property(nonatomic)IBOutlet UISwitch *devSwitch;
@property(nonatomic)IBOutlet UISwitch *wifiSwitch;
@property(nonatomic)IBOutlet UISwitch *wifiDebugSwitch;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    self.bundle = [[NSBundle mainBundle] bundleIdentifier];
    self.bundle = @"com.chinatelecom.189mail";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    self.netReach = [Reachability reachabilityForInternetConnection];
    [self.netReach startNotifier];
    
//    NSString *key = [[self getFlowgateSDK] generateKey:@"com.chinatelecom.189mail" token:@"E98A5E6E8FA034EA55CA67150F862497" timeStamp:@"1399867168"];
//    NSLog(@"key = %@", key);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.i_offset = 0;    //默认偏移量为0
    self.i_textFieldY = 0;
    self.i_textFieldHeight = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
//    //获取键盘的高度
//    self.view.frame = CGRectMake(self.view.frame.origin.x,
//                                 self.view.frame.origin.y-120,
//                                 self.view.frame.size.width,
//                                 self.view.frame.size.height);
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int keyboardHeight = keyboardRect.size.height;
    
    //计算偏移量
    self.i_offset = keyboardHeight - (self.view.frame.size.height-(self.i_textFieldY+self.i_textFieldHeight));
    
    //进行偏移
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
//    if(self.i_offset == 0)
//    {
        CGRect rect = CGRectMake(0.0f,-keyboardHeight,width,height); //把整个view 往上提，肯定要用负数 y
        self.view.frame = rect;
//    }
    
    [UIView commitAnimations];
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
//    self.view.frame = CGRectMake(self.view.frame.origin.x,
//                                 self.view.frame.origin.y+120,
//                                 self.view.frame.size.width,
//                                 self.view.frame.size.height);
//    if(self.i_offset > 0)
//    {
        //恢复到偏移前的正常量
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        CGRect rect = CGRectMake(0.0f,0,width,height); //把整个view 往上提，肯定要用负数 y   注意self.view 的y 是从20开始的，即StautsBarHeight
        self.view.frame = rect;
        
        [UIView commitAnimations];
//    }
//    
    self.i_offset = 0;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.txtMobile resignFirstResponder];
    [self.txtSmsCode resignFirstResponder];
}

#pragma mark -
#pragma mark net change methods
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable) {
        //not reachable
    } else if(status == ReachableViaWiFi) {
        //wifi
        //[self expireToken];
    } else if (status == ReachableViaWWAN) {
        //3g
        //[self expireToken];
    }
    
}

-(IBAction)expireToken {
    if (![self isMobileNo:self.txtMobile.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    
    if (nil == self.token) {
        self.lblExpireToken.text = @"请先获取token";
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblExpireToken.text = @"";
        });
        
        [[self getFlowgateSDK] expireToken:@"test" mobile:self.txtMobile.text token:self.token appSign:self.bundle block:(^(NSDictionary *dict, NSError *error){
            NSLog(@"dic = %@",dict);
            
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            appDelegate.tk = nil;
            appDelegate.ts = nil;
            appDelegate.ks = nil;
            appDelegate.domain = nil;
            appDelegate.port = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblExpireToken.text = [NSString stringWithFormat:@"%d:%@",[[dict objectForKey:@"result"] intValue],(NSString*)[dict objectForKey:@"msg"]];
            });
        })];
    });
}

/**
 * Detect whether an account is a Chinese mobile No.
 */
- (BOOL)isMobileNo:(NSString *)mobile {
    if(mobile == nil || [mobile stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0 ){
        return NO;
    }
    
    return  YES;
    //return [mobile isMatchedByRegex:@"^((\\+86)?1(([358][0-9])|[4][57]))\\d{8}$|10000|10086|10010"];
}


- (IBAction)btnGetToken:(id)sender {
    if (![self isMobileNo:self.txtMobile.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.lblToken.text = @"";
//        });
//
//        [[self getFlowgateSDK] getToken:@"test" mobile:self.txtMobile.text appSign:self.bundle block:(^(NSDictionary *dict, NSError *error){
//            
//            NSString *text = nil;
//            if ([dict objectForKey:@"token"]) {
//                text = (NSString*)[dict objectForKey:@"token"];
//                self.token = text;
//                
//                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//                app.tk = text;
//            } else {
//                text = [NSString stringWithFormat:@"%d:%@",[[dict objectForKey:@"result"] intValue],(NSString*)[dict objectForKey:@"msg"]];
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.lblToken.text = text;
//            });
//        })];
//    });

    [[self getFlowgateSDK] getAgentInfo:@"test" mobile:self.txtMobile.text appSign:self.bundle block:^(NSDictionary *dictionary, NSError *error) {
        NSLog(@"dictionary = %@",dictionary);
        //NSLog(@"error = %d,%@",error.code,error.domain);
        
        if ([[dictionary objectForKey:@"result"] intValue] == 0) {
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            appDelegate.tk = [dictionary objectForKey:FGHttpHeaderFiledPropertyTK];
            appDelegate.ts = [dictionary objectForKey:FGHttpHeaderFiledPropertyTS];
            appDelegate.ks = [dictionary objectForKey:FGHttpHeaderFiledPropertyKS];
            appDelegate.domain = [dictionary objectForKey:FGHttpHeaderFiledPropertyDomain];
            appDelegate.port = [dictionary objectForKey:FGHttpHeaderFiledPropertyPort];
            self.token =  appDelegate.tk;
            self.timeStamp = appDelegate.ts;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.lblToken.text = [NSString stringWithFormat:@"Token : %@",appDelegate.tk];
                self.lblTimestamp.text = [NSString stringWithFormat:@"Timestamp : %@",appDelegate.ts];
                self.lblKey.text = [NSString stringWithFormat:@"Key : %@",appDelegate.ks];
            });
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dictionary objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
            });

        }
    }];
    
}

- (IBAction)btnGetTimestamp:(id)sender {
    if (nil == self.token) {
        self.lblTimestamp.text = @"请先获取token";
        return;
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.lblTimestamp.text = @"";
//        });
//        
//        [[self getFlowgateSDK] getTimestamp:@"test" mobile:self.txtMobile.text appSign:self.bundle token:self.token block:(^(NSDictionary *dict, NSError *error){
//            NSLog(@"%@",(NSString*)[dict objectForKey:@"msg"]);
//            
//            NSString *text = nil;
//            if ([dict objectForKey:@"timeStamp"]) {
//                text = (NSString*)[dict objectForKey:@"timeStamp"];
//                self.timeStamp = text;
//                
//                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//                app.domain = (NSString*)[dict objectForKey:@"domain"];
//                app.port = (NSString*)[dict objectForKey:@"port"];
//                app.ts = text;
//            } else {
//                text = [NSString stringWithFormat:@"%d:%@",[[dict objectForKey:@"result"] intValue],(NSString*)[dict objectForKey:@"msg"]];
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.lblTimestamp.text = text;
//            });
//        })];
//    });
}

- (IBAction)getSmsCode:(id)sender {
    if (![self isMobileNo:self.txtMobile.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblGetSmsCode.text = @"";
        });
        
        [[self getFlowgateSDK] sendCaptcha:@"test" mobile:self.txtMobile.text appSign:self.bundle block:(^(NSDictionary *dict, NSError *error){
            NSLog(@"dic = %@",dict);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblGetSmsCode.text = [NSString stringWithFormat:@"%d:%@",[[dict objectForKey:@"result"] intValue],(NSString*)[dict objectForKey:@"msg"]];
            });
        })];
    });
}

- (IBAction)checkSmsCode:(id)sender {
    if (![self isMobileNo:self.txtMobile.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入收到验证码的手机号！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    
    if(self.txtSmsCode.text == nil || [self.txtSmsCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0 ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入你收到的短信验证码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblCheckSms.text = @"";
        });
        
        [[self getFlowgateSDK] checkCaptcha:@"test" mobile:self.txtMobile.text captcha:self.txtSmsCode.text appSign:self.bundle block:(^(NSDictionary *dict, NSError *error){
            NSLog(@"dic = %@",dict);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblCheckSms.text = [NSString stringWithFormat:@"%d:%@",[[dict objectForKey:@"result"] intValue],(NSString*)[dict objectForKey:@"msg"]];
            });
        })];
    });
}

- (IBAction)btnGenerateKey:(id)sender {
    if (![self isMobileNo:self.txtMobile.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入收到验证码的手机号！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    
//    if(self.txtSmsCode.text == nil || [self.txtSmsCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <=0 ){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入你收到的短信验证码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
//        alert.alertViewStyle = UIAlertViewStyleDefault;
//        [alert show];
//        return;
//    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.lblKey.text = @"";
//        });
//        
//        NSString *key = [[self getFlowgateSDK] generateKey:self.bundle token:self.token timeStamp:self.timeStamp];
//        if (nil != key) {
//            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//            app.ks = key;
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.lblKey.text = key;
//        });
//    });
}

- (FlowgateSDK *)getFlowgateSDK
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.flowgateSDK == nil) {
        delegate.flowgateSDK = [FlowgateSDK new];
    }
    return delegate.flowgateSDK;
}

- (IBAction)devSwitchAction:(UISwitch *)sender {
    FlowgateSDK *sdk = [self getFlowgateSDK];
    [sdk switchToDevMode:sender.isOn];
    //NSLog(@"========devSwitchAction:%@",sender.isOn?@"ON":@"OFF");
}

- (IBAction)wifiDebugSwitchAction:(UISwitch *)sender {
    FlowgateSDK *sdk = [self getFlowgateSDK];
    [sdk debugInWifi:sender.isOn];
    //NSLog(@"========wifiDebugSwitchAction:%@",sender.isOn?@"ON":@"OFF");
}

- (IBAction)wifiSwitchAction:(UISwitch *)sender {
    FlowgateSDK *sdk = [self getFlowgateSDK];
    [sdk networkDidChanged:sender.isOn];
    //NSLog(@"========wifiSwitchAction:%@",sender.isOn?@"ON":@"OFF");
}

- (IBAction)getFlowInfo:(id)sender {
    
    if (![self isMobileNo:self.txtMobile.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入手机号！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    
    [[self getFlowgateSDK] getOrdersInfo:@"test" mobile:self.txtMobile.text appSign:self.bundle block:^(NSDictionary *dictionary, NSError *error) {
        NSLog(@"dic = %@",dictionary);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblFlowInfo.text = [NSString stringWithFormat:@"总流量 %@K, 已使用 %@K",[
                                                                                    dictionary objectForKey:@"total"] ,
                                                                                    [dictionary objectForKey:@"used"]];
        });
        

    }];
    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[TestViewController new]];
//    [self presentViewController:navigationController animated:NO completion:^{
//        ;
//    }];
}


@end
