//
//  PageViewController.m
//  Shejishi
//
//  Created by 罗 显扬 on 12/8/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "PageViewController.h"
#import "LibraryAPI.h"
#import "ArticleImageCell.h"
#import <AFNetworking/UIKit+AFNetworking.h>

#define TOP_BG_HIDE 120.0f
#define TOP_FLAG_HIDE 55.0f
#define RATE 2
#define SWITCH_Y -TOP_FLAG_HIDE
#define ORIGINAL_POINT CGPointMake(self.view.bounds.size.width/2 - 35, -20)

@interface PageViewController ()

@end

@implementation PageViewController

static NSString * const ArticleImageCellIdentifier = @"ArticleImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    _loadMoreArticleCount = 0;
    _isFinishLoadAllArticle = NO;
    
    //文章下载好后加载数据
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadArticleFinish:)
                                                 name:@"ReloadTableViewInGroup"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LoadAllArticlesFinish:)
                                                 name:@"LoadAllArticlesFinish"
                                               object:nil];
    
    //2.
    self.articlesInList = [[LibraryAPI sharedInstance] getArticlesInGroup:(int)_group];
    if (![self.articlesInList count]) {
        [self performSelectorInBackground:@selector(startDownloadArticle) withObject:nil];
    } else {
        [self.tableView reloadData];
    }
    
    //3.
    __block PageViewController *weakSelf = self;
    self.beginUpdatingBlock = ^(PageViewController *viewController) {
        [weakSelf performSelectorInBackground:@selector(startDownloadArticle) withObject:nil];
    };
    
    //4.
    self.refreshImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.refreshImgView.center = ORIGINAL_POINT;
    self.refreshImgView.image = [UIImage imageNamed:@"refresh"];
    self.refreshImgView.hidden = YES;
    [self.navigationController.view addSubview:self.refreshImgView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    //设置title字体为白色
    NSDictionary * dict=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    
    [super viewWillAppear:animated];
}

- (void)startDownloadArticle
{
    [[LibraryAPI sharedInstance] downloadArticleInGroup:(int)_group withLoadCount:_loadMoreArticleCount];
}

- (void)startLoadMoreArticle
{
    NSLog(@"load 5 more article");
    _loadMoreArticleCount++;
    
    [[LibraryAPI sharedInstance] downloadArticleInGroup:(int)_group withLoadCount:_loadMoreArticleCount];
}

- (void)downloadArticleFinish:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(reloadTableView:) withObject:notification waitUntilDone:NO];
}

- (void)LoadAllArticlesFinish:(NSNotification *)notification
{
    _isFinishLoadAllArticle = YES;
}

- (void)reloadTableView:(NSNotification *)notification
{
    NSString *group = notification.userInfo[@"group"];
    if ([group isEqualToString:[NSString stringWithFormat:@"%ld", (long)_group]]) {
        self.articlesInList = [[LibraryAPI sharedInstance] getArticlesInGroup:(int)_group];
        _tableViewCellCount = (int)[self.articlesInList count];
        
        [self.tableView reloadData];
    }
    
    [self endUpdating];
}

#pragma mark - UITableViewDataSource

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
            [self performSelectorInBackground:@selector(startLoadMoreArticle) withObject:nil];
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
    ArticleInList *article = self.articlesInList[indexPath.row];
    
    [cell.titleLabel setText:article.title];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadImageNotification"
                                                        object:self
                                                      userInfo:@{@"imageView":cell.customImageView, @"url":article.imageUrl, @"group":[NSString stringWithFormat:@"%ld", (long)self.group]}];
    
    //[self setImageForCell:cell atIndexPath:indexPath withURL:[NSURL URLWithString:article.imageUrl]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setImageForCell:(ArticleImageCell *)cell atIndexPath:(NSIndexPath *)indexPath withURL:(NSURL *)url
{
    [cell.customImageView setImage:nil];
    [cell.customImageView setImageWithURL:url];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    //下拉刷新逻辑
    CGPoint contentOffset = sender.contentOffset;
//    contentOffset.y += 20.0f;
    CGPoint point = contentOffset;
//    point.y += 20.0f;
    //        CGFloat rate = point.y/sender.contentSize.height;
    CGFloat rate = point.y / 667;
    if(point.y+TOP_BG_HIDE>5){
        //self.bgImageView.frame = CGRectMake(0, (-TOP_BG_HIDE)*(1+rate*RATE), self.bgImageView.frame.size.width, self.bgImageView.frame.size.height);
    }
    if(!_isLoading){
        if(sender.dragging){
            if(point.y+TOP_FLAG_HIDE>=0){
                self.refreshImgView.center = CGPointMake(self.refreshImgView.center.x,(-TOP_FLAG_HIDE)*(1+rate*RATE*7)+35);
            }
            self.refreshImgView.transform = CGAffineTransformMakeRotation(rate*30);
        }else{
            //判断位置
            if(point.y<SWITCH_Y){//触发刷新状态
                [self downLoadNewData];
            }else{
                self.refreshImgView.center = CGPointMake(self.refreshImgView.center.x,(-TOP_FLAG_HIDE)*(1+rate*RATE*7)+35);
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.refreshImgView.hidden = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.refreshImgView.hidden = YES;
}

-(void)downLoadNewData{
    _isLoading = YES;
    stopRotating = NO;
    angle = 0;
    
    _loadMoreArticleCount = 0;
    _isFinishLoadAllArticle = NO;
    
    [self rotateRefreshImage];
    
    if(self.beginUpdatingBlock){
        self.beginUpdatingBlock(self);
    }
}

-(void)endUpdating{
    stopRotating = YES;
}

-(void)rotateRefreshImage{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.refreshImgView.transform = endAngle;
    } completion:^(BOOL finished) {
        angle += 10;
        if(!stopRotating){
            [self rotateRefreshImage];
        }else{
            //上升隐藏
            [UIView animateWithDuration:0.2 animations:^{
                self.refreshImgView.center = ORIGINAL_POINT;
            } completion:^(BOOL finished) {
                _isLoading = NO;
                self.refreshImgView.hidden = YES;
            }];
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowArticleDetailSegue"]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        ArticleDetailViewController *articleDetailViewController = segue.destinationViewController;
        
        ArticleInList *article = self.articlesInList[indexPath.row];
        [articleDetailViewController setArticleID:[article.articleID integerValue]];
        [articleDetailViewController setThumbnail:article.imageUrl];
    }
}


@end
