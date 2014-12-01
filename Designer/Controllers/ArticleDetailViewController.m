//
//  ArticleDetailViewController.m
//  Designer
//
//  Created by 罗 显扬 on 12/2/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "ArticleDetailViewController.h"
#import "GetArticleData.h"
#import "CommentViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>

#define DEVICE_FRAME [UIScreen mainScreen].bounds.size
#define TOPIMAGE_HEIGHT 213.0f

@interface ArticleDetailViewController () <UIWebViewDelegate, UIScrollViewDelegate>
{
    NSInteger _commentCount;
    NSInteger _imageCount;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageOfDianzan;
@property (weak, nonatomic) IBOutlet UILabel *labelCountOfDianzan;
@property (weak, nonatomic) IBOutlet UILabel *labelCountOfComment;

@property (strong, nonatomic) UIImageView *topImageView;
@property (strong, nonatomic) UILabel *articleTitle;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIView *statusBarZheZhaoView;

@property (strong, nonatomic) GetArticleData *articleData;


@end

@implementation ArticleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];

    _commentCount = 0;
    
    self.statusBarZheZhaoView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.scrollView addSubview:self.webView];
    [self clearWebViewBackground:self.webView];
    
    self.statusBarZheZhaoView.backgroundColor = [UIColor clearColor];
    
//    加载文章数据, 文章加载完后才会加载评论数据
    
    [self performSelectorInBackground:@selector(loadArticleData) withObject:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.webView isEqual:webView]) {
        NSArray *arr = [self.webView subviews];
        UIScrollView *ascollView = [arr objectAtIndex:0];
        
        CGFloat actualHeight = 0.0f;
        if (DEVICE_FRAME.width == 320.0f) {
            actualHeight = ascollView.contentSize.height + _imageCount * 180.0f;
        } else if (DEVICE_FRAME.width == 375.0f) {
            actualHeight = ascollView.contentSize.height + _imageCount * 210.0f;
        } else if (DEVICE_FRAME.width == 414.0f) {
            actualHeight = ascollView.contentSize.height + _imageCount * 230.0f;
        }
        
        NSLog(@"The no image webview hight is %f", actualHeight);
        [self.webView setFrame:CGRectMake(0.0f, TOPIMAGE_HEIGHT, DEVICE_FRAME.width, actualHeight)];
        [self.scrollView setContentSize:CGSizeMake(TOPIMAGE_HEIGHT, TOPIMAGE_HEIGHT + self.webView.frame.size.height)];
    }
}

- (void)popViewController
{
    self.statusBarZheZhaoView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setArticleID:(NSUInteger)articleID
{
    _articleID = articleID;
    NSLog(@"the article id is %lu", (unsigned long)_articleID);
}

#pragma mark 去除webView滚动顶部和底部的白边
- (void)clearWebViewBackground:(UIWebView *)webView
{
    UIWebView *web = webView;
    for (id v in web.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            [v setBounces:NO];
        }
    }
}

#pragma mark 加载文章数据

- (void)loadArticleData
{
    NSDictionary *dic = [self.articleData getArticleData:_articleID];
    
    if (dic) {
        [self performSelectorOnMainThread:@selector(finishLoadArticleData:) withObject:dic waitUntilDone:NO];
    } else {
        //TODO加载文章数据失败
    }
}

