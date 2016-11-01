//
//  PINCache+RACSignalSupport.m
//  TianTianWang
//
//  Created by yitailong on 16/10/31.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import "PINCache+RACSignalSupport.h"

NSString *const  TTNetworkCahcesErrorDomain = @"TTNetworkCahcesErrorDomain";


@implementation PINCache (RACSignalSupport)

- (RACSignal *)cacheObjectForKey:(NSString *)key
{
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self)
        
             [self objectForKey:key block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
         
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (object) {
                        [subscriber sendNext:object];
                        [subscriber sendCompleted];
                    } else {
                        
                        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"没有缓存"};
                        NSError *error = [NSError errorWithDomain:@"TTNetworkCahces" code:0 userInfo:userInfo];
                        [subscriber sendError:error];
                    }
                });
                 
             }];
        
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
}

@end
