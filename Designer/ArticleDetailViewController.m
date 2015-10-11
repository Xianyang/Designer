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
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import <ShareSDK/ShareSDK.h>

#define DEVICE_FRAME [UIScreen mainScreen].bounds.size
#define TOPIMAGE_HEIGHT 213.0f

@interface ArticleDetailViewController () <UIWebViewDelegate, UIScrollViewDelegate, NJKWebViewProgressDelegate>
{
    NSInteger _commentCount;
    NSInteger _imageCount;
    
    NSString *_title;
    NSString *_abstract;
    
    NSString *_thumbnailName;
    
    BOOL _isFirstPage;
    
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    BOOL _isStatusBarZheZhaoViewAppear;
}

//@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIImageView *dianzanImage;
@property (weak, nonatomic) IBOutlet UILabel *dianzanLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

//@property (strong, nonatomic) UIImageView *topImageView;
//@property (strong, nonatomic) UILabel *articleTitle;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIView *statusBarZheZhaoView;

@property (strong, nonatomic) GetArticleData *articleData;


@end

@implementation ArticleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    
    _commentCount = 0;
    
    self.statusBarZheZhaoView.alpha = 0.0;
    _isStatusBarZheZhaoViewAppear = NO;
    
    [self.webView.scrollView setDelegate:self];
    
    [self setProgressView];
    
//    加载文章数据, 文章加载完后才会加载评论数据
    [self performSelectorInBackground:@selector(loadArticleData) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    if (_isStatusBarZheZhaoViewAppear) {
        self.statusBarZheZhaoView.alpha = 1.0;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        self.statusBarZheZhaoView.alpha = 0.0;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    if (_isFirstPage) {
        [self.view addSubview:_progressView];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    self.statusBarZheZhaoView.alpha = 0.0;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [super viewWillDisappear:animated];
}

- (void)setProgressView
{
    _progressProxy = [[NJKWebViewProgress alloc] init];
    self.webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, 1, self.view.frame.size.width, 3)];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *picName = [[request URL] absoluteString];
    
    NSLog(@"pic name is %@", picName);
    
    return YES;
}

- (void)popViewController
{
    [self.statusBarZheZhaoView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setArticleID:(NSUInteger)articleID thumbnail:(NSString *)thumbnailName isFirstPage:(BOOL)isFirstPage
{
    _articleID = articleID;
    _thumbnailName = thumbnailName;
    _isFirstPage = isFirstPage;
    
    NSLog(@"the article id is %lu", (unsigned long)_articleID);
}

#pragma mark - 分享

- (IBAction)shareBtnClicked:(id)sender
{
    NSString *imagePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", [_thumbnailName lastPathComponent]];
    
//    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
//    NSData *data = [NSData dataWithContentsOfFile:filename];
    
    //1、构造分享内容
    //    id<ISSContent> publishContent = [ShareSDK content:@"要分享的内容"
    //                                       defaultContent:@"默认内容"
    //                                                image:[ShareSDK imageWithPath:imagePath]
    //                                                title:@"ShareSDK"
    //                                                  url:@"http://www.mob.com"
    //                                          description:@"这是一条演示信息"
    //                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSContent> publishContent = [ShareSDK content:_abstract
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:_title?_title:@""
                                                  url:[@"http://shejishi.hop8.com/share/article.php?id=" stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)_articleID]]
                                          description:@"设计狮——专属设计师的新闻客户端"
                                            mediaType:SSPublishContentMediaTypeNews];
    //1+创建弹出菜单容器（iPad必要）
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    //2、弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                //可以根据回调提示用户。
                                if (state == SSResponseStateSuccess)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                    message:nil
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                    message:[NSString stringWithFormat:@"失败描述：%@",[error errorDescription]]
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                            }];
}

#pragma mark - 点赞

- (IBAction)dianzanBtnClicked:(id)sender
{
    //3.向后台发数据
    NSDictionary *dic = [self.articleData sendADianzan:_articleID];
    if (dic) {
        //判断点赞是否成功
        id status = [dic objectForKey:@"status"];
        if ([status isKindOfClass:[NSString class]]) {
            if ([status isEqualToString:@"1"]) {
                //点赞成功
                //1.更换点赞图片
                self.dianzanImage.image = [UIImage imageNamed:@"button_zan_click"];
                //2.更新界面
                NSInteger dianzanCount = [self.dianzanLabel.text integerValue];
                dianzanCount++;
                [self.dianzanLabel setText:[NSString stringWithFormat:@"%ld", (long)dianzanCount]];
            } else {
                //点赞失败
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"您已经点过赞了哦";
                hud.minSize = CGSizeMake(120.0f, 120.0f);
                hud.margin = 20.0f;
                hud.yOffset = -50.0f;
                [hud show:YES];
                [hud hide:YES afterDelay:2.0f];
            }
        }
    }
}


