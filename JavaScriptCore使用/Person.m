//
//  Person.m
//  JavaScriptCore使用
//
//  Created by archerLj on 15/11/20.
//  Copyright © 2015年 archerLj. All rights reserved.
//

#import "Person.h"
#import <UIKit/UIKit.h>

@implementation Person
@synthesize firstName, lastName, urls;

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (void)doFoo:(id)foo withBar:(id)bar {
    
    NSString *stringKK = [NSString stringWithFormat:@"%@%@",foo,bar];
    NSLog(@"%@",stringKK);
}
@end
