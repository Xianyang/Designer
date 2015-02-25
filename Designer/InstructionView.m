//
//  InstructionView.m
//  Designer
//
//  Created by 罗 显扬 on 15/2/14.
//  Copyright (c) 2015年 罗 显扬. All rights reserved.
//

#import "InstructionView.h"

#define PAGE_CONTROL_WIDTH 26.0f
#define PAGE_CONTROL_HEIGHT 37.0f

#define DEVICE_FRAME [UIScreen mainScreen].bounds.size

@implementation InstructionView

- (id)initWithFrame:(CGRect)frame withPanelCount:(NSInteger)count
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildScrollViewWithFrame:frame];
        [self buildImageViews];
        [self buildPageControl];
    }
    
    return self;
}

- (void)buildScrollViewWithFrame:(CGRect)frame
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentSize = CGSizeMake(DEVICE_FRAME.width * 2, DEVICE_FRAME.height);
    
    [self addSubview:self.scrollView];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)buildImageViews
{
    self.imageViews = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null], nil];
}

- (void)buildPageControl
{
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((DEVICE_FRAME.width - PAGE_CONTROL_WIDTH) / 2, DEVICE_FRAME.height - 50.0f, PAGE_CONTROL_WIDTH, PAGE_CONTROL_HEIGHT)];
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    
    [self addSubview:self.pageControl];
}

- (void)showInView:(UIView *)view
{
    //Add introduction view
    self.alpha = 1;
    [view addSubview:self];
    
    //Fade in
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

-(void)hideWithFadeOutDuration
{
    //Fade out
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"pushtoCaipinList"];
}

//加载一个page
- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0) {
        return;
    }
    if (page >= 2) {
        return;
    }
    
    UIImageView *imageView = self.imageViews[page];
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        if (page) {
            if (DEVICE_FRAME.width == 414.0f) {
                imageView.image = [UIImage imageNamed:@"引导2-1242_2208"];
            } else if (DEVICE_FRAME.width == 375.0f) {
                imageView.image = [UIImage imageNamed:@"引导2-750_1334"];
            } else {
                if (DEVICE_FRAME.height == 480.0f) {
                    imageView.image = [UIImage imageNamed:@"引导2-640_960"];
                } else {
                    imageView.image = [UIImage imageNamed:@"引导2-640_1136"];
                }
            }
            
            imageView.userInteractionEnabled = YES;
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50.0f, DEVICE_FRAME.height - 110.0f, 210.0f, 70.0f)];
            button.backgroundColor = [UIColor clearColor];
            [button addTarget:self action:@selector(hideWithFadeOutDuration) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:button];
            
        } else {
            if (DEVICE_FRAME.width == 414.0f) {
                imageView.image = [UIImage imageNamed:@"引导1-1242_2208"];
            } else if (DEVICE_FRAME.width == 375.0f) {
                imageView.image = [UIImage imageNamed:@"引导1-750_1334"];
            } else {
                if (DEVICE_FRAME.height == 480.0f) {
                    imageView.image = [UIImage imageNamed:@"引导1-640_960"];
                } else {
                    imageView.image = [UIImage imageNamed:@"引导1-640_1136"];
                }
            }
        }
        
        [self.imageViews replaceObjectAtIndex:page withObject:imageView];
    }
    
    if (self.scrollView) {
        CGRect frame = self.scrollView.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        [imageView setFrame:frame];
        [self.scrollView addSubview:imageView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (_pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    //    [self loadScrollViewWithPage:page - 1];
    //    [self loadScrollViewWithPage:page];
    //    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}


@end
