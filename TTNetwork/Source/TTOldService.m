//
//  TTOldService.m
//  TianTianWang
//
//  Created by yitailong on 16/7/8.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import "TTOldService.h"
#import "TTHTTPClient.h"
#import "TTAPIBaseModel.h"
#import "TTAPIParamsGenerator.h"
#import "PINCache+RACSignalSupport.h"

static NSString *const TTOldServiceErrorDomain = @"TTOldServiceErrorDomain";

@interface TTOldService ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSURLSessionDataTask*> *tasks;

@end

@implementation TTOldService

- (NSNumber *)PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName success:(void(^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure
{

    NSURLSessionDataTask *dataTask = [[TTHTTPClient shareClient] PostWithParams:params methodName:methodName success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
       
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            TTAPIBaseModel *baseModel = [[TTAPIBaseModel alloc] initWithDictionary:responseObject error:nil];
            if (baseModel.responseMsg.returnCode.integerValue == TTNetWorkStateOK) {
                success(responseObject);
            }
            else{
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: baseModel.responseMsg.message};
                NSError *error = [NSError errorWithDomain:TTOldServiceErrorDomain code:baseModel.responseMsg.returnCode.integerValue userInfo:userInfo];
                failure(error);
            }
        }
       
       [self.tasks removeObjectForKey:@(task.taskIdentifier)];
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        failure(error);
        [self.tasks removeObjectForKey:@(task.taskIdentifier)];
    }];
    
    if (dataTask) {
        [self.tasks setObject:dataTask forKey:@(dataTask.taskIdentifier)];
    }
    
    return @(dataTask.taskIdentifier);
}

- (RACSignal *)rac_PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       NSURLSessionDataTask *dataTask = [[TTHTTPClient shareClient] PostWithParams:params methodName:methodName success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
           
           if ([responseObject isKindOfClass:[NSDictionary class]]) {
               TTAPIBaseModel *baseModel = [[TTAPIBaseModel alloc] initWithDictionary:responseObject error:nil];
               if (baseModel.responseMsg.returnCode.integerValue == TTNetWorkStateOK) {
                   [subscriber sendNext:responseObject];
                   [subscriber sendCompleted];
               }
               else{
                   NSDictionary *userInfo = @{NSLocalizedDescriptionKey: baseModel.responseMsg.message};
                   NSError *error = [NSError errorWithDomain:TTOldServiceErrorDomain code:baseModel.responseMsg.returnCode.integerValue userInfo:userInfo];
                   [subscriber sendError:error];
               }
           }

           
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
           [subscriber sendError:error];
       }];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] catch:^RACSignal *(NSError *error) {
        if (error.code == NSURLErrorCancelled) {
            return [RACSignal empty];
        }
        return [RACSignal error:error];
    }];;
}

- (RACSignal *)rac_PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName needCache:(BOOL)needCache
{
    if (!needCache) {
        return [self rac_PostWithParams:params methodName:methodName];
    }
    
    NSString *cacheKey = [TTAPIParamsGenerator cacheKeyGenerator:params methodName:methodName];
    
    RACSignal *cacheSignal = [[[TTOldService cacheManager] cacheObjectForKey:cacheKey] catchTo:[RACSignal empty]];

    RACSignal *remoteSignal = [[self rac_PostWithParams:params methodName:methodName] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        if (value) {
            [[TTOldService cacheManager]  setObject:value forKey:cacheKey block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
                
            }];
        }
        return [RACSignal return:value];
    }];
    
    return [RACSignal merge:@[[cacheSignal takeUntil:remoteSignal], remoteSignal]];
}

- (void)cancelAllTasks
{
    for (NSURLSessionDataTask *task in self.tasks) {
        [task cancel];
        [self.tasks removeObjectForKey:@(task.taskIdentifier)];
    }
}

#pragma mark -- Setter && Getter
- (NSMutableDictionary *)tasks
{
    if (!_tasks) {
        _tasks = [@{} mutableCopy];
    }
    return _tasks;
}

+ (PINCache *)cacheManager
{
    static PINCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[PINCache alloc] initWithName:@"TTNetworkCahces"];
        cache.memoryCache.costLimit = 4*1024*1024; // 4MB
        cache.diskCache.byteLimit = 32*1024*1024; // 32MB
        cache.diskCache.ageLimit = 60*60*24*7;
    });
    return cache;
}

@end
