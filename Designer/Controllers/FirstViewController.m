//
//  FirstViewController.m
//  Designer
//
//  Created by 罗 显扬 on 11/27/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "FirstViewController.h"
#import "ArticleImageCell.h"
#import "GetArticleData.h"
#import "ArticleModel.h"
#import "ArticleDetailViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>

#define DEVICE_FRAME [UIScreen mainScreen].bounds.size

@interface FirstViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSUInteger _kNameOfPages;
    NSUInteger _tableViewCellCount;
    
    NSUInteger _loadMoreArticleCount;
    BOOL _isFinishLoadAllArticle;
    
    BOOL _pageControlUsed;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *topScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *myNavigationView;
@property (strong, nonatomic) GetArticleData *data;
@property (strong, nonatomic) ArticleModel *allArticle;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation FirstViewController

static NSString * const ArticleImageCellIdentifier = @"ArticleImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
    
    //设置右滑返回
    self.navigationController.interactivePopGestureRecognizer.delegate =(id)self;
    
    //开始下载数据
    [self performSelectorInBackground:@selector(startDownloadArticleData) withObject:nil];
    
    //计时器，循环显示焦点图
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                  target:self
                                                selector:@selector(scrollToNextPage:)
                                                userInfo:nil
                                                 repeats:YES];
    [self.timer setFireDate:[NSDate distantFuture]];
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
    //1.解析出top3文章的图片url数组
    [self.allArticle.topImageViewIDsArray removeAllObjects];
    [self.allArticle.topImageViewTitlesArray removeAllObjects];
    [self.allArticle.topImageViewUrlsArray removeAllObjects];
    id array = [dic objectForKey:@"top3"];
    if ([array isKindOfClass:[NSArray class]]) {
        _kNameOfPages = 0;
        for (NSDictionary *aDic in array) {
            [self.allArticle.topImageViewUrlsArray addObject:[aDic objectForKey:@"pic"]];
            [self.allArticle.topImageViewIDsArray addObject:[aDic objectForKey:@"id"]];
            [self.allArticle.topImageViewTitlesArray addObject:[aDic objectForKey:@"title"]];
            _kNameOfPages++;
        }
    }
    
    [self setTopImageView];
    
    //2.解析出文章数据
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

#pragma mark - TopScrollView

- (void)setTopImageView
{
    [self.imageViews removeAllObjects];
//    [self.isScrollViewHasSubview removeAllObjects];
    for (unsigned i = 0; i < _kNameOfPages; i++) {
        [self.imageViews addObject:[NSNull null]];
    }
    
    //set up scroll view
    [self.topScrollView setPagingEnabled:YES];
    [self.topScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * _kNameOfPages, 160.0f)];
    [self.topScrollView setShowsHorizontalScrollIndicator:NO];
    [self.topScrollView setShowsVerticalScrollIndicator:NO];
    [self.topScrollView setScrollsToTop:NO];
    [self.topScrollView setDelegate:self];
    
    [self.pageControl setNumberOfPages:_kNameOfPages];
    [self.pageControl setCurrentPage:0];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    //开启计时器，自动翻页
    [self.timer setFireDate:[NSDate date]];
}

//自动翻页到下一页
- (void)scrollToNextPage:(id)sender
{
    NSInteger pageNum = self.pageControl.currentPage;
    CGRect frame = self.topScrollView.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    frame.origin.y = 0.0f;
    frame.origin.x = frame.size.width * (pageNum + 1);
    [self.topScrollView scrollRectToVisible:frame animated:YES];
    pageNum++;
    
    if (pageNum == _kNameOfPages) {
        frame.origin.x = 0.0f;
    }
    [self.topScrollView scrollRectToVisible:frame animated:YES];
}


//加载一个page
- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0) {
        return;
    }
    if (page >= _kNameOfPages) {
        return;
    }
    
    //若已添加上某图片，则不在添加
    UIImageView *imageView = [self.imageViews objectAtIndex:page];
    
    if ([(NSNull *)imageView isEqual:[NSNull null]]) {
        //if ([self.topImageViewImagesArray[page] isKindOfClass:[UIImage class]]) {
        //imageView = [[UIImageView alloc] initWithImage:self.topImageViewImagesArray[page]];
        imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:[NSURL URLWithString:self.allArticle.topImageViewUrlsArray[page]]];
        
        imageView.tag = [self.allArticle.topImageViewIDsArray[page] integerValue];
        //            imageView.exclusiveTouch = YES;
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
        singleFingerOne.numberOfTouchesRequired = 1;
        singleFingerOne.numberOfTapsRequired = 1;
        singleFingerOne.delegate = self;
        [imageView addGestureRecognizer:singleFingerOne];
        
        UIImageView *zhezhaoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 160.0f - 54.0f, DEVICE_FRAME.width, 54.0f)];
        zhezhaoImageView.image = [UIImage imageNamed:@"zhezhao_faxian"];
        [imageView addSubview:zhezhaoImageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 110.0f, DEVICE_FRAME.width, 34.0f)];
        //                [titleLabel setAlpha:0.5f];
        titleLabel.backgroundColor = [UIColor clearColor];
        NSString *title = [@"    " stringByAppendingString:self.allArticle.topImageViewTitlesArray[page]];
        
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        [titleLabel setText:title];
        [imageView addSubview:titleLabel];
        
        
        
        [self.imageViews replaceObjectAtIndex:page withObject:imageView];
        //}
        
    }
    
    if (self.topScrollView != nil) {
        CGRect frame = self.topScrollView.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        [imageView setFrame:frame];
        [self.topScrollView addSubview:imageView];
    }
}

//点击图片，进入文章界面
- (void)imageViewClicked:(UITapGestureRecognizer *)recognizer
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ArticleDetailViewController *articleDetailViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ArticleDetailViewController"];
    //设置文章id
    [articleDetailViewController setArticleID:recognizer.view.tag];
    [self.navigationController pushViewController:articleDetailViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if ([sender isEqual:self.topScrollView]) {
        // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
        // which a scroll event generated from the user hitting the page control triggers updates from
        // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
        if (_pageControlUsed)
        {
            // do nothing - the scroll was initiated from the page control, not the user dragging
            return;
        }
        
        // Switch the indicator when more than 50% of the previous/next page is visible
        CGFloat pageWidth = self.topScrollView.frame.size.width;
        int page = floor((self.topScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
        
        // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
        
        // A possible optimization would be to unload the views+controllers which are no longer visible
    } else {
        if (sender.contentOffset.y > -20.0f && sender.contentOffset.y < 76.0f) {
            self.myNavigationView.alpha = (sender.contentOffset.y + 20) / 96;
        } else if (sender.contentOffset.y < -20.0f){
            self.myNavigationView.alpha = 0.0f;
        } else if (sender.contentOffset.y > 76.0f) {
            self.myNavigationView.alpha = 1.0f;
        }
    }
//    else {
//        [_refreshHeaderView egoRefreshScrollViewDidScroll:sender];
//    }
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.topScrollView]) {
        _pageControlUsed = NO;
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.topScrollView]) {
        _pageControlUsed = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([scrollView isEqual:self.topScrollView]) {
        //        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
        //                                                      target:self
        //                                                    selector:@selector(scrollToNextPage:)
        //                                                    userInfo:nil
        //                                                     repeats:NO];
        [self.timer setFireDate:[[NSDate date] dateByAddingTimeInterval:5.0]];
    }
//    else {
//        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
//    }
}

- (NSMutableArray *)imageViews
{
    if (!_imageViews) {
        _imageViews = [[NSMutableArray alloc] init];
    }
    
    return _imageViews;
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
