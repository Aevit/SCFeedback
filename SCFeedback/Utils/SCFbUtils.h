//
//  SCFbUtils.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/13.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define SCFbLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#else
#define SCFbLog(...)
#endif

#define SCWeakSelf(type) __weak typeof(type) weak##type = type;
#define SCStrongSelf(type) __strong typeof(type) type = weak##type;

#define sc_rgba(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define emptyStr(obj)               (!obj ? @"" : (((NSNull *)(obj) == [NSNull null] ? @"" : (obj))))
#define isEmptyStr(obj)             ([emptyStr(obj) isEqualToString:@""] ? YES : NO)
#define isNilOrNullObj(obj)         ((!obj || [obj isEqual:[NSNull null]]) ? YES : NO)

@interface SCFbUtils : NSObject

@end
