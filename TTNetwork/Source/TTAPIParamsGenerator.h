//
//  TTAPIParamsGenerator.h
//  天天网
//
//  Created by yitailong on 16/4/27.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTAPIParamsGenerator : NSObject

+ (NSDictionary *)commonParamsDictionary;
+ (NSDictionary *)paramsDictionaryGenerator:(NSDictionary *)params methodName:(NSString *)methodName;
+ (NSString *)cacheKeyGenerator:(NSDictionary *)params methodName:(NSString *)methodName;


@end
