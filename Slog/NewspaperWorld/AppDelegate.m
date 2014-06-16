//
//  AppDelegate.m
//  Slog
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "BooksListViewController.h"
#import "SplitMasterViewController.h"
#import "SplashViewController.h"
#import "SearchViewController.h"
#import "DummyViewController.h"
#import "HelpViewController.h"
#import "MyBooksViewController.h"
#import "MyBooksListViewController.h"
#import "DemoFragmentsViewController.h"
#import "Constants.h"
#import "Utils.h"
#import "NWApiClient.h"
#import "NWDataModel.h"
#import "MKStoreManager.h"
#import "UIDevice+IdentifierAddition.h"
#import <QuartzCore/QuartzCore.h>

#define MASTER_INDEX        0
#define DETAIL_INDEX        1
#define SEARCH_INDEX        2
#define HELP_INDEX          3
#define BOOKLIST_INDEX      4
#define LAST_READED_INDEX   5
#define FRAGMENTS_INDEX     6
#define MY_BOOKS_INDEX      7

@interface AppDelegate(Private)

- (void)initializeSplitView;

- (void)initializeTabBar;

- (void)handleNotification:(NSNotification*)notification;

- (void)replaceViewControllerFromIndex:(int)index;

- (UINavigationController*)createNavigationViewControllerWithRoot:(UIViewController*)root;

- (void)authorizeApplication;

- (void)getCategories;

- (void)getPurchasedBooks;

- (void)showMainViewController;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;
@synthesize tabBarController = _tabBarController;
@synthesize detailNavigationController = _detailNavigationController;
@synthesize hyphenator = _hyphenator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[MKStoreManager sharedManager];

    [[NWDataModel sharedModel] loadState];
    
    _hyphenator = [SGHyphenator sharedInstance];
    [_hyphenator setPatternFile:@"hyphens_ru"];

    _viewControllers = [[NSMutableArray alloc] init];
    _tabBarController    = nil;
    _splitViewController = nil;
    _detailNavigationController = nil;
    _lastNetworkOperationSelector = nil;

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
    }
    else
    {
        _notificationsViewControllers = [[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SEARCH_INDEX],      SEARCH_SHOULDSHOW_NOTIFICATION,
                                                                                    [NSNumber numberWithInt:HELP_INDEX],        HELP_SHOULDSHOW_NOTIFICATION,
                                                                                    [NSNumber numberWithInt:BOOKLIST_INDEX],    BOOKLIST_SHOULDSHOW_NOTIFICATION,
                                                                                    [NSNumber numberWithInt:LAST_READED_INDEX], LAST_READED_SHOULDSHOW_NOTIFICATION,
                                                                                    [NSNumber numberWithInt:FRAGMENTS_INDEX],   FRAGMENTS_SHOULDSHOW_NOTIFICATION,
                                                                                    [NSNumber numberWithInt:MY_BOOKS_INDEX],    MY_BOOKS_SHOULDSHOW_NOTIFICATION, nil] retain];
        for (NSString* notificationID in [_notificationsViewControllers allKeys])
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:notificationID object:nil];
        }
    }
    [self authorizeApplication];
    [self.window makeKeyAndVisible];

    [[NWDataModel sharedModel].demoFragmentsCache load];
    [[NWDataModel sharedModel].purchasedBooksCache load];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"didEnterBackground" object: nil userInfo: nil];
    [[NWDataModel sharedModel].demoFragmentsCache save];
    [[NWDataModel sharedModel].purchasedBooksCache save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([NWDataModel sharedModel].demoFragmentsCache == nil)
        [[NWDataModel sharedModel].demoFragmentsCache load];

    if ([NWDataModel sharedModel].purchasedBooksCache == nil)
        [[NWDataModel sharedModel].purchasedBooksCache load];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_viewControllers release];
    [_tabBarController release];
    [_notificationsViewControllers release];
    [_splitViewController release];
}


