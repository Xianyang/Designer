//
//  ThirdViewController.m
//  Designer
//
//  Created by 罗 显扬 on 12/1/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "FifthViewController.h"
#import "ArticleImageCell.h"
#import "GetArticleData.h"
#import "ArticleModel.h"
#import "ArticleDetailViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>

#define DEVICE_FRAME [UIScreen mainScreen].bounds.size

@interface FifthViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSUInteger _kNameOfPages;
    NSUInteger _tableViewCellCount;
    
    NSUInteger _loadMoreArticleCount;
    BOOL _isFinishLoadAllArticle;
    
    BOOL _pageControlUsed;
    
}
@property (strong ,nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) GetArticleData *data;
@property (strong, nonatomic) ArticleModel *allArticle;
@end

@implementation FifthViewController

static NSString * const ArticleImageCellIdentifier = @"ArticleImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    //设置右滑返回
    self.navigationController.interactivePopGestureRecognizer.delegate =(id)self;
    
    //开始下载数据
    [self performSelectorInBackground:@selector(startDownloadArticleData) withObject:nil];
}

#pragma mark - 下载数据
//后台下载数据
- (void)startDownloadArticleData
{
    //从头加载数据
    //    _reloading = YES;
    _loadMoreArticleCount = 0;
    _isFinishLoadAllArticle = NO;
    NSDictionary *dic = [self.data getArticleListOnce];
    
    if (dic) {
        //将得到的数据保存起来，在没有网络连接的时候可以显示数据
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"savedArticleData"];
        [self performSelectorOnMainThread:@selector(setViewWithArticleDic:) withObject:dic waitUntilDone:NO];
    } else {
        //        _reloading = NO;
        //        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        
        
    }
}

- (void)setViewWithArticleDic:(NSDictionary *)dic
{
    [self.allArticle.imagesUrlArray removeAllObjects];
    [self.allArticle.titlesArray removeAllObjects];
    [self.allArticle.idsArray removeAllObjects];
    [self.allArticle.likeCountArray removeAllObjects];
    [self.allArticle.commentCountArray removeAllObjects];
    
    _tableViewCellCount = [[dic objectForKey:@"list_size"] integerValue];
    
    id list = [dic objectForKey:@"list"];
    if ([list isKindOfClass:[NSArray class]]) {
        for (NSDictionary *aDic in list) {
            [self.allArticle.imagesUrlArray addObject:[aDic objectForKey:@"pic"]];
            [self.allArticle.titlesArray addObject:[aDic objectForKey:@"title"]];
            [self.allArticle.idsArray addObject:[aDic objectForKey:@"id"]];
            [self.allArticle.likeCountArray addObject:[aDic objectForKey:@"like_count"]];
            [self.allArticle.commentCountArray addObject:[aDic objectForKey:@"comment_count"]];
        }
    }
    
    [self.tableView reloadData];
    
}

//加载更多数据，条数可更改
- (void)loadMoreArticle
{
    NSLog(@"load 5 more article");
    _loadMoreArticleCount++;
    
    NSDictionary *dic = [self.data getMoreArticleList:_loadMoreArticleCount];
    
    NSInteger list_size = [[dic objectForKey:@"list_size"] integerValue];
    if (list_size) {
        _tableViewCellCount += list_size;
        if (list_size < 5) {
            _isFinishLoadAllArticle = YES;  //文章已经全部加载完
        }
        id list = [dic objectForKey:@"list"];
        for (NSDictionary *aDic in list) {
            [self.allArticle.imagesUrlArray addObject:[aDic objectForKey:@"pic"]];
            [self.allArticle.titlesArray addObject:[aDic objectForKey:@"title"]];
            [self.allArticle.idsArray addObject:[aDic objectForKey:@"id"]];
            [self.allArticle.likeCountArray addObject:[aDic objectForKey:@"like_count"]];
            [self.allArticle.commentCountArray addObject:[aDic objectForKey:@"comment_count"]];
        }
    } else {
        //返回为空
        _isFinishLoadAllArticle = YES;
    }
}

- (ArticleModel *)allArticle
{
    if (!_allArticle) {
        _allArticle = [[ArticleModel alloc] init];
    }
    
    return _allArticle;
}

- (GetArticleData *)data
{
    if (!_data) {
        _data = [[GetArticleData alloc] init];
    }
    
    return _data;
}


#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableViewCellCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _tableViewCellCount - 5) {
        if (!_isFinishLoadAllArticle) {
            //记得将这个值改成20
            //[self loadMoreArticle];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self loadMoreArticle];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            });
        }
    }
    
    return [self setupCell:indexPath];
}

- (ArticleImageCell *)setupCell:(NSIndexPath *)indexPath
{
    ArticleImageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ArticleImageCellIdentifier
                                                                  forIndexPath:indexPath];
    
    [self configureImageCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureImageCell:(ArticleImageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.titleLabel setText:self.allArticle.titlesArray[indexPath.row]];
    [cell.likeCountLabel setText:self.allArticle.likeCountArray[indexPath.row]];
    [cell.commentCountLabel setText:self.allArticle.commentCountArray[indexPath.row]];
    [self setImageForCell:cell atIndexPath:indexPath];
}

- (void)setImageForCell:(ArticleImageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell.customImageView setImage:nil];
    [cell.customImageView setImageWithURL:[NSURL URLWithString:self.allArticle.imagesUrlArray[indexPath.row]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowArticleDetailSegue"]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        ArticleDetailViewController *articleDetailViewController = segue.destinationViewController;
        
        [articleDetailViewController setArticleID:[self.allArticle.idsArray[indexPath.row] integerValue]];
    }
}

@end
