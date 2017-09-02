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
- (RACSignal *)rac_GetWithParams:(NSDictionary *)params  methodName:(NSString * )methodName needCache:(BOOL)needCache;
- (RACSignal *)rac_PostWithParams:(NSDictionary *)params  methodName:(NSString * )methodName;
- (RACSignal *)rac_HeadWithParams:(NSDictionary *)params  methodName:(NSString * )methodName;
- (RACSignal *)rac_DeleteWithParams:(NSDictionary *)params  methodName:(NSString * )methodName;
- (RACSignal *)rac_PutWithParams:(NSDictionary *)params  methodName:(NSString * )methodName;
- (RACSignal *)rac_PatchWithParams:(NSDictionary *)params  methodName:(NSString * )methodName;

- (RACSignal *)uploadJPEGImgae:(UIImage *)image methodName:(NSString *)methodName;
- (RACSignal *)uploadJPEGImgae:(UIImage *)image quality:(CGFloat)quality methodName:(NSString *)methodName;
- (RACSignal *)uploadPNGImgae:(UIImage *)image methodName:(NSString *)methodName;

// 缓存管理
+ (PINCache *)cacheManager;

@end
