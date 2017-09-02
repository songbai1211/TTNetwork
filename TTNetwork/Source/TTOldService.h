//
//  TTOldService.h
//  TianTianWang
//
//  Created by yitailong on 16/7/8.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PINCache.h"

@interface TTOldService : NSObject



- (RACSignal *)rac_GetWithParams:(NSDictionary *)params  methodName:(NSString * )methodName;
- (RACSignal *)rac_PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName;
- (RACSignal *)rac_PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName needCache:(BOOL)needCache;

// 缓存管理
+ (PINCache *)cacheManager;

@end
