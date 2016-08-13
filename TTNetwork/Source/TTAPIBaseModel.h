//
//  TTAPIBaseModel.h
//  TianTianWang
//
//  Created by yitailong on 16/5/19.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "TTAPIModel.h"

@interface TTAPIBaseModel : JSONModel

@property (nonatomic, copy) TTAPIModel *responseMsg;

@end