#pragma mark 去除webView滚动顶部和底部的白边
//- (void)clearWebViewBackground:(UIWebView *)webView
//{
//    UIWebView *web = webView;
//    for (id v in web.subviews) {
//        if ([v isKindOfClass:[UIScrollView class]]) {
//            [v setBounces:NO];
//        }
//    }
//}

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
//    [self.scroller addSubview:self.topImageView];
//    id imageUrlString = [dic objectForKey:@"t_pic"];
//    if ([imageUrlString isKindOfClass:[NSString class]]) {
//        [self.topImageView setImageWithURL:[NSURL URLWithString:imageUrlString]];
//    }
    
    //2.显示评论数和点赞数
    id dianzanString = [dic objectForKey:@"like_count"];
    id pinglunString = [dic objectForKey:@"comment_count"];
    if ([dianzanString isKindOfClass:[NSString class]]) {
        self.dianzanLabel.text = dianzanString;
    }
    if ([pinglunString isKindOfClass:[NSString class]]) {
        self.commentLabel.text = pinglunString;
    }
    
    id dianzanStatus = [dic objectForKey:@"status"];
    if ([dianzanStatus isKindOfClass:[NSString class]]) {
        if ([dianzanStatus isEqualToString:@"1"]) {
            self.dianzanImage.image = [UIImage imageNamed:@"button_zan"];
        } else {
            self.dianzanImage.image = [UIImage imageNamed:@"button_zan_click"];
        }
    }
    
    //3.显示文章内容
    
    //(1).标题
    id title = [dic objectForKey:@"title"];
    
    _abstract = [dic objectForKey:@"abstract"];
    //(2).遮罩
    //UIImageView *zhezhaoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DEVICE_FRAME.width, TOPIMAGE_HEIGHT)];
    if ([title isKindOfClass:[NSString class]]) {
        _title = title;
//        if ([title length] < 15) {
//            [zhezhaoImageView setImage:[UIImage imageNamed:@"pic_zhezhao_small"]];
//        } else {
//            [zhezhaoImageView setImage:[UIImage imageNamed:@"pic_zhezhao"]];
//        }
//        [_topImageView addSubview:zhezhaoImageView];
        
//        self.articleTitle.text = title;
//        [_topImageView addSubview:self.articleTitle];
    } else {
//        self.articleTitle.text = @"文章加载失败";
//        [_topImageView addSubview:self.articleTitle];
    }
    
    NSString *urlString = [dic objectForKey:@"content"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.webView.scrollView isEqual:scrollView]) {
        if (scrollView.contentOffset.y > TOPIMAGE_HEIGHT + 20.0f) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.statusBarZheZhaoView.alpha = 1.0;
                             }];
            _isStatusBarZheZhaoViewAppear = YES;
          [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        } else {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.statusBarZheZhaoView.alpha = 0.0;
                             }];
            _isStatusBarZheZhaoViewAppear = NO;
          [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
    }
}


//- (UIWebView *)webView
//{
//    if (!_webView) {
//        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, TOPIMAGE_HEIGHT, DEVICE_FRAME.width, self.scroller.frame.size.height)];
//        _webView.delegate = self;
//        //        _webView.scalesPageToFit = YES;
//        _webView.scrollView.bounces = NO;
//        _webView.scrollView.scrollEnabled = NO;
//    }
//    
//    return _webView;
//}
//
//- (UIImageView *)topImageView
//{
//    if (!_topImageView) {
//        _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DEVICE_FRAME.width, TOPIMAGE_HEIGHT)];
//    }
//    
//    return _topImageView;
//}
//
//- (UILabel *)articleTitle
//{
//    if (!_articleTitle) {
//        _articleTitle = [[UILabel alloc] initWithFrame:CGRectMake(22.0f, TOPIMAGE_HEIGHT - 60.0f, DEVICE_FRAME.width - 47.0f, 60.0f)];
//        _articleTitle.textColor = [UIColor whiteColor];
//        _articleTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:21];
//        _articleTitle.numberOfLines = 0;
//    }
//    
//    return _articleTitle;
//}

- (UIView *)statusBarZheZhaoView
{
    if (!_statusBarZheZhaoView) {
        _statusBarZheZhaoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DEVICE_FRAME.width, 20.0f)];
        _statusBarZheZhaoView.backgroundColor = [UIColor whiteColor];
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
