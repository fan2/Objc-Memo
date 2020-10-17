//
//  NSArray+Safe.h
//  SwizzleMethodDemo
//
//  Created by faner on 16Oct20.
//  Copyright © 2020年 zimushan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Safe)

- (id)objectAtIndexSafely:(NSUInteger)index;
- (id)objectAtIndexSafely0:(NSUInteger)index;
- (id)objectAtIndexSafelyI:(NSUInteger)index;

@end
