/*******************************************************************************
 *
 * Copyright 2012 Zack Grossbart
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************/

#import "MainPageViewController.h"
#import "MainSectionViewController.h"
#import "LevelMgr.h"
#import "StyleUtil.h"

@interface MainPageViewController () {
    bool _pageControlUsed;
}

@property (nonatomic, retain, readwrite) NSMutableArray *views;
@property (readwrite, retain) MainMenuViewController *menuView;

@end

@implementation MainPageViewController

- (id)initWithNibNameAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*) menuView {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.views = [NSMutableArray arrayWithCapacity:[[LevelMgr getLevelMgr].levelSets count]];
        _pageControlUsed = NO;
        self.menuView = menuView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [StyleUtil styleMenuButton:self.backBtn];
    
	_scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * [[LevelMgr getLevelMgr].levelSets count], _scrollView.frame.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    
    _pageControl.numberOfPages = [[LevelMgr getLevelMgr].levelSets count];
    _pageControl.currentPage = 0;
    
    [self loadScrollViewWithPage:0];
    
    self.view.alpha = 0;
    
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:0.5];
    self.view.alpha = 1;
    [UIView commitAnimations];

}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
    
    //NSLog(@"page: %d", page);
    
    //[self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= [[LevelMgr getLevelMgr].levelSets count]) return;
    
    if (_pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        //return;
    }
	
    // replace the placeholder if necessary
    MainSectionViewController *controller = nil;
    
    if (page < [self.views count]) {
        controller = [self.views objectAtIndex:page];
    } else {
        controller = [[[MainSectionViewController alloc] initWithNibAndMenuView:nil bundle:nil menu:self.menuView index:page] autorelease];
        [self.views addObject:controller];
    }    
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [_scrollView addSubview:controller.view];
        controller.label.text = [LevelMgr getLevelSet:page].name;
        [controller.playBtn setImage:[UIImage imageNamed: [LevelMgr getLevelSet:page].imageName] forState:UIControlStateNormal];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

- (IBAction)pageChanged:(id)sender {
    int page = _pageControl.currentPage;
    NSLog(@"page: %d", page);
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    // update the scroll view to the appropriate page
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
}

- (IBAction)backToMainTapped:(id)sender {
    [self.menuView backToMainTapped:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_scrollView release];
    [self.views release];
    [_pageControl release];
    [self.menuView release];
    [_backBtn release];
    [super dealloc];
}

@end
