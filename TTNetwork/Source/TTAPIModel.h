//
//  TTAPIModel.h
//  TianTianWang
//
//  Created by yitailong on 16/5/10.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import <JSONModel/JSONModel.h>

typedef NS_ENUM(NSInteger, TTNetWorkState){
    TTNetWorkStateOK = 0,         //正常
};


@protocol TTAPIModel

@end

@interface TTAPIModel : JSONModel

/**
 *  状态值
 */
@property (nonatomic, copy) NSString *returnCode;

/**
 *  错误信息
 */
@property (nonatomic, copy) NSString *message;



@end



