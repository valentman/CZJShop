//
//  CZJPageControlView.m
//  CZJShop
//
//  Created by Joe.Pen on 12/16/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJPageControlView.h"
#define BtnTag 1001


@interface CZJPageControlView()
<UIPageViewControllerDataSource,
UIPageViewControllerDelegate,
UIScrollViewDelegate>
{
}
/**
 *  只需要修改的第一处
 */
@property (nonatomic, strong) NSArray *btnArr;
/**
 *  只需要修改的第二处,
 */
@property (nonatomic,strong) NSArray *viewControllerArray;
@property (nonatomic, strong)UIPageViewController *pageController;
@property (nonatomic, assign)NSInteger currentPageIndex;
@end

@implementation CZJPageControlView
@synthesize btnArr = _btnArr;
@synthesize viewControllerArray = _viewControllerArray;
- (instancetype)initWithFrame:(CGRect)frame andPageIndex:(NSInteger)pageIndex
{
    if (self == [super initWithFrame:frame])
    {
        _currentPageIndex = pageIndex;
        return self;
    }
    return nil;
}

- (void)setTitleArray:(NSArray*)titleArray andVCArray:(NSArray*)vcArray
{
    _btnArr = titleArray;
    _viewControllerArray = vcArray;
    if (_btnArr.count != 0 && _viewControllerArray != 0)
    {
        [self initMainController];
        [self setupPageViewController];
    }
    else
    {
        UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"无内容" message:@"" delegate:self cancelButtonTitle:@"确 定" otherButtonTitles:@"", nil];
        [alertview show];
    }
}


#pragma mark- 初始化PageViewController
-(void)setupPageViewController{
    [self addSubview:self.pageController.view];
    [self syncScrollView];
}

-(void)syncScrollView{
    for (UIView *view in self.pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *pageScrollView = (UIScrollView *)view;
            pageScrollView.delegate = self;
            pageScrollView.scrollsToTop=NO;
        }
    }
}

- (UIPageViewController *)pageController{
    if (!_pageController) {
        _pageController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageController.view.frame = ((nil == self.pageControlViewConfig) ? kGeneralPageControllerFrame : self.pageControlViewConfig.pageControllerFrame);
        _pageController.view.backgroundColor = ((nil == self.pageControlViewConfig) ? CLEARCOLOR : self.pageControlViewConfig.pageControllerBGColor);
        _pageController.delegate = self;
        _pageController.dataSource = self;
        
        [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:_currentPageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    return _pageController;
}


#pragma mark- 初始化顶部PageViewController导航按钮
-(void)initMainController{
    CGSize size = CGSizeMake(PJ_SCREEN_WIDTH / self.btnArr.count, 50);
    for (int i = 0; i < self.btnArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.btnArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:((nil == self.pageControlViewConfig) ? [UIColor darkGrayColor] : self.pageControlViewConfig.btnTitleColorNormal) forState:UIControlStateNormal];
        [btn setTitleColor:((nil == self.pageControlViewConfig) ? CZJREDCOLOR : self.pageControlViewConfig.btnTitleColorSelected) forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:(nil == self.pageControlViewConfig) ? 16 : self.pageControlViewConfig.btnTitleLabelSize];
        [btn setBackgroundColor:(nil == self.pageControlViewConfig) ?  CZJNAVIBARBGCOLOR : self.pageControlViewConfig.btnBackgroundColor];
        btn.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.numberOfLines = 2;
        float originX = i * size.width;
        btn.frame = CGRectMake(originX, 0, size.width, size.height);
        btn.tag = BtnTag + i;

        [btn addTarget:self action:@selector(changeControllerClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        if (i == _currentPageIndex)
        {
            btn.selected = YES;
        }

        //添加分隔线
        if (i < self.btnArr.count - 1)
        {
            UIView* line = [[UIView alloc]init];
            line.backgroundColor = [UIColor grayColor];
            line.frame = CGRectMake(originX + size.width, 20, 0.5, 10);
            [self addSubview:line];
        }
    }
}


#pragma mark 点击了pageController的按钮
-(void)changeControllerClick:(id)sender{
    UIView *btn = (UIView *)sender;
    NSInteger tempIndex = _currentPageIndex;
    __weak typeof (self) weakSelf = self;
    NSInteger nowTemp = btn.tag - BtnTag;
    /**
     * 这种方式只动画滑动一个页面
     */
    if (nowTemp > tempIndex)
    {
        [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:nowTemp]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            if (finished) {
                [weakSelf updateCurrentPageIndex:nowTemp];
                [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifikOrderListType object:nil userInfo:@{@"currentIndex" : [NSString stringWithFormat:@"%ld",nowTemp]}];
            }
        }];
    }
    else if (nowTemp < tempIndex)
    {
        [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:nowTemp]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
            if (finished) {
                [weakSelf updateCurrentPageIndex:nowTemp];
                [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifikOrderListType object:nil userInfo:@{@"currentIndex" : [NSString stringWithFormat:@"%ld",nowTemp]}];
            }
        }];
    }
    
    /**
     * 这种方式有多少个页面就动画滑动多少个页面
     */
    /*
    if (nowTemp > tempIndex) {
        for (int i = (int)tempIndex + 1; i <= nowTemp; i ++) {
            [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf updateCurrentPageIndex:i];
                    if (i == nowTemp)
                    {
                        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifikOrderListType object:nil userInfo:@{@"currentIndex" : [NSString stringWithFormat:@"%ld",nowTemp]}];
                    }
                }
            }];
        }
    }else if (nowTemp < tempIndex){
        for (int i = (int)tempIndex ; i >= nowTemp; i--) {
            [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf updateCurrentPageIndex:i];
                    if (i == nowTemp)
                    {
                        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifikOrderListType object:nil userInfo:@{@"currentIndex" : [NSString stringWithFormat:@"%ld",nowTemp]}];
                    }
                }
            }];
        }
    }
     */
}

