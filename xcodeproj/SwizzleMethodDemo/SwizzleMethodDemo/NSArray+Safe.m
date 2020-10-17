//
//  NSArray+Safe.m
//  SwizzleMethodDemo
//
//  Created by faner on 16Oct20.
//  Copyright © 2020年 zimushan. All rights reserved.
//

#import "NSArray+Safe.h"

@implementation NSArray (Safe)

- (id)objectAtIndexSafely:(NSUInteger)index {
    if (index >= [self count]) {
        NSLog(@"NSArray" " objectAtIndex: outOfIndex %tu >= %tu", index, [self count]);
        return nil;
    }

    return [self objectAtIndexSafely:index]; // swizzled as SEL(objectAtIndex:) IMP in runtime
}

- (id)objectAtIndexSafely0:(NSUInteger)index {
    if (index >= [self count]) {
        NSLog(@"NSArray0" " objectAtIndex: outOfIndex %tu >= %tu", index, [self count]);
        return nil;
    }

    return [self objectAtIndexSafely0:index]; // swizzled as SEL(objectAtIndex:) IMP in runtime
}

- (id)objectAtIndexSafelyI:(NSUInteger)index {
    if (index >= [self count]) {
        NSLog(@"NSArrayI" " objectAtIndex: outOfIndex %tu >= %tu", index, [self count]);
        return nil;
    }

    return [self objectAtIndexSafelyI:index]; // swizzled as SEL(objectAtIndex:) IMP in runtime
}

@end
