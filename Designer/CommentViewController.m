//
//  CommentViewController.m
//  Designer
//
//  Created by 罗 显扬 on 12/2/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentCell.h"
#import "GetArticleData.h"
#import "CommentModel.h"
#import "WriteCommentViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>

#define DEVICE_FRAME [UIScreen mainScreen].bounds.size

static NSString *CommentCellIdentifier = @"CommentCell";

@interface CommentViewController () <UITableViewDataSource, UITableViewDelegate, WriteCommentViewControllerDelegate>
{
    NSInteger _articleID;
    
    NSInteger _commentCount;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *writeCommentButton;
@property (weak, nonatomic) IBOutlet UIImageView *shafaImgView;
@property (strong, nonatomic) GetArticleData *articleData;
@property (strong, nonatomic) CommentModel *allComment;

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    
    [self performSelectorInBackground:@selector(loadArticleCommentData) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)setArticleID:(NSInteger)articleID
{
    _articleID = articleID;
}

- (void)popViewController
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 加载评论数据

- (void)loadArticleCommentData
{
    NSDictionary *dic = [self.articleData getCommentData:_articleID];
    
    if (dic) {
        [self performSelectorOnMainThread:@selector(finishLoadArticleCommentData:)
                               withObject:dic
                            waitUntilDone:NO];
    } else {
        //TODO加载文章数据失败
    }
}

- (void)finishLoadArticleCommentData:(NSDictionary *)dic
{
    id commentArray = [[dic objectForKey:@"comment_array"] mutableCopy];
    if ([commentArray isKindOfClass:[NSMutableArray class]]) {
        //将评论数组倒序
        NSArray *reversedArray = [[commentArray reverseObjectEnumerator] allObjects];
        if ([reversedArray count] > 0) {
            _commentCount = [reversedArray count];
            
            [self.allComment.commentTimes removeAllObjects];
            [self.allComment.commentUserName removeAllObjects];
            [self.allComment.commentContents removeAllObjects];
            [self.allComment.commentAvatars removeAllObjects];
            
            for (NSDictionary *aDic in reversedArray) {
                id comment = [aDic objectForKey:@"comment"];
                if ([comment isKindOfClass:[NSString class]]) {
                    [self.allComment.commentContents addObject:comment];
                }
                id userName = [aDic objectForKey:@"who"];
                if ([userName isKindOfClass:[NSString class]]) {
                    [self.allComment.commentUserName addObject:userName];
                } else {
                    [self.allComment.commentUserName addObject:@"设机师"];
                }
                id time = [aDic objectForKey:@"time"];
                if ([time isKindOfClass:[NSString class]]) {
                    [self.allComment.commentTimes addObject:time];
                }
                id avatar = [aDic objectForKey:@"avatar"];
                if ([avatar isKindOfClass:[NSString class]]) {
                    [self.allComment.commentAvatars addObject:avatar];
                }
            }
            
            [self.tableview reloadData];
        } else {
            //TODO无评论
            [self.shafaImgView setHidden:NO];
        }
    }
}

#pragma mark - delegate

- (void)dimissWriteCommentController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)writeCommentControllerDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadCommentData:(CommentModel *)allComment
{
    self.allComment = allComment;
    [self.tableview reloadData];
    NSLog(@"reload comment");
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static CommentCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableview dequeueReusableCellWithIdentifier:CommentCellIdentifier];
    });
    
    [self setContent:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.allComment.commentTimes count]) {
        [self.shafaImgView setHidden:YES];
        return [self.allComment.commentTimes count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableview]) {
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier
                                                            forIndexPath:indexPath];
        [self setContent:cell atIndexPath:indexPath];
        return cell;
    } else {
        return nil;
    }
}

- (void)setContent:(CommentCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.userNameOfComment.text = self.allComment.commentUserName[indexPath.row];
    cell.timeOfComment.text = self.allComment.commentTimes[indexPath.row];
    cell.contentOfComment.text = self.allComment.commentContents[indexPath.row];
    [cell.touxiangImage setImageWithURL:[NSURL URLWithString:self.allComment.commentAvatars[indexPath.row]] placeholderImage:[UIImage imageNamed:@"placeholder_touxiang"]];
    cell.touxiangImage.layer.masksToBounds = YES;
    cell.touxiangImage.layer.cornerRadius = 15.0f;
    
    [cell.contentOfComment preferredMaxLayoutWidth];
    CGFloat preferrdMaxLayoutWidth = DEVICE_FRAME.width - 80.0f;
    [cell.contentOfComment setPreferredMaxLayoutWidth:preferrdMaxLayoutWidth];
}

- (CommentModel *)allComment
{
    if (!_allComment) _allComment = [[CommentModel alloc] init];
    return _allComment;
}

- (GetArticleData *)articleData
{
    if (!_articleData) _articleData = [[GetArticleData alloc] init];
    return _articleData;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PresentWriteCommentViewSegue"]) {
        UINavigationController *navigationC = segue.destinationViewController;
        WriteCommentViewController *writeCommentViewController = navigationC.viewControllers[0];
        writeCommentViewController.delegate = self;
        [writeCommentViewController setArticleID:_articleID];
    }
}


@end
