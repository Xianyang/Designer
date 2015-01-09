//
//  TopImage.h
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/13.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopImage : NSObject

@property (nonatomic, copy, readonly) NSString *articleID, *title, *imageUrl;

- (id)initWithArticleID:(NSString *)articleID title:(NSString *)title imageUrl:(NSString *)imageUrl;

@end
