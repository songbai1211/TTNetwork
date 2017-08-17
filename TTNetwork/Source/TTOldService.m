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

@property (nonatomic, copy) void (^ttServiceSuccessHanlder)(id<RACSubscriber> subscriber, id responseObject);
@property (nonatomic, copy) void (^ttServiceFailureHanlder)(id<RACSubscriber> subscriber, NSError *error);

@end

@implementation TTOldService

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ttServiceSuccessHanlder = ^(id<RACSubscriber> subscriber, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                TTAPIBaseModel *baseModel = [[TTAPIBaseModel alloc] initWithDictionary:responseObject error:nil];
                if (baseModel.status.code.integerValue == TTNetWorkStateOK) {
                    [subscriber sendNext:responseObject];
                    [subscriber sendCompleted];
                }
                else{
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: baseModel.status.message};
                    NSError *error = [NSError errorWithDomain:TTOldServiceErrorDomain code:baseModel.status.code.integerValue userInfo:userInfo];
                    [subscriber sendError:error];
                }
            }
        };
        
        self.ttServiceFailureHanlder = ^(id<RACSubscriber> subscriber, NSError *error) {
            [subscriber sendError:error];
        };
    }
    return self;
}

- (RACSignal *)rac_GetWithParams:(NSDictionary *)params  methodName:(NSString * )methodName
{
    return [self RequsetHttpType:TTHTTPMethodGET params:params methodName:methodName];
}

- (RACSignal *)rac_PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName
{
    return [self RequsetHttpType:TTHTTPMethodPOST params:params methodName:methodName];
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

- (RACSignal *)RequsetHttpType:(TTHTTPMethodType)httpType params:(NSDictionary *)params  methodName:(NSString * )methodName
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [[TTHTTPClient shareClient] RequsetHttpType:httpType params:params methodName:methodName success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
            if (self.ttServiceSuccessHanlder) {
                self.ttServiceSuccessHanlder(subscriber, responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
            if (self.ttServiceFailureHanlder) {
                self.ttServiceFailureHanlder(subscriber, error);
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] catch:^RACSignal *(NSError *error) {
        if (error.code == NSURLErrorCancelled) {
            return [RACSignal empty];
        }
        return [RACSignal error:error];
    }];
}


#pragma mark -- Setter && Getter
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
