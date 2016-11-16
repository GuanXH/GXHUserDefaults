//
//  GXHUserDefaults.m
//  GXHUserDefaults
//
//  Created by guanxuhang1234 on 16/11/15.
//  Copyright © 2016年 guanxuhang1234. All rights reserved.
//

#import <Foundation/Foundation.h>
#define GXHUserDef [GXHUserDefaults standardUserDefaults]
@interface GXHUserDefaults : NSObject

+ (instancetype)standardUserDefaults;
/**
  如果之前没有赋过值 赋defaultsValueForProperty返回的值
 */
- (void)gxh_setDefaults;
/**
   如果之前赋过值 清除  赋defaultsValueForProperty返回的值
 */
- (void)gxh_resetToDefault;

/**
 返回当前所有已赋值属性的keyvalues

 @return keyvalues字典
 */
- (NSDictionary *)gxh_fetchCurrentKeyValues;

/**
 清空所有值
 */
- (void)gxh_cleanAll;


/**
  取字段值    bool  float····· 会返回number

 @param key <#key description#>
 */
+ (id)fetchValueForKey:(NSString *)key;
@end