-(void)updateCurrentPageIndex:(NSInteger)newIndex
{
    _currentPageIndex = newIndex;
    
    UIButton *btn = (UIButton *)[self viewWithTag:BtnTag+_currentPageIndex];
    for (int i = 0 ; i < self.btnArr.count; i ++) {
        UIButton *otherBtn = (UIButton *)[self viewWithTag:BtnTag + i];
        if (btn.tag == otherBtn.tag) {
            otherBtn.selected = YES;
        }else{
            otherBtn.selected = NO;
        }
    }
}


#pragma mark- UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger X = _currentPageIndex;
    UIButton *btn = (UIButton *)[self viewWithTag:X+BtnTag];
    [UIView animateWithDuration:0.2 animations:^{
        UIView *line = (UIView *)[self viewWithTag:2000];
        CGRect sizeRect = line.frame;
        sizeRect.origin.x = btn.frame.origin.x;
        line.frame = CGRectMake(btn.frame.origin.x, 64 - 2, btn.frame.size.width, 2);
    }];
}


#pragma mark UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    index--;
    return [_viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    index++;
    
    if (index == [_viewControllerArray count]) {
        return nil;
    }
    return [_viewControllerArray objectAtIndex:index];
}


#pragma mark UIPageViewControllerDelegate
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        _currentPageIndex = [self indexOfController:[pageViewController.viewControllers lastObject]];
        [self updateCurrentPageIndex:_currentPageIndex];
        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifikOrderListType object:nil userInfo:@{@"currentIndex" : [NSString stringWithFormat:@"%ld",_currentPageIndex]}];
        NSLog(@"当前界面是界面=== %ld",_currentPageIndex);
    }
}

-(NSInteger)indexOfController:(UIViewController *)viewController
{
    for (int i = 0; i<[_viewControllerArray count]; i++) {
        if (viewController == [_viewControllerArray objectAtIndex:i])
        {
            return i;
        }
    }
    return NSNotFound;
}

@end



@implementation CZJPageControlViewConfig
@end