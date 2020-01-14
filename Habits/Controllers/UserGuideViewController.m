//
//  UserGuideViewController.m
//  Habits
// THIS IS NOT USED ANY MORE, INSTEAD WE HAVE A VIDEO
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "UserGuideViewController.h"
#import "Colors.h"

@interface UserGuideViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
@property (nonatomic, strong) UIPageViewController * pageViewController;
@property (nonatomic, strong) NSArray * pageFilenames;
@property (nonatomic, strong) UIPageControl * pageControl;
@end

@implementation UserGuideViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"User guide";
    self.view.backgroundColor = [UIColor blackColor];
    NSError * error;
    self.pageFilenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] pathForResource:@"grabs" ofType:nil] error:&error];
    if(error){
        NSLog(@"Error reading info files %@", error);
    }
    UIPageViewController * pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageViewController.delegate = self;
    pageViewController.dataSource = self;
    self.pageViewController = pageViewController;
    
    [self addChildViewController:pageViewController];
    [pageViewController didMoveToParentViewController:self];

    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.view addSubview:pageViewController.view];
    
    [pageViewController setViewControllers:@[[self viewControllerAtIndex: 0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 40)];
    [self.view addSubview:self.pageControl];
    self.pageControl.pageIndicatorTintColor = [[Colors blue] colorWithAlphaComponent:0.5];
    self.pageControl.currentPageIndicatorTintColor = [Colors blue];
    self.pageControl.numberOfPages = self.pageFilenames.count;
    
    
    UIBarButtonItem * nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(didPressNext)];
    self.navigationItem.rightBarButtonItem = nextButton;
}
-(void)didPressNext{
    NSInteger index = [self indexOfViewController:self.pageViewController.viewControllers.firstObject];
    if(index > self.pageFilenames.count - 1) return;
    self.navigationItem.rightBarButtonItem.enabled = index + 1 < self.pageFilenames.count - 1;
    __weak UserGuideViewController * welf = self;
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:index + 1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        [welf updatePageControl];
    }];
}
-(NSInteger)indexOfViewController:(UIViewController*)controller{
    NSString * title = controller.title;
    NSInteger index = [self.pageFilenames indexOfObject:title];
    return  index;
}
-(UIViewController*)viewControllerAtIndex:(NSInteger)index{
    if (index > self.pageFilenames.count - 1 || index < 0) {
        return nil;
    }
    UIViewController * result = [UIViewController new];
    NSString * filename = self.pageFilenames[index];
    UIImage * image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil inDirectory:@"grabs"]];
    result.title = filename;
    UIView * container = [[UIView alloc] initWithFrame:self.pageViewController.view.bounds];
    result.view = container;
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectInset(container.bounds, 40, 80);
    [container addSubview:imageView];
    return result;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
{
    NSInteger index = [self.pageFilenames indexOfObject:viewController.title];
    assert(index != NSNotFound);
    return [self viewControllerAtIndex:index-1];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;
{
    NSInteger index = [self.pageFilenames indexOfObject:viewController.title];
    assert(index != NSNotFound);
    return [self viewControllerAtIndex:index+1];
}
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    [self updatePageControl];
}
-(void)updatePageControl{
    NSString * title = [[self.pageViewController.viewControllers lastObject] title];
    NSInteger index = [self.pageFilenames indexOfObject:title];
    self.pageControl.currentPage = index;
    self.navigationItem.rightBarButtonItem.enabled = index < self.pageFilenames.count - 1;

}
@end
