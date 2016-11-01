//
//  TTOldService.h
//  TianTianWang
//
//  Created by yitailong on 16/7/8.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import <PINCache.h>

@interface TTOldService : NSObject

- (NSNumber *)PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName success:(void(^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;

- (RACSignal *)rac_PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName;
- (RACSignal *)rac_PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName needCache:(BOOL)needCache;

- (void)cancelAllTasks;

// 缓存管理
+ (PINCache *)cacheManager;

@end
