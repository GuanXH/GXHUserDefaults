//
//  GXHViewController.m
//  GXHUserDefaults
//
//  Created by guanxuhang1234 on 11/14/2016.
//  Copyright (c) 2016 guanxuhang1234. All rights reserved.
//

#import "GXHViewController.h"
#import "GXHUserDefaults+appSetting.h"
@interface GXHViewController ()

@end

@implementation GXHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self test];
    [self test2];

	// Do any additional setup after loading the view, typically from a nib.
}
#pragma mark - 无多用户切换
- (void)test{
    GXHUserDef.userid = 123456;
    GXHUserDef.userName = @"guan";
    GXHUserDef.height = 1.8;
    NSLog(@"test %@",[GXHUserDef gxh_fetchCurrentKeyValues]);
}
#pragma mark - 多用户切换
- (void)test2{
    GXHUserDef.userid = 678910;
   [GXHUserDef gxh_setDefaults];
    GXHUserDef.userName = @"GUAN";
    GXHUserDef.height = 1.8;
    NSLog(@"test2 %@",[GXHUserDef gxh_fetchCurrentKeyValues]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
