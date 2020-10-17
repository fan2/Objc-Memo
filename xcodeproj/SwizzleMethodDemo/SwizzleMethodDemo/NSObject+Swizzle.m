//
//  NSObject+Swizzle.m
//  SwizzleMethodDemo
//
//  Created by faner on 16Oct20.
//  Copyright © 2020年 zimushan. All rights reserved.
//

#import "NSObject+Swizzle.h"
#import "objc/runtime.h"

@implementation NSObject (SwizzleCategory)

#pragma mark - swizzleMethod

/**
 替换当前类的实例方法
 */
+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel
{
    Method originMethod = class_getInstanceMethod(self, origSel);
    Method newMethod = class_getInstanceMethod(self, altSel);

    if (originMethod && newMethod) {
        if (class_addMethod(self, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            // 添加 MethodList[origSel] = newMethod，然后再设置 MethodList[altSel] = originMethod
            class_replaceMethod(self, altSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        } else {
            // 添加失败：可能已有该 SEL-IMP 映射，直接交换实现？
            method_exchangeImplementations(originMethod, newMethod);
        }
        return YES;
    }
    return NO;
}

/**
 替换当前实例所属类的实例方法
 */
+ (BOOL)swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel
{
    Class metaCls = object_getClass((id)self); // internal type???
    return [metaCls swizzleMethod:origSel withMethod:altSel];
}

/**
 替换指定类的实例方法
 oriSel-fromMethod: 一般为当前类或超类的实例方法
 altSel-toMethod: 一般为用户在当前类别实现的新实例方法
 */
+ (void)swizzleMethod:(SEL)oriSel withMethod:(SEL)altSel fromClass:(Class)cls {
    if (!oriSel || !altSel || !cls) {
        return;
    }

    NSLog(@"swizzleMethod %s with %s fromClass %s", [NSStringFromSelector(oriSel) UTF8String],
          [NSStringFromSelector(altSel) UTF8String], [NSStringFromClass(cls) UTF8String]);
    
    Method fromMethod = class_getInstanceMethod(cls, oriSel);
    Method toMethod = class_getInstanceMethod(cls, altSel);
    
    if (fromMethod && toMethod) {
        BOOL fromFound = NO;
        BOOL toFound = NO;
        
        while (!fromFound) {
            unsigned int count = 0;

            Method * method = class_copyMethodList(cls, &count); // 拷贝当前类的方法列表
            Method * methodList = method; // 保存指针，以便释放

            if (method == NULL || count == 0) { // 方法列表为空
                cls = class_getSuperclass(cls); // iter super
            } else {
                unsigned int index = count;
                while (index > 0) {
                    index--;
                    if (*method == toMethod) {
                        toFound = YES;
                    }
                    if (*method == fromMethod) {
                        fromFound = YES;
                    }
                    method = method + 1; // iter next
                }
                free(methodList); // 释放本轮拷贝轮询的方法列表
                
                if (!fromFound) { // 源 IMP 未找到
                    toFound = NO;
                    cls = class_getSuperclass(cls); // iter super
                }
            }
        } // while loop

        if (fromFound) {
            if (toFound) { // 源方法和新方法都已找到，则交换实现
                method_exchangeImplementations(fromMethod, toMethod);
            } else { // 源方法已找到，但新方法尚未找到，则先添加
                if (class_addMethod(cls, oriSel, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
                    class_replaceMethod(cls, altSel, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod));
                } else {
                    method_exchangeImplementations(fromMethod, toMethod);
                }
            }
        } // WTF！？
    }
}

/**
 同 +[NSObject swizzleClassMethod:withClassMethod:] ？
 */
+ (void)swizzleMethod:(SEL)oriSel withMethod:(SEL)altSel inClass:(Class)cls{
    if (!oriSel || !altSel || !cls) {
        return;
    }
    
    NSLog(@"swizzleMethod %s with %s inClass %s", [NSStringFromSelector(oriSel) UTF8String],
          [NSStringFromSelector(altSel) UTF8String], [NSStringFromClass(cls) UTF8String]);
    
    Method fromMethod = class_getInstanceMethod(cls, oriSel);
    Method toMethod = class_getInstanceMethod(cls, altSel);
    
    if (fromMethod && toMethod) {
        if (class_addMethod(cls, oriSel, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
            class_replaceMethod(cls, altSel, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod));
        } else {
            method_exchangeImplementations(fromMethod, toMethod);
        }
        
    }
}

#pragma mark -| swizzleClassMethod

/**
 替换指定类的静态方法
 */
+(void)swizzleClassMethod:(SEL)oriSel withMethod:(SEL)altSel inClass:(Class)cls {
    if (!oriSel || !altSel || !cls) {
        return;
    }

    NSLog(@"swizzleClassMethod %s with %s inClass %s", [NSStringFromSelector(oriSel) UTF8String],
          [NSStringFromSelector(altSel) UTF8String],[NSStringFromClass(cls) UTF8String]);

    Method fromMethod = class_getClassMethod(cls, oriSel);
    Method toMethod = class_getClassMethod(cls, altSel);
    
    Class metaCls = object_getClass((id)cls);
    
    if (fromMethod && toMethod) {
        if (class_addMethod(metaCls, oriSel, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
            class_replaceMethod(metaCls, altSel, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod));
        } else {
            method_exchangeImplementations(fromMethod, toMethod);
        }
    }
}

/**
 替换指定类的静态方法
 oriSel-fromMethod: 一般为当前类或超类的静态方法
 altSel-toMethod: 一般为用户在当前类别实现的新静态方法
 */
// 基本实现逻辑同 +swizzleMethod:withMethod:fromClass:，只是 class_getInstanceMethod 换成了 class_getClassMethod
+(void)swizzleClassMethod:(SEL) oriSel withMethod:(SEL)altSel fromClass:(Class)cls {
    if (!oriSel || !altSel || !cls) {
        return;
    }
    
    NSLog(@"swizzleClassMethod %s with %s fromClass %s", [NSStringFromSelector(oriSel) UTF8String],
          [NSStringFromSelector(altSel) UTF8String],[NSStringFromClass(cls) UTF8String]);
    
    Method fromMethod = class_getClassMethod(cls, oriSel);
    Method toMethod = class_getClassMethod(cls, altSel);
    
    Class metaCls = object_getClass((id)cls);
    
    if (fromMethod && toMethod) {
        BOOL fromFound = NO;
        BOOL toFound = NO;
        
        while (!fromFound) {
            unsigned int count = 0;
            
            Method * method = class_copyMethodList(metaCls, &count); // 拷贝当前类的方法列表
            Method * methodList = method; // 保存指针，以便释放
            
            if (method == NULL || count == 0) { // 方法列表为空
                metaCls = class_getSuperclass(metaCls); // iter super
            } else {
                unsigned int index = count;
                while (index > 0) {
                    index--;
                    if (*method == toMethod) {
                        toFound = YES;
                    }
                    if (*method == fromMethod) {
                        fromFound = YES;
                    }
                    method = method + 1; // iter next
                }
                free(methodList); // 释放本轮拷贝轮询的方法列表
                
                if (!fromFound) { // 源 IMP 未找到
                    toFound = NO;
                    metaCls = class_getSuperclass(metaCls);
                }
            }
        } // while loop
        
        if (fromFound) {
            if (toFound) { // 源方法和新方法都已找到，则交换实现
                method_exchangeImplementations(fromMethod, toMethod);
            } else { // 源方法已找到，但新方法尚未找到，则先添加
                if (class_addMethod(metaCls, oriSel, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
                    class_replaceMethod(metaCls, altSel, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod));
                } else {
                    method_exchangeImplementations(fromMethod, toMethod);
                }
            }
        } // WTF！？
    }
}

#pragma mark - swizzleCluster

+ (void)swizzleString {
    NSLog(@"swizzleString begin");

    const char *cstr = "utf 8 chars";
    NSString *utf8 = [NSString stringWithUTF8String:cstr];
    Class utf8Cls = [utf8 class];
    [self swizzleClassMethod:@selector(stringWithUTF8String:) withMethod:NSSelectorFromString(@"stringWithUTF8StringSafely:") fromClass:utf8Cls];

//    NSString *str = [NSString stringWithCString:cstr encoding:NSUTF8StringEncoding];
//    Class cutf8Cls = [str class];
//    [self swizzleClassMethod:@selector(stringWithCString:encoding:) withMethod:NSSelectorFromString(@"stringWithCStringSafely:encoding:") fromClass:cutf8Cls];

    id ocStr = [[NSString alloc] init];
    Class ocStrCls = [ocStr class];
    [self swizzleMethod:@selector(substringFromIndex:) withMethod:NSSelectorFromString(@"substringFromIndexSafely:") fromClass:ocStrCls];
    [self swizzleMethod:@selector(substringToIndex:) withMethod:NSSelectorFromString(@"substringToIndexSafely:") fromClass:ocStrCls];
    [self swizzleMethod:@selector(getCharacters:range:) withMethod:NSSelectorFromString(@"getCharactersSafely:range:") fromClass:ocStrCls];

    NSLog(@"swizzleString end");
}

+ (void)swizzleArray {
    NSLog(@"swizzleArray begin");

    NSArray *array = [NSArray array];
    Class arrCls = [array class];
    [self swizzleMethod:@selector(objectAtIndex:) withMethod:NSSelectorFromString(@"objectAtIndexSafely0:") inClass:arrCls];

    NSArray *array1 = [NSArray arrayWithObject:@""];
    Class arrCls1 = [array1 class];
    [self swizzleMethod:@selector(objectAtIndex:) withMethod:NSSelectorFromString(@"objectAtIndexSafely:") inClass:arrCls1];

    NSArray *arrayI = [NSArray arrayWithObjects:@1,@2, nil];
    Class arrClsI = [arrayI class];
    [self swizzleMethod:@selector(objectAtIndex:) withMethod:NSSelectorFromString(@"objectAtIndexSafelyI:") inClass:arrClsI];

    NSLog(@"swizzleArray end");
}

+ (void)swizzleCluster {
    NSLog(@"swizzleCluster begin");

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleString];
        [self swizzleArray];
    });

    NSLog(@"swizzleCluster end");
}

@end
