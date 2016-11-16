//
//  GXHUserDefaults+appSetting.h
//  GXHUserDefaults
//
//  Created by guanxuhang1234 on 16/11/14.
//  Copyright © 2016年 guanxuhang1234. All rights reserved.
//
#import "GXHUserDefaults.h"

@interface GXHUserDefaults (appSetting)
@property (nonatomic,copy) NSString * userName;
@property (nonatomic,assign)  int age;
@property (nonatomic,assign) NSInteger userid;
@property (nonatomic,assign) float height;
@property (nonatomic,assign) double weight;
@property (nonatomic,assign) BOOL islogin;
@property (nonatomic,assign) BOOL isNignt;
@property (nonatomic,strong) NSArray * testArray;
@end
