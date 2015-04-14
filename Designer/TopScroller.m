//
//  TopScroller.m
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/13.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import "TopScroller.h"

#define DEVICE_FRAME [UIScreen mainScreen].bounds.size
#define TOPIMAGE_HEIGHT 213.0f

@interface TopScroller() <UIScrollViewDelegate>
{
    NSInteger _numberOfViews;
}


@property (strong, nonatomic) NSTimer *timer;

@end

@implementation TopScroller

- (void)setupScroller
{
    self.scroller.delegate = self;
    
    [self.scroller setPagingEnabled:YES];
    [self.scroller setShowsHorizontalScrollIndicator:NO];
    [self.scroller setShowsVerticalScrollIndicator:NO];
    [self.scroller setScrollsToTop:NO];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
    [self.scroller addGestureRecognizer:tapRecognizer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                  target:self
                                                selector:@selector(scrollToNextPage:)
                                                userInfo:nil
                                                 repeats:YES];
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)reload
{
    // 0
    _numberOfViews = [self.delegate numberOfViewsForTopScroller:self];
    
    // 1
    if (self.delegate == nil) return;
    
    // 2 - remove all subviews
    [self.scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    // 3 - add subviews to scrollview
    for (unsigned int i = 0; i < _numberOfViews + 2; i++) {
        UIView *view = [[UIView alloc] init];
        // 添加最后一张图片，来循环
        if (i == 0) {
            view = [self.delegate topScroller:self viewAtFirstOfLast:NO];
        } else if (i == _numberOfViews + 1) {
            view = [self.delegate topScroller:self viewAtFirstOfLast:YES];
        } else {
            view = [self.delegate topScroller:self viewAtIndex:i - 1];
        }
        
        view.frame = CGRectMake(i * DEVICE_FRAME.width, 0.0f, DEVICE_FRAME.width, TOPIMAGE_HEIGHT);
        
        [self.scroller addSubview:view];
    }
    
    // 4
    [self.scroller setContentSize:CGSizeMake(DEVICE_FRAME.width * (_numberOfViews + 2), TOPIMAGE_HEIGHT)];
    [self.scroller setContentOffset:CGPointMake(DEVICE_FRAME.width, 0) animated:NO];
    
    // 5
    [self.pageControl setNumberOfPages:_numberOfViews];
    [self.pageControl setCurrentPage:0];
    
    // 6 - start timer
    [self.timer setFireDate:[NSDate date]];
}

//自动翻页到下一页
- (void)scrollToNextPage:(id)sender
{
    NSInteger pageNum = self.pageControl.currentPage;
    CGRect frame = self.scroller.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    frame.origin.y = 0.0f;
    frame.origin.x = frame.size.width * (pageNum + 2);
//    [self.scroller scrollRectToVisible:frame animated:YES];
//    pageNum++;
    
//    if (pageNum == [self.delegate numberOfViewsForTopScroller:self]) {
//        frame.origin.x = 0.0f;
//    }
    [self.scroller scrollRectToVisible:frame animated:YES];
}

//点击
- (void)scrollerTapped:(UITapGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];
    
    for (int index = 1; index < _numberOfViews + 1; index++) {
        UIView *view = self.scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location)) {
            [self.delegate topScroller:self clickedViewAtIndex:index - 1];
            break;
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if ([sender isEqual:self.scroller]) {
        if (_numberOfViews >= 1) {
            float targetX = sender.contentOffset.x;
            if (targetX <= 0) {
                targetX = _numberOfViews * DEVICE_FRAME.width;
                [sender setContentOffset:CGPointMake(targetX, 0) animated:NO];
            } else if (targetX >= (_numberOfViews + 1) * DEVICE_FRAME.width){
                targetX = DEVICE_FRAME.width;
                [sender setContentOffset:CGPointMake(targetX, 0) animated:NO];
            }
        }
        
        CGFloat pageWidth = self.scroller.frame.size.width;
        int page = floor((self.scroller.contentOffset.x - pageWidth / 2) / pageWidth);
        if (page != self.pageControl.currentPage) {
            self.pageControl.currentPage = page;
        }
    }
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scroller]) {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([scrollView isEqual:self.scroller]) {
        [self.timer setFireDate:[[NSDate date] dateByAddingTimeInterval:5.0]];
    }
}

@end
