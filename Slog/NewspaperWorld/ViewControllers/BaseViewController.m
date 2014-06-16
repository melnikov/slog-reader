//
//  BaseViewController.m
//  NewspaperWorld
//


#import "BaseViewController.h"
#import "Utils.h"
#import "UIStyleManager.h"
#import "NWApiErrors.h"
#import "Constants.h"
#import "NWBookCard.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "NWBookCacheItem.h"
#import "ReadBookViewController.h"
#import "NWBooksCache.h"
#import "ReaderViewController.h"
#import "AppDelegate.h"

static BOOL _staticMasterIsVisible = NO;
static NSMutableArray* _detailControllers = nil;


static void releaseDetailsArray()
{
    [_detailControllers release];
    _detailControllers = nil;
}

@interface BaseViewController()
@end

@implementation BaseViewController

@synthesize navigationRootViewController;

#pragma mark Memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = ([Utils isDeviceiPad]) ? [nibNameOrNil stringByAppendingString:@"_iPad"] : [nibNameOrNil stringByAppendingString:@"_iPhone"];
       
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _errorAlert = nil;
        _isDetailViewController = YES;
    }
    return self;
}

- (void)dealloc
{
    [_masterButton release];
    [super dealloc];
}

#pragma mark View life-cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if (self.navigationController.navigationBar)
	{
        [[UIStyleManager instance] applyStyle:@"NavigationBar_iPad" toView:self.navigationController.navigationBar];
		
		if([Utils isDeviceiPad])
		{
			[self.navigationController.navigationBar setBackgroundImage:[[UIImage new] autorelease] forBarMetrics:UIBarMetricsDefault];
		}
		else
		{
			if(IS_OS_5_OR_LATER)
				[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_background.png"] forBarMetrics:UIBarMetricsDefault];
			
			if(IS_OS_7_OR_LATER)
				[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_background_ios7.png"] forBarMetrics:UIBarMetricsDefault];
		}
		
		if(IS_OS_6_OR_LATER)
			[self.navigationController.navigationBar setShadowImage:[[UIImage new] autorelease]];
		
		[self.navigationController.navigationBar setTintColor:RGB(180, 6, 16)];
		
		if(IS_OS_6_OR_LATER)
			self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : RGB(180, 6, 16)};
	}

    [self initializeDetailViewController];
	
	background = [[UIImageView alloc] initWithFrame:self.view.frame];
	
	background.contentMode = UIViewContentModeScaleToFill;
	
	background.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	if(!background.superview)
	{
		[self.view insertSubview:background atIndex:0];
		
		background.frame = self.view.frame;
		
		CGRect rect = background.frame;
		
		rect.origin.y = -self.navigationController.navigationBar.frame.size.height;
		
		rect.size.height += self.navigationController.navigationBar.frame.size.height;
		
		background.frame = rect;
	}
}

- (void)initializeDetailViewController
{
    if (!self.isDetailViewController || ![Utils isDeviceiPad])
        return;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSwipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    [swipeLeft release];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(handleSwipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    [swipeRight release];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleTap)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    [tap release];

    if (!_detailControllers)
    {
        _detailControllers = [[NSMutableArray alloc] init];
        atexit(releaseDetailsArray);
    }
    if (![_detailControllers containsObject:self])
        [_detailControllers addObject:self];
}

- (oneway void)release
{

    if (self.isDetailViewController && [Utils isDeviceiPad] && self.retainCount == 2)
    {  
        [_detailControllers removeObject:self];
    }
    [super release];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (UIInterfaceOrientationIsPortrait(self.statusBarOrientation))
    {
        [BaseViewController addMasterButtonForAll];
    }
    else
    {
        [BaseViewController removeMasterButtonForAll];
    }
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
//        [self.navigationController popViewControllerAnimated:animated];
//    }
//	
//	[super viewWillDisappear:animated];
//}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return  UIInterfaceOrientationLandscapeLeft |
            UIInterfaceOrientationLandscapeRight |
            UIInterfaceOrientationPortrait |
            UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (![Utils isDeviceiPad])
        return;

    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        if (self.isDetailViewController)
            [self hideMasterView];
        [BaseViewController removeMasterButtonForAll];
    } else {
        [BaseViewController addMasterButtonForAll];
    }
}

