//
//  ArticleInList.m
//  Shejishi
//
//  Created by 罗 显扬 on 14/12/11.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import "ArticleInList.h"

@implementation ArticleInList

- (id)initWithID:(NSString *)articleID title:(NSString *)title imageUrl:(NSString *)imageUrl likeCount:(NSString *)likeCount commentCount:(NSString *)commentCount
{
    if (self = [super init]) {
        _articleID = articleID;
        _title = title;
        _imageUrl = imageUrl;
        _likeCount = likeCount;
        _commentCount = commentCount;
    }
    
    return self;
}

@end
