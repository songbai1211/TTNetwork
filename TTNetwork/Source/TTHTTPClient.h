//
//  TTHTTPClient.h
//  TianTianWang
//
//  Created by yitailong on 16/7/6.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>


typedef NS_ENUM(NSInteger, TTHTTPMethodType) {
    TTHTTPMethodGET    = 0,    //!< GET
    TTHTTPMethodPOST   = 1,    //!< POST
    TTHTTPMethodHEAD   = 2,    //!< HEAD
    TTHTTPMethodDELETE = 3,    //!< DELETE
    TTHTTPMethodPUT    = 4,    //!< PUT
    TTHTTPMethodPATCH  = 5,    //!< PATCH
};

@interface TTHTTPClient : AFHTTPSessionManager

+ (nonnull instancetype)shareClient;

- (nullable NSURLSessionDataTask *)RequsetHttpType:(TTHTTPMethodType)httpType params:(nullable NSDictionary *)params  methodName:(nullable  NSString * )methodName success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

@end
