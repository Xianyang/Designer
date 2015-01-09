//
//  Article.m
//  Shejishi
//
//  Created by 罗 显扬 on 14/12/11.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import "Article.h"

@implementation Article

- (id)initWithTitle:(NSString *)title content:(NSString *)content topImageUrl:(NSString *)topImageUrl likeCount:(NSString *)likeCount commentCount:(NSString *)commentCount
{
    self = [super init];
    if (self) {
        _title = title;
        _content = content;
        _topImageUrl = topImageUrl;
        _likeCount = likeCount;
        _commentCount = commentCount;
    }
    
    return self;
}

@end
