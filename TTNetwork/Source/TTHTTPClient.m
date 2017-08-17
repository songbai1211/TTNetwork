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
@property (nonatomic, strong) NSArray *listOfHttpType;

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
    self = [super initWithBaseURL:[NSURL URLWithString:NHCBaseURL]];
    if (self) {
        [RACObserve(self, activityCount) subscribeNext:^(NSNumber *activityCount) {
            if (activityCount.integerValue>0) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
            else{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
        }];
        
        self.listOfHttpType =  @[@"GET", @"POST", @"HEAD", @"DELETE", @"PUT", @"PATCH"];
    }
    return self;
}


- (nullable NSURLSessionDataTask *)RequsetHttpType:(TTHTTPMethodType)httpType params:(nullable NSDictionary *)params  methodName:(nullable  NSString * )methodName success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
{
    NSString *httpTypeMethod = nil;
    
    if (httpType >= 0 && httpType < self.listOfHttpType.count) {
        httpTypeMethod = self.listOfHttpType[httpType];
    }
    NSAssert(httpTypeMethod.length > 0, @"The HTTP method not found.");

    NSDictionary *encryptedPara = [TTAPIParamsGenerator paramsDictionaryGenerator:params methodName:methodName];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:httpTypeMethod URLString:[[NSURL URLWithString:methodName relativeToURL:self.baseURL] absoluteString] parameters:encryptedPara error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    NSDictionary *headers =  [TTAPIParamsGenerator commonHeaderDictionary];
    if (headers.count > 0) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [request setValue:value forHTTPHeaderField:field];
        }];
    }
    
    @synchronized(self){
        self.activityCount++;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        @synchronized(self) {
            self.activityCount = MAX(_activityCount - 1, 0);
        }
        
       if (error) {
           if (failure) {
               failure(dataTask, error);
           }
       } else {
           if (success) {
               success(dataTask, responseObject);
           }
       }

   }];
    [dataTask resume];
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
