//
//  TTHTTPClient.m
//  TianTianWang
//
//  Created by yitailong on 16/7/6.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import "TTHTTPClient.h"
#import "ReactiveCocoa.h"
#import "TTAPIParamsGenerator.h"
#import "TTAPIURL.h"

@interface TTHTTPClient ()

@property (nonatomic, assign) NSInteger activityCount;
@property (nonatomic, strong) NSCache *sessionManagerCache;

@end

@implementation TTHTTPClient

+ (instancetype)shareClient
{
    static TTHTTPClient *httpClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpClient = [[self alloc] init];
    });
    
    return httpClient;
}

- (instancetype)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:YXBaseURL]];
    if (self) {
        [RACObserve(self, activityCount) subscribeNext:^(NSNumber *activityCount) {
            if (activityCount.integerValue>0) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
            else{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
        }];
    }
    return self;
}

- (nullable NSURLSessionDataTask *)PostWithParams:(nullable NSDictionary *)params  methodName:(nullable  NSString * )methodName success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
{
    NSDictionary *encryptedPara = [TTAPIParamsGenerator paramsDictionaryGenerator:params methodName:methodName];
    
    @synchronized(self){
        self.activityCount++;
    }
    
    NSURLSessionDataTask *dataTask = [self POST:methodName parameters:encryptedPara progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        @synchronized(self) {
            self.activityCount = MAX(_activityCount - 1, 0);
        }
        
        success?success(task, responseObject):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        @synchronized(self) {
            self.activityCount = MAX(_activityCount - 1, 0);
        }
        
        failure?failure(task, error):nil;
    }];
    return dataTask;
}

#pragma mark --  Setter && Getter
- (NSCache *)sessionManagerCache {
    if (!_sessionManagerCache) {
        _sessionManagerCache = [[NSCache alloc] init];
    }
    return _sessionManagerCache;
}

@end
