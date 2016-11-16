//
//  GXHUserDefaults.m
//  GXHUserDefaults
//
//  Created by guanxuhang1234 on 16/11/15.
//  Copyright © 2016年 guanxuhang1234. All rights reserved.
//

#import "GXHUserDefaults.h"
#import <objc/runtime.h>

@interface GXHPropertyInfoModel : NSObject
@property(nonatomic,copy)NSString * setterTypes;
@property(nonatomic,copy)NSString * getterTypes;
@property(nonatomic,copy)NSString * setterMethodName;
@property(nonatomic,copy)NSString * getterMethodName;
@property(nonatomic,assign)IMP setterImp;
@property(nonatomic,assign)IMP getterImp;
@property(nonatomic,copy)NSString * propertyName;
@property(nonatomic,assign)BOOL isObject;
@end
@implementation GXHPropertyInfoModel
@end
@interface GXHUserDefaults ()

@end
static NSUserDefaults * currentUserDefaults;
static NSMutableDictionary * propertyInfoModels;
@implementation GXHUserDefaults


+ (instancetype)standardUserDefaults{
    static dispatch_once_t pred;
    static GXHUserDefaults *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance gxh_setDefaults];
    });
    return sharedInstance;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        currentUserDefaults = [NSUserDefaults standardUserDefaults];
        propertyInfoModels = [[NSMutableDictionary alloc] init];
        [self addMethods];
    }
    return self;
}
- (void)addMethods{
    unsigned int propertyCount = 0;
    
    objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);

    for (int i = 0; i < propertyCount; i ++) {
        GXHPropertyInfoModel * info = [[GXHPropertyInfoModel alloc] init];
        objc_property_t property = propertys[i];
        const char * propertyName = property_getName(property);
        info.propertyName =[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSString * propertyAttribute = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        NSString * T_value = [[propertyAttribute componentsSeparatedByString:@","] firstObject];
        NSString * type = [T_value substringWithRange:NSMakeRange(1, T_value.length-1)];
        [self getMethodEncodingTypesWithPropertyType:[type characterAtIndex:0] andInfoModel:info];
        class_addMethod([self class],sel_registerName([info.getterMethodName cStringUsingEncoding:NSUTF8StringEncoding]), info.getterImp, [info.getterTypes cStringUsingEncoding:NSUTF8StringEncoding]);
        class_addMethod([self class],sel_registerName([info.setterMethodName cStringUsingEncoding:NSUTF8StringEncoding]), info.setterImp, [info.setterTypes cStringUsingEncoding:NSUTF8StringEncoding]);
        [propertyInfoModels  setObject:info forKey:info.getterMethodName];
        [propertyInfoModels  setObject:info forKey:info.setterMethodName];
    }
    ///一定要释放
    free(propertys);
}

/**
  如果之前没有赋过值 赋defaultsValueForProperty返回的值
 */
- (void)gxh_setDefaults{
    NSDictionary * defautsValue;
    if ([self respondsToSelector:@selector(defaultsValueForProperty)]) {
        defautsValue = [self performSelector:@selector(defaultsValueForProperty)];
    }
    [propertyInfoModels  enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        GXHPropertyInfoModel * info = obj;
        NSString * property_key = [self getKeyWithPropertyName:info.propertyName];
        if (defautsValue&&[defautsValue objectForKey:info.propertyName]&&[[NSUserDefaults standardUserDefaults] objectForKey:property_key]==nil){
            [[NSUserDefaults standardUserDefaults] setObject:[defautsValue objectForKey:info.propertyName] forKey:property_key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}
/**
 重新初始到默认值状态
 */
- (void)gxh_resetToDefault{
    NSDictionary * defautsValue;
    if ([self respondsToSelector:@selector(defaultsValueForProperty)]) {
        defautsValue = [self performSelector:@selector(defaultsValueForProperty)];
    }
    [propertyInfoModels  enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        GXHPropertyInfoModel * info = obj;
        NSString * property_key = [self getKeyWithPropertyName:info.propertyName];
        if (defautsValue&&[defautsValue objectForKey:info.propertyName]) {
            [[NSUserDefaults standardUserDefaults] setObject:[defautsValue objectForKey:info.propertyName] forKey:property_key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:property_key];
        }
    }];
}

/**
 返回当前所有属性的keyvalues
 
 @return keyvalues字典
 */
- (NSDictionary *)gxh_fetchCurrentKeyValues{
    NSMutableDictionary * KeyValues = [[NSMutableDictionary alloc] init];
    [propertyInfoModels  enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        GXHPropertyInfoModel * info = obj;
        NSString * property_key = [self getKeyWithPropertyName:info.propertyName];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:property_key]) {
            [KeyValues setObject:[[NSUserDefaults standardUserDefaults] objectForKey:property_key] forKey:property_key];
        }
    }];
    return KeyValues;
}
/**
 清空所有值
 */
