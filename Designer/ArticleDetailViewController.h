//
//  ArticleDetailViewController.h
//  Designer
//
//  Created by 罗 显扬 on 12/2/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleDetailViewController : UIViewController
{
    NSUInteger _articleID;
}

- (void)setArticleID:(NSUInteger)articleID thumbnail:(NSString *)thumbnailName isFirstPage:(BOOL)isFirstPage;

@end
