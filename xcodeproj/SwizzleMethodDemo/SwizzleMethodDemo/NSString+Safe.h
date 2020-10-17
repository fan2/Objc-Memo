//
//  NSString+Safe.h
//  SwizzleMethodDemo
//
//  Created by faner on 16Oct20.
//  Copyright © 2020年 zimushan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Safe)

+ (nullable instancetype)stringWithUTF8StringSafely:(nullable const char *)cString;

- (nullable NSString *)substringFromIndexSafely:(NSUInteger)from;
- (nullable NSString *)substringToIndexSafely:(NSUInteger)to;

@end