- (void)gxh_cleanAll{
    [propertyInfoModels  enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        GXHPropertyInfoModel * info = obj;
        NSString * property_key = [self getKeyWithPropertyName:info.propertyName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:property_key];
    }];
}
+ (id)fetchValueForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
- (void)getMethodEncodingTypesWithPropertyType:(char)type andInfoModel:(GXHPropertyInfoModel *)infoModel{
    NSString * headerString = [infoModel.propertyName substringWithRange:NSMakeRange(0, 1)];
    infoModel.setterMethodName = [NSString stringWithFormat:@"set%@:",[infoModel.propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[headerString uppercaseString]]];
    infoModel.getterMethodName = infoModel.propertyName;
    infoModel.setterTypes = [NSString stringWithFormat:@"v@:%c",type];
    infoModel.getterTypes = [NSString stringWithFormat:@"%c@:",type];
    switch (type) {
        case 'c':
        {
            // char
            infoModel.getterImp =  (IMP)gxh_charGetter;
            infoModel.setterImp =  (IMP)gxh_charSetter;
        }
            break;
        
        case 'i':
        {
            // int
            infoModel.getterImp =  (IMP)gxh_intGetter;
            infoModel.setterImp =  (IMP)gxh_intSetter;
        }
            break;
        case 's':
        {
            //short
            infoModel.getterImp =  (IMP)gxh_shortGetter;
            infoModel.setterImp =  (IMP)gxh_shortSetter;
        }
            break;
        case 'B':
        {
            //Bool
            infoModel.getterImp =  (IMP)gxh_boolGetter;
            infoModel.setterImp =  (IMP)gxh_boolSetter;
        }
            break;
        case 'l':
        {
            //long
            infoModel.getterImp =  (IMP)gxh_longGetter;
            infoModel.setterImp =  (IMP)gxh_longSetter;
        }
            break;
        case 'q':
        {
            //LongLong
            infoModel.getterImp =  (IMP)gxh_longLongGetter;
            infoModel.setterImp =  (IMP)gxh_longLongSetter;
        }
            break;
        case 'S':
        {
            //UnsignedShort
            infoModel.getterImp =  (IMP)gxh_unsignedShortGetter;
            infoModel.setterImp =  (IMP)gxh_unsignedShortSetter;
        }
            break;
        case 'C':
        {
            //UnsignedChar
            infoModel.getterImp =  (IMP)gxh_unsignedCharGetter;
            infoModel.setterImp =  (IMP)gxh_unsignedCharSetter;
        }
            break;
        case 'I':
        {
            //UnsignedInt
            infoModel.getterImp =  (IMP)gxh_integerGetter;
            infoModel.setterImp =  (IMP)gxh_integerSetter;
        }
            break;
        case 'L':
        {
            //UnsignedLong
            infoModel.getterImp =  (IMP)gxh_unsignedLongGetter;
            infoModel.setterImp =  (IMP)gxh_unsignedLongSetter;
        }
            break;
        case 'f':
        {
            //Float
            infoModel.getterImp =  (IMP)gxh_floatGetter;
            infoModel.setterImp =  (IMP)gxh_floatSetter;
        }
            break;
        case 'd':
        {
            //double
            infoModel.getterImp =  (IMP)gxh_doubleGetter;
            infoModel.setterImp =  (IMP)gxh_doubleSetter;
        }
            break;
        case '@':
        {
            //Object
            infoModel.getterImp =  (IMP)gxh_objectGetter;
            infoModel.setterImp =  (IMP)gxh_objectSetter;
            infoModel.isObject = YES;
        }
            break;
        default:
        {
            //Object
            infoModel.getterImp =  (IMP)gxh_objectGetter;
            infoModel.setterImp =  (IMP)gxh_objectSetter;
            infoModel.isObject = YES;
        }
            break;
    }
}
void gxh_unsignedShortSetter(GXHUserDefaults *self, SEL _cmd,unsigned short value) {
    
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithUnsignedShort:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}
unsigned short gxh_unsignedShortGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] unsignedShortValue];
}
void gxh_unsignedCharSetter(GXHUserDefaults *self, SEL _cmd,unsigned char value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithUnsignedChar:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}
unsigned char gxh_unsignedCharGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] unsignedCharValue];
}
void gxh_unsignedLongSetter(GXHUserDefaults *self, SEL _cmd, unsigned long value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithUnsignedLong:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}
unsigned long gxh_unsignedLongGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] unsignedLongValue];
}
void gxh_unsignedlongLongSetter(GXHUserDefaults *self, SEL _cmd, long long value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithLongLong:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}
long long gxh_unsignedLongLongGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] longLongValue];
}
void gxh_longLongSetter(GXHUserDefaults *self, SEL _cmd, long long value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithLongLong:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}
long long gxh_longLongGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] longLongValue];
}
void gxh_longSetter(GXHUserDefaults *self, SEL _cmd, long value) {
     NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithLong:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}
