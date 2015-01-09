//
//  PageViewController.h
//  Shejishi
//
//  Created by 罗 显扬 on 12/8/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleImageCell.h"
#import "ArticleDetailViewController.h"
#import "LibraryAPI.h"
#import "ArticleImageCell.h"
#import <AFNetworking/UIKit+AFNetworking.h>

@class PageViewController;
typedef void (^BeginUpdatingBlock)(PageViewController *);

@interface PageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
//    int _group;
    
    NSUInteger _tableViewCellCount;
    
    int _loadMoreArticleCount;
    BOOL _isFinishLoadAllArticle;
    
    BOOL _pageControlUsed;
        
    BOOL _isLoading;
    CGFloat angle;
    BOOL stopRotating;
    
    
}

@property (assign, nonatomic) NSInteger group;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *articlesInList;

@property (strong,nonatomic) BeginUpdatingBlock beginUpdatingBlock;
@property (strong, nonatomic) UIImageView *refreshImgView;



@end
