//
//  CZJPageControlView.m
//  CZJShop
//
//  Created by Joe.Pen on 12/16/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJPageControlView.h"
#import "CZJPicDetailController.h"
#import "CZJBuyNoticeController.h"
#import "CZJHotRecoController.h"
#define BtnTag 1001

@interface CZJPageControlView()
<UIPageViewControllerDataSource,
UIPageViewControllerDelegate,
UIScrollViewDelegate>
{
    
}
@property (nonatomic, strong)  NSArray *btnArr;
@property(nonatomic,strong) NSMutableArray *viewControllerArray;
@property (nonatomic, strong)UIPageViewController *pageController;
@property (nonatomic, assign)NSInteger currentPageIndex;
@end

@implementation CZJPageControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        [self initMainController];
        [self setupPageViewController];
        return self;
    }
    return nil;
}
/**
 *  只需要修改的第一处
 */
- (NSArray *)btnArr{
    if (!_btnArr) {
        _btnArr =  @[@"图文详情",@"购买须知",@"热门推荐"];
    }
    return _btnArr;
}

/**
 *  只需要修改的第二处
 */
- (NSMutableArray *)viewControllerArray{
    if (!_viewControllerArray) {
        _viewControllerArray =
        _viewControllerArray = [[NSMutableArray alloc]init];
        CZJPicDetailController *FController = [[CZJPicDetailController alloc]init];
        CZJBuyNoticeController *SController = [[CZJBuyNoticeController alloc]init];
        CZJHotRecoController *TController = [[CZJHotRecoController alloc]init];
        
        [_viewControllerArray addObjectsFromArray:@[FController,SController,TController]];
    }
    return _viewControllerArray;
}


- (UIPageViewController *)pageController{
    if (!_pageController) {
        _pageController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageController.view.frame = CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 184);
        _pageController.delegate = self;
        _pageController.dataSource = self;
        
        [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:_currentPageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
    }
    return _pageController;
}
//初始化导航控制器
-(void)initMainController{
    for (int i = 0; i < self.btnArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGSize size = [self.btnArr[2] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
        [btn setTitle:self.btnArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        float horiMargin = (PJ_SCREEN_WIDTH - self.btnArr.count*size.width)/4;
        float originX = i * (size.width + horiMargin);
        btn.frame = CGRectMake(originX + horiMargin, 20, size.width, size.height);
        btn.tag = BtnTag + i;
        if (i == _currentPageIndex) {
            btn.selected = YES;

        }
        [btn addTarget:self action:@selector(changeControllerClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

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
-(void)changeControllerClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tempIndex = _currentPageIndex;
    __weak typeof (self) weakSelf = self;
    NSInteger nowTemp = btn.tag - BtnTag;
    if (nowTemp > tempIndex) {
        for (int i = (int)tempIndex + 1; i <= nowTemp; i ++) {
            [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf updateCurrentPageIndex:i];
                }
            }];
        }
    }else if (nowTemp < tempIndex){
        for (int i = (int)tempIndex ; i >= nowTemp; i--) {
            [_pageController setViewControllers:@[[self.viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf updateCurrentPageIndex:i];
                }
            }];
        }
    }
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
#pragma mark --------Scroll协议-------
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

#pragma mark - Page View Controller Data Source

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

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        _currentPageIndex = [self indexOfController:[pageViewController.viewControllers lastObject]];
        [self updateCurrentPageIndex:_currentPageIndex];
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
