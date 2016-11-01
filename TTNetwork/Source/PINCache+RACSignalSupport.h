//
//  PINCache+RACSignalSupport.h
//  TianTianWang
//
//  Created by yitailong on 16/10/31.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import <PINCache/PINCache.h>
#import "ReactiveCocoa.h"

extern NSString *const TTNetworkCahcesErrorDomain ;


@interface PINCache (RACSignalSupport)

- (RACSignal *)cacheObjectForKey:(NSString *)key;

@end
