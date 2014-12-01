//
//  CommentModel.m
//  Designer
//
//  Created by 罗 显扬 on 12/2/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "CommentModel.h"

@implementation CommentModel

- (NSMutableArray *)commentContents
{
    if (!_commentContents) {
        _commentContents = [[NSMutableArray alloc] init];
    }
    
    return _commentContents;
}

- (NSMutableArray *)commentUserName
{
    if (!_commentUserName) {
        _commentUserName = [[NSMutableArray alloc] init];
    }
    
    return _commentUserName;
}

- (NSMutableArray *)commentTimes
{
    if (!_commentTimes) {
        _commentTimes = [[NSMutableArray alloc] init];
    }
    
    return _commentTimes;
}


@end
