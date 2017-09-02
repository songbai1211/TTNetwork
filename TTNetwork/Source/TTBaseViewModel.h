//
//  TTBaseViewModel.h
//  TianTianWang
//
//  Created by yitailong on 16/7/10.
//  Copyright © 2016年 oyxc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TTBaseViewModel : NSObject

@property (nonatomic, strong, readonly) RACSubject *errors;

- (void)setUpCommand;
- (void)setUpSubscribe;

@end
