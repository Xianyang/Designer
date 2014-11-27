//
//  ArticleModel.h
//  Designer
//
//  Created by 罗 显扬 on 11/28/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleModel : NSObject

@property (strong, nonatomic) NSMutableArray *imagesUrlArray;
@property (strong, nonatomic) NSMutableArray *titlesArray;
@property (strong, nonatomic) NSMutableArray *idsArray;
@property (strong, nonatomic) NSMutableArray *likeCountArray;
@property (strong, nonatomic) NSMutableArray *commentCountArray;

@end