#pragma mark Public implementation

+ (AppDelegate*)sharedAppDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark Private implementation

- (void)initializeTabBar
{
    if (!_tabBarController)
        _tabBarController = [[UITabBarController alloc] init];
    
    [_viewControllers removeAllObjects];
    //store
    [_viewControllers addObject:[self createNavigationViewControllerWithRoot:[BookCategoriesViewController createViewController]]];
    //search
    [_viewControllers addObject:[self createNavigationViewControllerWithRoot:[SearchViewController createViewController]]];  
     //My books
    [_viewControllers addObject:[self createNavigationViewControllerWithRoot:[MyBooksViewController createViewController]]];
     //help  
    [_viewControllers addObject:[self createNavigationViewControllerWithRoot:[HelpViewController createViewController]]];
    
    _tabBarController.viewControllers = _viewControllers;
	
	_tabBarController.tabBar.tintColor = RGB(136, 24, 17);
	
	_tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tab_background.png"];
	
	if(IS_OS_7_OR_LATER)
	{
		_tabBarController.tabBar.translucent = YES;
		
		_tabBarController.tabBar.opaque = YES;
		
		_tabBarController.tabBar.layer.backgroundColor = [UIColor clearColor].CGColor;
		
		_tabBarController.tabBar.backgroundColor = [UIColor clearColor];
		
		_tabBarController.tabBar.barTintColor = [UIColor clearColor];
		
		[_tabBarController.tabBar setShadowImage:[[UIImage new] autorelease]];
		
		for(CALayer* sublayer in _tabBarController.tabBar.layer.sublayers)
		{
			sublayer.backgroundColor = [UIColor clearColor].CGColor;
		}
		
//		((UIViewController*)_viewControllers[0]).extendedLayoutIncludesOpaqueBars = NO;
//		((UIViewController*)_viewControllers[1]).extendedLayoutIncludesOpaqueBars = NO;
//		((UIViewController*)_viewControllers[2]).extendedLayoutIncludesOpaqueBars = NO;
//		((UIViewController*)_viewControllers[3]).extendedLayoutIncludesOpaqueBars = NO;
//		
//		((UIViewController*)_viewControllers[0]).automaticallyAdjustsScrollViewInsets = NO;
//		((UIViewController*)_viewControllers[1]).automaticallyAdjustsScrollViewInsets = NO;
//		((UIViewController*)_viewControllers[2]).automaticallyAdjustsScrollViewInsets = NO;
//		((UIViewController*)_viewControllers[3]).automaticallyAdjustsScrollViewInsets = NO;
//		
//		((UIViewController*)_viewControllers[0]).edgesForExtendedLayout = UIRectEdgeNone;
//		((UIViewController*)_viewControllers[1]).edgesForExtendedLayout = UIRectEdgeNone;
//		((UIViewController*)_viewControllers[2]).edgesForExtendedLayout = UIRectEdgeNone;
//		((UIViewController*)_viewControllers[3]).edgesForExtendedLayout = UIRectEdgeNone;
	}
	else
	{
		UIImageView * iv = [[UIImageView alloc] initWithFrame:_tabBarController.view.frame];
		
		iv.image = [UIImage imageNamed:@"tab_controller_bg.png"];
		
		iv.contentMode = UIViewContentModeScaleAspectFill;
		
		iv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
		//[_tabBarController.view addSubview:iv];
		
		[_tabBarController.view insertSubview:iv atIndex:0];
		
		_tabBarController.view.backgroundColor = [UIColor whiteColor];
		
		_tabBarController.tabBar.superview.backgroundColor = [UIColor whiteColor];
	}
		
	[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
													   //[UIFont fontWithName:@"AmericanTypewriter" size:20.0f], UITextAttributeFont,
													   [UIColor whiteColor], UITextAttributeTextColor,
													   //[UIColor grayColor], UITextAttributeTextShadowColor,
													   //[NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
													   nil]/*[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,  [UIColor yellowColor], NSForegroundColorAttributeName,nil]*/ forState:UIControlStateNormal];
	
	[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
													   //[UIFont fontWithName:@"AmericanTypewriter" size:20.0f], UITextAttributeFont,
													   [UIColor whiteColor], UITextAttributeTextColor,
													   //[UIColor grayColor], UITextAttributeTextShadowColor,
													   //[NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
													   nil]/*[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,  [UIColor yellowColor], NSForegroundColorAttributeName,nil]*/ forState:UIControlStateNormal];
	
