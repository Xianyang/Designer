//
//  XYArticleList.h
//  Designer
//
//  Created by 罗 显扬 on 4/1/15.
//  Copyright (c) 2015 罗 显扬. All rights reserved.
//

#import "JSONModel.h"

@protocol XYArticleList
@end

@interface XYArticleList : JSONModel

@property (strong, nonatomic) NSString *like_count;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *pic;
@property (strong, nonatomic) NSString *comment_count;

@end
