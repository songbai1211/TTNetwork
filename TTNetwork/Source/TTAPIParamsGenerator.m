//
//  TTAPIParamsGenerator.m
//  天天网
//
//  Created by yitailong on 16/4/27.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import "TTAPIParamsGenerator.h"
#import "UIDevice+TTKit.h"


@implementation TTAPIParamsGenerator

+ (NSDictionary *)commonParamsDictionary
{

    return @{};
}

+ (NSDictionary *)paramsDictionaryGenerator:(NSDictionary *)params methodName:(NSString *)methodName
{
    NSMutableDictionary *paramsDic = [[TTAPIParamsGenerator commonParamsDictionary] mutableCopy];
    
    
    return paramsDic;
}

@end