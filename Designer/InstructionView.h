//
//  InstructionView.h
//  Designer
//
//  Created by 罗 显扬 on 15/2/14.
//  Copyright (c) 2015年 罗 显扬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionView : UIView <UIScrollViewDelegate>
{
    BOOL _pageControlUsed;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *imageViews;

- (id)initWithFrame:(CGRect)frame withPanelCount:(NSInteger)count;
- (void)showInView:(UIView *)view;

@end