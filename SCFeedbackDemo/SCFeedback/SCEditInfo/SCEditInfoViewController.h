//
//  SCEditInfoViewController.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/13.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCFbMediaInfo.h"


@class SCFbMediaInfo;

typedef void(^sc_sendInfo_block)(UIViewController *editInfoController, NSArray<SCFbMediaInfo*> *dataArray, NSString *text);

typedef void(^sc_maxMediaInfoNum_block)();

@interface SCEditInfoViewController : UIViewController

/**
 callback when click the next step btn
 */
@property (nonatomic, copy) sc_sendInfo_block completeBlock;


/**
 extra info for something custom, such as the title, the placeholder of textview.
 NOTICE: the key of the "userInfo" has the prefix: "SCEditInfo", you can find the "extern" string in the "SCEditInfoViewController.h"
 */
@property (nonatomic, strong) NSDictionary *customInfo;

/**
 the new mediaInfo
 */
@property (nonatomic, strong) SCFbMediaInfo *theNewInfo;

/**
 set the max number of the contents in the mediaView, default is 4

 @param num the max number
 @param block callback when will reach the max limit number
 */
- (void)setupMaxMediaNum:(NSInteger)num toMaxBlock:(sc_maxMediaInfoNum_block)block;

@end


