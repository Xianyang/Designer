//
//  XYArticleListManager.h
//  Designer
//
//  Created by 罗 显扬 on 4/1/15.
//  Copyright (c) 2015 罗 显扬. All rights reserved.
//

#import "JSONModel.h"
#import "XYArticleList.h"

@interface XYArticleListManager : JSONModel

@property (strong, nonatomic) NSString *list_size;
@property (strong, nonatomic) NSArray<XYArticleList> *list;

@end