//	[[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor yellowColor] }
//                                             forState:UIControlStateNormal];
//    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
//                                             forState:UIControlStateSelected];
	
	[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGB(136, 24, 17), UITextAttributeTextColor,nil] forState:UIControlStateSelected];
	
    UITabBarItem* tab = [_tabBarController.tabBar.items objectAtIndex:0];
    [tab setTitle:NSLocalizedString(@"IDS_BOOKSTORE_TAB_TITLE",@"")];
	
	if(IS_OS_7_OR_LATER)
	{
		[tab setImage:[[UIImage imageNamed:@"store_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		[tab setSelectedImage:[UIImage imageNamed:@"store_tab_selected.png"]];
	}
	else
	{
		[tab setFinishedSelectedImage:[UIImage imageNamed:@"store_tab_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"store_tab.png"]];
	}
    
    tab = [_tabBarController.tabBar.items objectAtIndex:1];
	[tab setTitle:NSLocalizedString(@"IDS_SEARCH_TAB_TITLE",@"")];

	if(IS_OS_7_OR_LATER)
	{
		[tab setImage:[[UIImage imageNamed:@"search_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		[tab setSelectedImage:[UIImage imageNamed:@"search_tab_selected.png"]];
	}
	else
	{
		[tab setFinishedSelectedImage:[UIImage imageNamed:@"search_tab_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"search_tab.png"]];
	}
	
    tab = [_tabBarController.tabBar.items objectAtIndex:2];
    [tab setTitle:NSLocalizedString(@"IDS_MY_BOOKS_TITLE",@"")];

	if(IS_OS_7_OR_LATER)
	{
		[tab setImage:[[UIImage imageNamed:@"mybooks_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		[tab setSelectedImage:[UIImage imageNamed:@"mybooks_tab_selected.png"]];
	}
	else
	{
		[tab setFinishedSelectedImage:[UIImage imageNamed:@"mybooks_tab_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"mybooks_tab.png"]];
	}
	
    tab = [_tabBarController.tabBar.items objectAtIndex:3];
    [tab setTitle:NSLocalizedString(@"IDS_HELP",@"")];
    
	if(IS_OS_7_OR_LATER)
	{
		[tab setImage:[[UIImage imageNamed:@"help_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		[tab setSelectedImage:[UIImage imageNamed:@"help_tab_selected.png"]];
	}
	else
	{
		[tab setFinishedSelectedImage:[UIImage imageNamed:@"help_tab_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"help_tab.png"]];
	}
	
    if ([NWDataModel sharedModel].categories.count == 0)
    {
        _tabBarController.selectedIndex = 2;
    }
}

- (void)initializeSplitView
{
    if (!_splitViewController)
        _splitViewController = [[UISplitViewController alloc] init];
    
    [_viewControllers removeAllObjects];
    //master
    [_viewControllers addObject:[SplitMasterViewController createViewController]];
    
    //detail    
    [_viewControllers addObject:[DummyViewController createViewController]];

    //search
    [_viewControllers addObject:[SearchViewController createViewController]];
    
    //help  
    [_viewControllers addObject:[HelpViewController createViewController]];
       
    //Booklist
    [_viewControllers addObject:[BooksListViewController createViewController]]; 
       
    //Last readed   
    [_viewControllers addObject:[DummyViewController createViewController]];
       
    //Fragments   
    [_viewControllers addObject:[DemoFragmentsViewController createViewController]];
    
    //My books list
    [_viewControllers addObject:[MyBooksListViewController createViewController]];
    
        
    NSMutableArray* newViewControllers = [NSMutableArray array];
    UIViewController* masterNavigationController = [self createNavigationViewControllerWithRoot:[_viewControllers objectAtIndex:MASTER_INDEX]];
    [newViewControllers addObject:masterNavigationController];
    
    self.detailNavigationController = [self createNavigationViewControllerWithRoot:[_viewControllers objectAtIndex:DETAIL_INDEX]];

    UIView *rootView = [masterNavigationController view];
    rootView.layer.borderWidth = 0.0f;
    rootView.layer.cornerRadius =0.0f;

    [newViewControllers addObject:self.detailNavigationController];
     
    _splitViewController.viewControllers = newViewControllers;
    
    [self replaceViewControllerFromIndex:MY_BOOKS_INDEX];
}

- (void)handleNotification:(NSNotification*)notification
{
    NSNumber* viewControllerNumber = [_notificationsViewControllers objectForKey:notification.name];
    if (!viewControllerNumber)
        return;
    
    int viewControllerIndex = [viewControllerNumber intValue];
    BaseViewController* baseViewController = [_viewControllers objectAtIndex:viewControllerIndex];
    if (notification.userInfo && [notification.userInfo.allValues count] > 0)
    {
        NSObject* classDescription = [notification.userInfo.allValues objectAtIndex:0];
        [baseViewController initializeWithClassDescription:classDescription];
    }
    
    [self replaceViewControllerFromIndex:viewControllerIndex];    
}

- (void)replaceViewControllerFromIndex:(int)index
{   
    if (index >= [_viewControllers count])
        return;
        
    BaseViewController* baseViewController = [_viewControllers objectAtIndex:index];
    [baseViewController viewWillAppear:YES];
    [self.detailNavigationController setViewControllers:[NSArray arrayWithObjects:baseViewController, nil] animated:YES];    
    [baseViewController viewDidAppear:YES];
}

- (UINavigationController*)createNavigationViewControllerWithRoot:(UIViewController*)root
{
    return  [[[UINavigationController alloc] initWithRootViewController:root] autorelease];
}

- (void)authorizeApplication
{
    [SplashViewController showSplashWithText:NSLocalizedString(@"IDS_APPLICATION_AUTHORIZATION",@"")];
    NSString* uid = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    [[NWApiClient sharedClient] authorizeApplicationWithUID:uid delegate:self];
    _lastNetworkOperationSelector = @selector(authorizeApplication);
}

- (void)getCategories
{
    [SplashViewController showSplashWithText:NSLocalizedString(@"IDS_LOADING_CATEGORIES",@"")];
    [[NWApiClient sharedClient] getCategoriesWithDelegate:self];
    _lastNetworkOperationSelector = @selector(getCategories);
}

- (void)showMainViewController
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self initializeTabBar];
        self.window.rootViewController = self.tabBarController;
    }
    else
    {
        [self initializeSplitView];
        self.window.rootViewController = self.splitViewController;
    }
}

#pragma mark NewspaperApiClientDelegate methods

- (void)apiClientReceivedToken:(NSString*)token
{
    [self getCategories];
}

- (void)apiClientReceivedCategories:(NWCategories*)categories
{
    [NWDataModel sharedModel].categories = categories;
    [SplashViewController hideSplash];
    [self showMainViewController];
}

- (void)apiClientDidFailedExecuteMethod:(NSString*)methodName error:(NSError*)error
{
    [SplashViewController hideSplash]; 
    [self showMainViewController];
}

#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:NSLocalizedString(@"IDS_NETWORK_ERROR_OCCURED",@"")])
    {
        [self performSelector:_lastNetworkOperationSelector];
    }
}


@end
