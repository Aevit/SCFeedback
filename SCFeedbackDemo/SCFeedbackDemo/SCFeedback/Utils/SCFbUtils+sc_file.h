//
//  SCFbUtils+sc_file.h
//  SCFeedbackDemo
//
//  Created by aevit on 2017/7/2.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFbUtils.h"

@interface SCFbUtils (sc_file)

+ (NSSet*)file_sc_videoTypeSet;

+ (NSSet*)file_sc_picTypeSet;

+ (NSSet*)file_sc_audioTypeSet;

+ (NSString *)file_documentsPath;

+ (NSString *)file_cachesPath;

+ (NSString*)file_scrcd_default_folder;

+ (BOOL)file_createFolder:(NSString*)folder;

+ (BOOL)file_deleteFolder:(NSString*)folder;

+ (NSArray*)file_getAllFilesInPath:(NSString*)path;

+ (void)file_deleteFiles:(NSArray*)arr;

+ (NSMutableArray*)file_getAllImageInPath:(NSString*)path;

+ (void)file_deleteAllImageInPath:(NSString*)path;

@end
