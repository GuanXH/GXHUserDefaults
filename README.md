# GXHUserDefaults
快捷使用NSUserDefaults  支持.语法  支持多用户切换
###  使用方法
创建一个GXHUserDefaults的category  添加相关属性
.m文件中 @dynamic 相关属性
例如：
```
 #import   <GXHUserDefaults/GXHUserDefaults.h>
     
     
     @interface GXHUserDefaults (appSetting)
     @property (nonatomic,copy) NSString * userName;
     @property (nonatomic,assign) int age;
     @property (nonatomic,assign) NSInteger userid;
     @property (nonatomic,assign) float height;
     @property (nonatomic,assign) double weight;
     @property (nonatomic,assign) BOOL islogin;
     @property (nonatomic,assign) BOOL isNignt;
     @property (nonatomic,strong) NSArray * testArray;
     @end
```

```
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

```
---
##### 以下方法不是必须实现  看工程需求对应实现  函数里不要使用GXHUserDefaults实例 会造成递归问题
###### 1.添加前缀 依据需求实现此方法   如果无此需求可以不实现方法
```
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
```
###### 2.添加默认值
```
//初始默认值 把初始想赋值的属性写在这里    ps：如果以某个属性作为其他属性的前缀 例如userid   首先赋值userid  再调用gxh_resetToDefault
- (NSDictionary *)defaultsValueForProperty{
    return @{
             @"islogin":@(NO),
             @"userName":@"游客路人甲",
             @"testArray":@[@"1",@"2",@"3"]
             };
}
```
---
##### 使用demo
###### 1.正常使用  无用户切换
```
- (void)test{
    GXHUserDef.userid = 123456;
    GXHUserDef.userName = @"guan";
    GXHUserDef.height = 1.8;
    NSLog(@"test %@",[GXHUserDef gxh_fetchCurrentKeyValues]);
}
```
###### 1.将userid或者一个别的属性做为前缀  实现用户切换的情况    先赋值  再使用gxh_setDefaults 获取默认值  

```
  - (void)test2{
    GXHUserDef.userid = 678910;
   [GXHUserDef gxh_setDefaults];
    GXHUserDef.userName = @"GUAN";
    GXHUserDef.height = 1.8;
    NSLog(@"test2 %@",[GXHUserDef gxh_fetchCurrentKeyValues]);
}
```





     