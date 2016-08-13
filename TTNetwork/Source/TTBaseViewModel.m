//
//  TTBaseViewModel.m
//  TianTianWang
//
//  Created by yitailong on 16/7/10.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import "TTBaseViewModel.h"

 NSString const *TTRequsetPageSize = @"TTRequsetPageSize";
 NSString const *TTRequsetPageIndex = @"TTRequsetPageIndex";

@interface TTBaseViewModel ()

@property (nonatomic, strong, readwrite) RACSubject *errors;


@end


@implementation TTBaseViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpCommand];
        [self setUpSubscribe];
    }
    return self;
}

- (void)setUpCommand
{
    
}

- (void)setUpSubscribe
{
    
}

- (RACSubject *)errors
{
    if (!_errors) {
        _errors = [RACSubject subject];
    }
    
    return _errors;
}

@end