#pragma mark Public methods

+ (void)addMasterButtonForAll
{
    if (![Utils isDeviceiPad])
        return;
    
    for (BaseViewController* vc in _detailControllers)
    {
        [vc addMasterButton];
    }
}

+ (void)removeMasterButtonForAll
{
    if (![Utils isDeviceiPad])
        return;
    
    for (BaseViewController* vc in _detailControllers)
    {
        [vc removeMasterButton];
    }
}

- (void)addMasterButton
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return;
    
    [self.navigationItem setLeftBarButtonItem:self.masterButton animated:YES];
}

- (void)removeMasterButton
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return;

    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)handleSwipeLeft
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return;

    if (UIInterfaceOrientationIsPortrait(self.statusBarOrientation))
    {
        [self hideMasterView];
    }
}

- (void)handleSwipeRight
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return;

    if (UIInterfaceOrientationIsPortrait(self.statusBarOrientation))
    {
        [self showMasterView];
    }
}

- (void)handleTap
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return;

    if (UIInterfaceOrientationIsPortrait(self.statusBarOrientation))
    {
        [self hideMasterView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return NO;

    if (!self.masterIsVisible)
        return NO;

    return YES;
}

- (void)hideMasterView
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return;
    
    if (self.masterIsVisible)
    {      
        NSArray *controllers = self.splitViewController.viewControllers;
        UIViewController *rootViewController = [controllers objectAtIndex:0];

        [rootViewController viewWillDisappear:YES];

        UIView *rootView = rootViewController.view;
        CGRect rootFrame = rootView.frame;
        rootFrame.origin.x -= rootFrame.size.width;

        [UIView animateWithDuration:0.4 animations:
        ^{
            rootView.frame = rootFrame;
        }
        completion: ^(BOOL finished)
        {
            [rootViewController viewDidDisappear:YES];
            self.masterIsVisible = NO;
        }];
    }
}

- (void)showMasterView
{
    if (![Utils isDeviceiPad] || !self.isDetailViewController)
        return;
    
    if (!self.masterIsVisible)
    {
        NSArray *controllers = self.splitViewController.viewControllers;
        UIViewController *rootViewController = [controllers objectAtIndex:0];
        self.masterIsVisible = YES;

        [rootViewController viewWillAppear:YES];

        UIView *rootView = rootViewController.view;
        CGRect rootFrame = rootView.frame;
        rootFrame.origin.x += rootFrame.size.width;

        [UIView animateWithDuration:0.4 animations:
        ^{
            rootView.frame = rootFrame;
        }
        completion: ^(BOOL finished)
        {
            [rootViewController viewDidAppear:YES];
            self.masterIsVisible = YES;
        }];
    }
}

- (void)notifySuccessfullyPurchaseBookWithID:(int)bookID
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:bookID], @"BookID", nil];    
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_PURCHASED_NOTIFICATION 
                                                        object:nil userInfo:userInfo];
}

- (CGRect)screenBoundsForOrientation:(UIInterfaceOrientation)orientation
{
    if ([Utils isDeviceiPad] && UIInterfaceOrientationIsPortrait(orientation))
        return CGRectMake(0, 0, 768, 1024);
    else
    if ([Utils isDeviceiPad] && UIInterfaceOrientationIsLandscape(orientation))
        return CGRectMake(0, 0, 1024, 768);
    else
    if (![Utils isDeviceiPad] && UIInterfaceOrientationIsPortrait(orientation))
        return CGRectMake(0, 0, 320, 480);
    
    return CGRectMake(0, 0, 480, 320);
}


- (void)initializeWithClassDescription:(NSObject*)classDescription
{
    NSLog(@"[ERROR] initializeWithClassDescription: not overloaded");
}

