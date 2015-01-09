//
//  TopImage.m
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/13.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import "TopImage.h"

@implementation TopImage

- (id)initWithArticleID:(NSString *)articleID title:(NSString *)title imageUrl:(NSString *)imageUrl
{
    self = [super init];
    if (self) {
        _articleID = articleID;
        _title = title;
        _imageUrl = imageUrl;
    }
    
    return self;
}

@end
