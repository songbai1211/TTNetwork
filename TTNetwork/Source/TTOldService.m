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
#import <AFNetworking/AFNetworking.h>

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
                
                TTAPIBaseModel *baseModel = [TTAPIBaseModel yy_modelWithDictionary:responseObject];
                
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

- (RACSignal *)rac_GetWithParams:(NSDictionary *)params  methodName:(NSString * )methodName needCache:(BOOL)needCache
{
    if (!needCache) {
        return [self rac_GetWithParams:params methodName:methodName];
    }
    
    NSString *cacheKey = [TTAPIParamsGenerator cacheKeyGenerator:params methodName:methodName];
    
    RACSignal *cacheSignal = [[[TTOldService cacheManager] cacheObjectForKey:cacheKey] catchTo:[RACSignal empty]];
    
    RACSignal *remoteSignal = [[self rac_GetWithParams:params methodName:methodName] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        if (value) {
            [[TTOldService cacheManager]  setObject:value forKey:cacheKey block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
                
            }];
        }
        return [RACSignal return:value];
    }];
    
    return [RACSignal merge:@[[cacheSignal takeUntil:remoteSignal], remoteSignal]];
}

- (RACSignal *)rac_PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName
{
    return [self RequsetHttpType:TTHTTPMethodPOST params:params methodName:methodName];
}

- (RACSignal *)rac_HeadWithParams:(NSDictionary *)params  methodName:(NSString * )methodName
{
    return [self RequsetHttpType:TTHTTPMethodHEAD params:params methodName:methodName];

}

- (RACSignal *)rac_DeleteWithParams:(NSDictionary *)params  methodName:(NSString * )methodName
{
    return [self RequsetHttpType:TTHTTPMethodDELETE params:params methodName:methodName];
}

- (RACSignal *)rac_PutWithParams:(NSDictionary *)params  methodName:(NSString * )methodName
{
    return [self RequsetHttpType:TTHTTPMethodPUT params:params methodName:methodName];

}


- (RACSignal *)rac_PatchWithParams:(NSDictionary *)params  methodName:(NSString * )methodName
{
    return [self RequsetHttpType:TTHTTPMethodPATCH params:params methodName:methodName];
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

- (RACSignal *)uploadJPEGImgae:(UIImage *)image methodName:(NSString *)methodName
{
    return [self uploadJPEGImgae:image quality:0.7 methodName:methodName];
}

- (RACSignal *)uploadJPEGImgae:(UIImage *)image quality:(CGFloat)quality methodName:(NSString *)methodName
{
    return [[self rac_PostFileWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imgData = UIImageJPEGRepresentation(image, quality);
        [formData appendPartWithFileData:imgData name:@"file" fileName:@"file.jpeg" mimeType:@"image/jpeg"];
    } methodName:methodName] map:^id _Nullable(id  _Nullable value) {
        NSDictionary *body = value[@"body"];
        return body[@"url"];
    }];
}

- (RACSignal *)uploadPNGImgae:(UIImage *)image methodName:(NSString *)methodName
{
    return [[self rac_PostFileWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imgData = UIImagePNGRepresentation(image);
        [formData appendPartWithFileData:imgData name:@"file" fileName:@"file.png" mimeType:@"image/png"];
    } methodName:methodName] map:^id _Nullable(id  _Nullable value) {
        NSDictionary *body = value[@"body"];
        return body[@"url"];
    }];
}

- (RACSignal *)rac_PostFileWithBlock:(void (^)(id <AFMultipartFormData> formData))block methodName:(NSString * )methodName
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [[TTHTTPClient shareClient] RequsetFilePOST:methodName parameters:@{} constructingBodyWithBlock:block progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            if (self.ttServiceSuccessHanlder) {
                self.ttServiceSuccessHanlder(subscriber, responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (self.ttServiceFailureHanlder) {
                self.ttServiceFailureHanlder(subscriber, error);
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
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

- (void)dealloc
{
    NSLog(@"dealloc --- Service %@", NSStringFromClass([self class]));
}

@end
