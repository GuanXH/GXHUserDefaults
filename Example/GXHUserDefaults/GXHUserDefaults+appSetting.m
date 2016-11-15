//
//  GXHUserDefaults+appSetting.m
//  GXHUserDefaults
//
//  Created by guanxuhang1234 on 16/11/14.
//  Copyright © 2016年 guanxuhang1234. All rights reserved.
//

#import "GXHUserDefaults+appSetting.h"

@implementation GXHUserDefaults (appSetting)

@dynamic userName;
@dynamic age;
@dynamic userid;
@dynamic height;
@dynamic weight;
@dynamic islogin;
@dynamic isNignt;
@dynamic testArray;


#pragma mark - 以下不是必须实现  看工程需求对应实现  函数里不要使用GXHUserDefaults实例 造成递归问题

//初始默认值 把初始想赋值的属性写在这里    ps：如果以某个属性作为其他属性的前缀 例如userid   首先赋值userid  再调用gxh_resetToDefault
- (NSDictionary *)defaultsValueForProperty{
    return @{
             @"islogin":@(NO),
             @"userName":@"游客路人甲",
             @"testArray":@[@"1",@"2",@"3"]
             };
}

//一般用于多用户切换  字段的前缀  比如 prefix 为 guan_  [NSUserDefaults standardUserDefaults]里真正存的key是guan_username
//无多用户切换可以不实现
- (NSString *)userPropertyPrefixWithPropertyName:(NSString *)propertyName{
    NSArray * ignoreArray = @[@"userid",@"isNignt",@"islogin",@"testArray"];//忽略前缀的数组  一般用于公共参数  无用户差别
    if ([ignoreArray indexOfObject:propertyName]!=NSNotFound) {
        
        
        return nil;
    }
    // ps：自己不能作为自己的前缀   比如 userid  不能拿userid作为前缀 可以使用GXHUserDefaults 的类方法fetchValueForKey: 去取
    NSNumber * userid = [GXHUserDefaults fetchValueForKey:@"userid"];
    NSString * prefix;
    if (userid) {
         prefix  = [NSString stringWithFormat:@"%@",userid];
    }
    return prefix;
}

@end
