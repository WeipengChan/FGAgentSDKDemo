//
//  TestViewController.m
//  FlowGateApp1
//
//  Created by 赵瑜瑜 on 14-9-23.
//  Copyright (c) 2014年 21cn. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *flowInfoItems;
@property (nonatomic, strong) UITableView *flowInfoTableView;
@property (nonatomic, strong) UILabel *noResultLabel;

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //self.flowInfoItems = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3"]];
    self.flowInfoItems = [NSMutableArray array];
    
    UIBarButtonItem *returnBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = returnBarButtonItem;
    
    self.flowInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,640) style:UITableViewStylePlain];
    [self.view addSubview:self.flowInfoTableView];
    
    self.noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 ,320, 320, 17)];
    self.noResultLabel.text = @"无流量";
    self.noResultLabel.font = [UIFont systemFontOfSize:17];
    self.noResultLabel.textColor = [UIColor lightGrayColor];
    self.noResultLabel.textAlignment = NSTextAlignmentCenter;
    self.noResultLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.noResultLabel];
    
    if([self.flowInfoItems count] > 0) {
        self.noResultLabel.hidden = YES;
    }
    
    self.flowInfoTableView.delegate = self;
    self.flowInfoTableView.dataSource = self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flowInfoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableViewIdentify = @"tableViewIdentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewIdentify];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewIdentify];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [self.flowInfoItems objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)cancel {
    
    NSLog(@"cacel clicked");
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
