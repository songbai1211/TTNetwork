//
//  TTBaseViewModel.h
//  TianTianWang
//
//  Created by yitailong on 16/7/10.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

extern NSString const *TTRequsetPageSize;
extern NSString const *TTRequsetPageIndex;


@interface TTBaseViewModel : NSObject

@property (nonatomic, strong, readonly) RACSubject *errors;

- (void)setUpCommand;
- (void)setUpSubscribe;

@end