- (void)finishLoadArticleData:(NSDictionary *)dic
{
    //1.下载顶部图片
    [self.scrollView addSubview:self.topImageView];
    id imageUrlString = [dic objectForKey:@"t_pic"];
    if ([imageUrlString isKindOfClass:[NSString class]]) {
        [self.topImageView setImageWithURL:[NSURL URLWithString:imageUrlString]];
    }
    
    //2.显示评论数和点赞数
    id dianzanString = [dic objectForKey:@"like_count"];
    id pinglunString = [dic objectForKey:@"comment_count"];
    if ([dianzanString isKindOfClass:[NSString class]]) {
        self.labelCountOfDianzan.text = dianzanString;
    }
    if ([pinglunString isKindOfClass:[NSString class]]) {
        self.labelCountOfComment.text = pinglunString;
    }
    
    id dianzanStatus = [dic objectForKey:@"status"];
    if ([dianzanStatus isKindOfClass:[NSString class]]) {
        if ([dianzanStatus isEqualToString:@"1"]) {
            self.imageOfDianzan.image = [UIImage imageNamed:@"button_zan"];
        } else {
            self.imageOfDianzan.image = [UIImage imageNamed:@"button_zan_click"];
        }
    }
    
    //3.显示文章内容
    
    //(1).标题
    id title = [dic objectForKey:@"title"];
    
    //(2).遮罩
    UIImageView *zhezhaoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DEVICE_FRAME.width, TOPIMAGE_HEIGHT)];
    if ([title length] < 15) {
        [zhezhaoImageView setImage:[UIImage imageNamed:@"pic_zhezhao_small"]];
    } else {
        [zhezhaoImageView setImage:[UIImage imageNamed:@"pic_zhezhao"]];
    }
    
    [_topImageView addSubview:zhezhaoImageView];
    
    if ([title isKindOfClass:[NSString class]]) {
        self.articleTitle.text = title;
        [_topImageView addSubview:self.articleTitle];
    }
    
    //(3).正文
    //    NSString *htmlURLString = [NSString stringWithFormat:@"<body style='background-color:#FFFFFF'><h3>%@</h3>", title];
    //    NSString *htmlURLString = @"<body style='background-color:#FFFFFF'>";
    CGFloat imageWidth = DEVICE_FRAME.width - 40.0f;
    NSString *imageWidhtString = [NSString stringWithFormat:@"%f", imageWidth];
    
    NSString *htmlURLString = [[@"<body style='background-color:#FFFFFF;'><style>img{width:" stringByAppendingString:imageWidhtString] stringByAppendingString:@"px;</style>"];
    
    NSString *contentString = htmlURLString;
    contentString = [htmlURLString stringByAppendingString:[dic objectForKey:@"content"]];
    contentString = [contentString stringByAppendingString:@"</body>"];
    
    [self.webView loadHTMLString:contentString baseURL:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    if (point.y > TOPIMAGE_HEIGHT - 20.0f) {
        self.statusBarZheZhaoView.backgroundColor = [UIColor whiteColor];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        self.statusBarZheZhaoView.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}


- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, TOPIMAGE_HEIGHT, DEVICE_FRAME.width, self.scrollView.frame.size.height - TOPIMAGE_HEIGHT)];
        _webView.delegate = self;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.scrollEnabled = NO;
    }
    
    return _webView;
}

- (UIImageView *)topImageView
{
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DEVICE_FRAME.width, TOPIMAGE_HEIGHT)];
    }
    
    return _topImageView;
}

- (UILabel *)articleTitle
{
    if (!_articleTitle) {
        _articleTitle = [[UILabel alloc] initWithFrame:CGRectMake(22.0f, TOPIMAGE_HEIGHT - 60.0f, DEVICE_FRAME.width - 47.0f, 60.0f)];
        _articleTitle.textColor = [UIColor whiteColor];
        _articleTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:21];
        _articleTitle.numberOfLines = 0;
    }
    
    return _articleTitle;
}

- (UIView *)statusBarZheZhaoView
{
    if (!_statusBarZheZhaoView) {
        _statusBarZheZhaoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DEVICE_FRAME.width, 20.0f)];
        _statusBarZheZhaoView.backgroundColor = [UIColor clearColor];
        [self.navigationController.view addSubview:self.statusBarZheZhaoView];
    }
    
    return _statusBarZheZhaoView;
}

- (GetArticleData *)articleData
{
    if (!_articleData) {
        _articleData = [[GetArticleData alloc] init];
    }
    
    return _articleData;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToCommentViewSegue"]) {
        CommentViewController *commentViewController = segue.destinationViewController;
        [commentViewController setArticleID:_articleID];
    }
}


@end
