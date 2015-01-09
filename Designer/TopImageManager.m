//
//  TopImageManager.m
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/13.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import "TopImageManager.h"

@interface TopImageManager()

@property (strong, nonatomic) NSMutableArray *topImages;

@end

@implementation TopImageManager

- (NSArray *)getTopImages
{
    return self.topImages;
}

- (void)setTopImagesWithArray:(NSArray *)topImages
{
    self.topImages = [topImages mutableCopy];
}

- (NSMutableArray *)topImages
{
    if(!_topImages) _topImages = [[NSMutableArray alloc] init];
    return _topImages;
}

@end
