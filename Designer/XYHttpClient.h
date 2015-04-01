//
//  XYHttpClient.h
//  Designer
//
//  Created by 罗 显扬 on 4/1/15.
//  Copyright (c) 2015 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYArticleListManager.h"
#import "XYTopImageManager.h"
#import <UIKit/UIKit.h>

@interface XYHttpClient : NSObject

//加载第group页的第loadcount组
- (void)downloadArticleInGroup:(int)group
                           withLoadCount:(int)loadCount
                                 success:(void (^)(XYArticleListManager *xyArticleListManager))successBlock
                                    fail:(void (^)(NSError *error))failBlock;

//获取第一页的焦点图URL
- (void)downloadTopImageURL:(void (^)(XYTopImageManager *xyTopImageManager))successBlock
                       fail:(void (^)(NSError *error))failBlock;

//根据URL下载图片
- (UIImage*)downloadImage:(NSString*)url;

@end
