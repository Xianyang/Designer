//
//  Article.h
//  Shejishi
//
//  Created by 罗 显扬 on 14/12/11.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (nonatomic, copy, readonly) NSString *title, *content, *topImageUrl;
@property (nonatomic, strong) NSString *likeCount, *commentCount;

- (id)initWithTitle:(NSString *)title content:(NSString *)content topImageUrl:(NSString *)topImageUrl likeCount:(NSString *)likeCount commentCount:(NSString *)commentCount;

@end
