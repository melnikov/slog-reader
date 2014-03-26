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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MKStoreManager sharedManager];

    [[NWDataModel sharedModel] loadState];

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
    
    UITabBarItem* tab = [_tabBarController.tabBar.items objectAtIndex:0];
    [tab setImage:[UIImage imageNamed:@"store_tab.png"]];
    [tab setTitle:NSLocalizedString(@"IDS_BOOKSTORE_TAB_TITLE",@"")];
    
    tab = [_tabBarController.tabBar.items objectAtIndex:1];
    [tab setImage:[UIImage imageNamed:@"search_tab.png"]];
    [tab setTitle:NSLocalizedString(@"IDS_SEARCH_TAB_TITLE",@"")];

    tab = [_tabBarController.tabBar.items objectAtIndex:2];
    [tab setImage:[UIImage imageNamed:@"mybooks_tab.png"]];
    [tab setTitle:NSLocalizedString(@"IDS_MY_BOOKS_TITLE",@"")];

    tab = [_tabBarController.tabBar.items objectAtIndex:3];
    [tab setImage:[UIImage imageNamed:@"help_tab.png"]];
    [tab setTitle:NSLocalizedString(@"IDS_HELP",@"")];
    
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
    rootView.layer.borderWidth = 1.0f;
    rootView.layer.cornerRadius =5.0f;

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
