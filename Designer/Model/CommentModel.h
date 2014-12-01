//
//  CommentModel.h
//  Designer
//
//  Created by 罗 显扬 on 12/2/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (strong, nonatomic) NSMutableArray *commentTimes;
@property (strong, nonatomic) NSMutableArray *commentUserName;
@property (strong, nonatomic) NSMutableArray *commentContents;

@end