- (void)defaultHandleFailExecuteMethod:(NSString*)method error:(NSError*)error
{
    NSString* errorString = nil;
    if ([error.domain isEqualToString:NWApiErrorDomainHttp])
    {
        errorString = NSLocalizedString(@"IDS_GENERAL_NETWORK_ERROR", @"");
    }
    if ([error.domain isEqualToString:NWApiErrorDomainFormat])
    {
        errorString = NSLocalizedString(@"IDS_BAD_FORMAT_ERROR", @"");
    }
    if ([error.domain isEqualToString:NWApiErrorDomainServerApi])
    {
        errorString = NSLocalizedString(@"IDS_GENERAL_API_ERROR", @"");
    }
    if (!_errorAlert)
    {
        _errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IDS_ERROR", @"")
                                                 message:errorString
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    }
    [_errorAlert show];
}

- (void)loadBook:(NWBookCard*)bookCard URL:(NSString*)url toPath:(NSString*)path cache:(NWBooksCache*)cache
{
    if (!bookCard)
        return;
    
    float threshold = 4*1024; // 4kb

#if TEST_MODE
    [cache addCacheItemForBookCard:bookCard
                     localFileName:[[NSBundle mainBundle] pathForResource:@"book1.fb2" ofType:@""]];
    [cache save];
    NWBookCacheItem* item = [cache cacheItemWithID:bookCard.ID];
    [ReadBookViewController readBookCacheItem:item parent:self];
    return;
#else

    [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_LOADING", @"")];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *loadOperation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    
    if (threshold > [Utils getFreeSpace]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_SPACE_ERROR_MSG", @"")];
    }
    
    loadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [loadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
         NSLog(@"Successfully downloaded file to %@", path);
         
         [cache addCacheItemForBookCard:bookCard
                          localFileName:path];
        
        if (![cache save]) {
            // SVProgressHUD is a singletone and it works with UI using GCD in main thread
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_SAVE_ERROR_MSG", @"")];   
        }
        
        NWBookCacheItem* item = [cache cacheItemWithID:bookCard.ID];
        [ReadBookViewController readBookCacheItem:item parent:self];
         
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
         NSLog(@"Unable to download book for URL %@", url);
        
        if (threshold > [Utils getFreeSpace]) {
            // SVProgressHUD is a singletone and it works with UI using GCD in main thread
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_SPACE_ERROR_MSG", @"")];            
        } else {
            // SVProgressHUD is a singletone and it works with UI using GCD in main thread
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_NETWORK_ERROR_OCCURED", @"")];
        }

    }];
    
    [loadOperation start];
#endif
}

#pragma mark Property accessors

- (void)setNavigationBarTitle:(NSString*)title
{
    self.navigationItem.title = title;
}

- (NSString*)navigationBarTitle
{
    return self.navigationItem.title;
}

- (CGFloat)statusBarHeight
{
    return [[UIApplication sharedApplication] isStatusBarHidden]? 0 : 20.0f;
}


- (UIDeviceOrientation)deviceOrientation
{
    if (UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation) == false)
        return UIDeviceOrientationPortrait;
    return [UIDevice currentDevice].orientation;
}

- (UIInterfaceOrientation)statusBarOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (UIViewController*)navigationRootViewController
{
    if (!self.navigationController || !self.navigationController.viewControllers)
        return nil;
    UIViewController* vc = [self.navigationController.viewControllers objectAtIndex:0];
    return vc;
}


- (UISplitViewController*)splitViewController
{
    //AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return appDelegate.splitViewController;
}

- (UIBarButtonItem*)masterButton
{
    if (!_masterButton)
        _masterButton = [[UIBarButtonItem alloc]
                         initWithTitle:NSLocalizedString(@"IDS_BOOKSTORE_TAB_TITLE", nil)
                         style:UIBarButtonItemStyleBordered
                         target:self
                         action:@selector(showMasterView)];
    return _masterButton;
}

- (BOOL)masterIsVisible
{
    return _staticMasterIsVisible;
}

- (void)setMasterIsVisible:(BOOL)newVal
{
    _staticMasterIsVisible = newVal;
}

@end
