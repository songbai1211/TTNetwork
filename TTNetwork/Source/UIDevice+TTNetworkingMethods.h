//
//  UIDevice+TTNetworkingMethods.h
//  NewDoctor
//
//  Created by localadmin on 2017/8/17.
//  Copyright © 2017年 ytl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (TTNetworkingMethods)

+ (NSString *)tt_appversion;

+ (NSString *)tt_uuid;

+ (NSString *)tt_platform;

+ (NSString *)tt_platformString;

+ (NSString *)tt_ostype;//显示“iOS6，iOS5”，只显示大版本号


@end
