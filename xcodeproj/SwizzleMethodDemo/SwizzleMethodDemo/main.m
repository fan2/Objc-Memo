//
//  main.m
//  SwizzleMethodDemo
//
//  Created by faner on 16Oct20.
//  Copyright © 2020年 zimushan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Swizzle.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        [NSObject swizzleCluster];
        
        NSString *testString = @"NSString+Safe Swizzle";
        __unused NSString *subStrFrom = [testString substringFromIndex:100];
        __unused NSString *subStrTo = [testString substringToIndex:100];
        const char *cstr = NULL;
        __unused NSString *utf8Str = [NSString stringWithUTF8String:cstr];

        NSArray *testArray = @[@"1980", @"2020", @"40"];
        __unused NSString *interval = [testArray objectAtIndex:3];
        // 以下标访问 testArray[3]，将抛异常 NSRangeException, -[__NSArrayI objectAtIndexedSubscript:]: index 3 beyond bounds
    }
    return 0;
}
