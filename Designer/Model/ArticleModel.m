//
//  ArticleModel.m
//  Designer
//
//  Created by 罗 显扬 on 11/28/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "ArticleModel.h"

@implementation ArticleModel

- (NSMutableArray *)imagesUrlArray
{
    if (!_imagesUrlArray) {
        _imagesUrlArray = [[NSMutableArray alloc] init];
    }
    
    return _imagesUrlArray;
}

- (NSMutableArray *)titlesArray
{
    if (!_titlesArray) {
        _titlesArray = [[NSMutableArray alloc] init];
    }
    
    return _titlesArray;
}

- (NSMutableArray *)idsArray
{
    if (!_idsArray) {
        _idsArray = [[NSMutableArray alloc] init];
    }
    
    return _idsArray;
}

- (NSMutableArray *)likeCountArray
{
    if (!_likeCountArray) {
        _likeCountArray = [[NSMutableArray alloc] init];
    }
    
    return _likeCountArray;
}

- (NSMutableArray *)commentCountArray
{
    if (!_commentCountArray) {
        _commentCountArray = [[NSMutableArray alloc] init];
    }
    
    return _commentCountArray;
}


@end
