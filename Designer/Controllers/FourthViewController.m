//
//  ThirdViewController.m
//  Designer
//
//  Created by 罗 显扬 on 12/1/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "FourthViewController.h"
#import "ArticleImageCell.h"
#import "GetArticleData.h"
#import "ArticleModel.h"
#import "ArticleDetailViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>

#define DEVICE_FRAME [UIScreen mainScreen].bounds.size

#define TOP_BG_HIDE 120.0f
#define TOP_FLAG_HIDE 55.0f
#define RATE 2
#define SWITCH_Y -TOP_FLAG_HIDE
#define ORIGINAL_POINT CGPointMake(self.view.bounds.size.width/2 - 40, -20)

@interface FourthViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSUInteger _kNameOfPages;
    NSUInteger _tableViewCellCount;
    
    NSUInteger _loadMoreArticleCount;
    BOOL _isFinishLoadAllArticle;
    
    BOOL _pageControlUsed;
    
    BOOL _isLoading;
    CGFloat angle;
    BOOL stopRotating;
    
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) GetArticleData *data;
@property (strong, nonatomic) ArticleModel *allArticle;
@property (strong,nonatomic) BeginUpdatingBlock4 beginUpdatingBlock;
@property (strong, nonatomic) UIImageView *refreshImgView;
@end

@implementation FourthViewController

static NSString * const ArticleImageCellIdentifier = @"ArticleImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    NSDictionary * dict=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    
    //设置右滑返回
    self.navigationController.interactivePopGestureRecognizer.delegate =(id)self;
    
    //开始下载数据
    [self performSelectorInBackground:@selector(startDownloadArticleData) withObject:nil];
    
    __block FourthViewController *weakSelf = self;
    self.beginUpdatingBlock = ^(FourthViewController *viewController) {
        [weakSelf performSelectorInBackground:@selector(startDownloadArticleData) withObject:nil];
    };
    
    self.refreshImgView.hidden = YES;
    self.refreshImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.refreshImgView.center = ORIGINAL_POINT;
    self.refreshImgView.image = [UIImage imageNamed:@"refresh"];
    self.refreshImgView.hidden = YES;
    [self.navigationController.view addSubview:self.refreshImgView];
}

#pragma mark - 下载数据
//后台下载数据
- (void)startDownloadArticleData
{
    //从头加载数据
    //    _reloading = YES;
    _loadMoreArticleCount = 0;
    _isFinishLoadAllArticle = NO;
    NSDictionary *dic = [self.data getArtilcleByGroupNumber:3 withLoadNumber:_loadMoreArticleCount];
    
    if (dic) {
        //将得到的数据保存起来，在没有网络连接的时候可以显示数据
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"savedArticleData"];
        [self performSelectorOnMainThread:@selector(setViewWithArticleDic:) withObject:dic waitUntilDone:NO];
    } else {
        //        _reloading = NO;
        //        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        
        
    }
    [self endUpdating];
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
    
    NSDictionary *dic = [self.data getArtilcleByGroupNumber:3 withLoadNumber:_loadMoreArticleCount];
    
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

-(void)downLoadNewData{
    _isLoading = YES;
    stopRotating = NO;
    angle = 0;
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
