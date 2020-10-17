//
//  NSString+Safe.m
//  SwizzleMethodDemo
//
//  Created by faner on 16Oct20.
//  Copyright © 2020年 zimushan. All rights reserved.
//

#import "NSString+Safe.h"

@implementation NSString (Safe)

+ (nullable instancetype)stringWithUTF8StringSafely:(nullable const char *)cString {
    if (cString == NULL) {
        NSLog(@"NSString" " stringWithUTF8String: NULL");
        return [NSString string];
    }

    return [self stringWithUTF8StringSafely:cString]; // swizzled as SEL(stringWithUTF8String:) IMP in runtime
}

- (nullable NSString *)substringFromIndexSafely:(NSUInteger)from {
    if (from > [self length]) {
        NSLog(@"NSString" " substringFromIndex: outOfIndex %tu > %tu", from, [self length]);
        return nil;
    }

    return [self substringFromIndexSafely:from]; // swizzled as SEL(substringFromIndex:) IMP in runtime
}

- (nullable NSString *)substringToIndexSafely:(NSUInteger)to {
    if (to > [self length]) {
        NSLog(@"NSString" " substringToIndex: outOfIndex %tu > %tu", to, [self length]);
        return nil;
    }

    return [self substringToIndexSafely:to]; // swizzled as SEL(substringToIndex:) IMP in runtime
}

@end
