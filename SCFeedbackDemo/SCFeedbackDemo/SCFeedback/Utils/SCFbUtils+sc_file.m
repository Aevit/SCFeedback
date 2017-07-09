//
//  SCFbUtils+sc_file.m
//  SCFeedbackDemo
//
//  Created by aevit on 2017/7/2.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFbUtils+sc_file.h"
#import <UIKit/UIKit.h>

@implementation SCFbUtils (sc_file)

+ (NSSet*)file_sc_videoTypeSet {
    static NSSet *set;
    if (!set) {
        set = [NSSet setWithObjects:@"mp4", @"mov", nil];
    }
    return set;
}

+ (NSSet*)file_sc_picTypeSet {
    static NSSet *set;
    if (!set) {
        set = [NSSet setWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"bmp", @"webp", nil];
    }
    return set;
}

+ (NSSet*)file_sc_audioTypeSet {
    static NSSet *set;
    if (!set) {
        set = [NSSet setWithObjects:@"caf", @"aac", @"mp3", @"m4a", @"wmv", @"wav", @"amr", nil];
    }
    return set;
}

+ (NSString*)file_documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString*)file_cachesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString*)file_scrcd_default_folder {
    static NSString *path = nil;
    if (path && path.length > 0) {
        return path;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    path = [paths[0] stringByAppendingPathComponent:@"scrcd"];
    [SCFbUtils file_createFolder:path];
    //    path = [NSString stringWithFormat:@"%@/scrcd", [paths objectAtIndex:0]]; // tnw todo
    return path;
}

+ (NSArray*)file_getAllFilesInPath:(NSString*)path {
    
    NSAssert(path && path.length > 0, @"SCFeedback: unkown path");
    if (!path || path.length <= 0) {
        return nil;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    //    NSArray *contents = [manager subpathsAtPath:path];
    //    return contents;
    
    NSArray *urls = [manager contentsOfDirectoryAtURL:[NSURL URLWithString:path] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    return urls;
    
    /*
     NSMutableArray *contents = [NSMutableArray array];
     [urls enumerateObjectsUsingBlock:^(NSURL*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
     if ([obj isKindOfClass:[NSURL class]] && [[SCFbUtils file_sc_videoTypeSet] containsObject:[[obj pathExtension] lowercaseString]]) {
     [contents addObject:obj];
     }
     }];
     return contents;
     */
}

+ (void)file_deleteFiles:(NSArray*)arr {
    if (!arr || arr.count <= 0) {
        return;
    }
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSFileManager defaultManager] removeItemAtURL:obj error:nil];
    }];
}

+ (NSMutableArray*)file_getAllImageInPath:(NSString*)path {
    
    NSAssert(path && path.length > 0, @"SCFeedback: unkown path");
    if (!path || path.length <= 0) {
        return nil;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *urls = [manager contentsOfDirectoryAtURL:[NSURL URLWithString:path] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSMutableArray *contents = [NSMutableArray array];
    
    [urls enumerateObjectsUsingBlock:^(NSURL*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSURL class]] && [[SCFbUtils file_sc_picTypeSet] containsObject:[[obj pathExtension] lowercaseString]]) {
            [contents addObject:obj];
        }
    }];
    
    return contents;
}

+ (void)file_deleteAllImageInPath:(NSString*)path {
    NSArray *urls = [[self class] file_getAllImageInPath:path];
    [[self class] file_deleteFiles:urls];
}

+ (BOOL)file_createFolder:(NSString*)folder {
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

+ (BOOL)file_deleteFolder:(NSString*)folder {
    BOOL rs = [[NSFileManager defaultManager] removeItemAtPath:folder error:nil];
    return rs;
}

+ (BOOL)file_saveImage:(UIImage*)image atPath:(NSString*)filePath {
    if (!image || !filePath || filePath.length <= 0) {
        return NO;
    }
    NSData *imageData = nil;
    NSString *ext = [filePath pathExtension];
    if ([ext isEqualToString:@"png"]) {
        imageData = UIImagePNGRepresentation(image);
    } else {
        imageData = UIImageJPEGRepresentation(image, 1);
    }
    if (!imageData || imageData.length <= 0) {
        return NO;
    }
    BOOL rs = [imageData writeToFile:filePath atomically:NO];
    return rs;
}

+ (UIImage*)file_getImageFromFilePath:(NSString*)filePath {
    if (!filePath || filePath.length <= 0) {
        return nil;
    }
    return [UIImage imageWithContentsOfFile:filePath];
}

@end