long gxh_longGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] longValue];
}

void gxh_shortSetter(GXHUserDefaults *self, SEL _cmd, short value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithShort:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}
short gxh_shortGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] shortValue];
}

void gxh_charSetter(GXHUserDefaults *self, SEL _cmd, char value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithChar:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}
char gxh_charGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] charValue];
}

bool gxh_boolGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] boolValue];
}

void gxh_boolSetter(GXHUserDefaults *self, SEL _cmd, bool value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithBool:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}

unsigned int gxh_integerGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] intValue];
}

void gxh_integerSetter(GXHUserDefaults *self, SEL _cmd, unsigned int value) {
     NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithInteger:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}

float gxh_floatGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] floatValue];
}

void gxh_floatSetter(GXHUserDefaults *self, SEL _cmd, float value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithFloat:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}

double gxh_doubleGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] doubleValue];
}

void gxh_doubleSetter(GXHUserDefaults *self, SEL _cmd, double value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    NSNumber *object = [NSNumber numberWithDouble:value];
    [currentUserDefaults setObject:object forKey:key];
    [currentUserDefaults synchronize];
}
int gxh_intGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [[currentUserDefaults objectForKey:key] intValue];
}

void gxh_intSetter(GXHUserDefaults *self, SEL _cmd, int value) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    [currentUserDefaults setObject:[NSNumber numberWithInt:value] forKey:key];
    [currentUserDefaults synchronize];
}
id gxh_objectGetter(GXHUserDefaults *self, SEL _cmd) {
    NSString *key  = [self getKeyWithSEL:_cmd];
    return [currentUserDefaults objectForKey:key];
}
void gxh_objectSetter(GXHUserDefaults *self, SEL _cmd, id object) {
    
    NSString *key  = [self getKeyWithSEL:_cmd];
    if (object) {
        [currentUserDefaults setObject:object forKey:key];
    } else {
        [currentUserDefaults removeObjectForKey:key];
    }
    [currentUserDefaults synchronize];
}
-  (NSString *)getKeyWithSEL:(SEL)cmd{
    NSString *key;
    GXHPropertyInfoModel * model = [propertyInfoModels objectForKey:NSStringFromSelector(cmd)];
    if ([self respondsToSelector:@selector(userPropertyPrefixWithPropertyName:)]) {
       key = [self performSelector:@selector(userPropertyPrefixWithPropertyName:) withObject:model.propertyName];
    }
    if (key == nil) {
        key = @"";
    }
    key  =  [key stringByAppendingString:model.propertyName];
    return key;
}
-  (NSString *)getKeyWithPropertyName:(NSString *)propertyName{
    NSString *key;
    GXHPropertyInfoModel * model = [propertyInfoModels objectForKey:propertyName];
    if ([self respondsToSelector:@selector(userPropertyPrefixWithPropertyName:)]) {
        key = [self performSelector:@selector(userPropertyPrefixWithPropertyName:) withObject:model.propertyName];
    }
    if (key == nil) {
        key = @"";
    }
    key  =  [key stringByAppendingString:model.propertyName];
    return key;
}
@end
