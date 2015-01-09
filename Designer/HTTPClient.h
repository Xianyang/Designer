//
//  HTTPClient.h
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/12.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HTTPClient : NSObject

//加载第group页的第loadcount组
- (NSDictionary *)downloadArticleInGroup:(int)group withLoadCount:(int)loadCount;

//获取第一页的焦点图URL
- (NSDictionary *)downloadTopImageURL;

//根据URL下载图片
- (UIImage*)downloadImage:(NSString*)url;

@end
