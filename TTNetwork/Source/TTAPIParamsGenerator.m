//
//  TTAPIParamsGenerator.m
//  天天网
//
//  Created by yitailong on 16/4/27.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import "TTAPIParamsGenerator.h"


@implementation TTAPIParamsGenerator

+ (NSDictionary *)commonHeaderDictionary
{
    return @{@"clientType": @"iOS",
             @"appVersion": @"1",
             @"mobileId" : @"1",
             @"deviceName" : @"1"
             };
}

+ (NSDictionary *)commonParamsDictionary
{

    return @{};
}

+ (NSDictionary *)paramsDictionaryGenerator:(NSDictionary *)params methodName:(NSString *)methodName
{
    NSMutableDictionary *paramsDic = [[TTAPIParamsGenerator commonParamsDictionary] mutableCopy];
    [paramsDic addEntriesFromDictionary:params];
    
    return paramsDic;
}

+ (NSString *)cacheKeyGenerator:(NSDictionary *)params methodName:(NSString *)methodName
{
    return @"";
}

@end
