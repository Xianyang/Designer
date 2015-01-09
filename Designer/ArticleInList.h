//
//  ArticleInList.h
//  Shejishi
//
//  Created by 罗 显扬 on 14/12/11.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleInList : NSObject

@property (nonatomic, copy, readonly) NSString *articleID, *title, *imageUrl, *likeCount, *commentCount;

- (id)initWithID:(NSString *)articleID title:(NSString *)title imageUrl:(NSString *)imageUrl likeCount:(NSString *)likeCount commentCount:(NSString *)commentCount;

@end
