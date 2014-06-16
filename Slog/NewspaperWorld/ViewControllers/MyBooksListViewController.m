//
//  MyBooksListViewController.m
//  NewspaperWorld
//

#import "MyBooksListViewController.h"
#import "NWDataModel.h"
#import "Constants.h"
#import "NWApiClient.h"
#import "SVProgressHUD.h"

@interface MyBooksListViewController (Private)

- (IBAction)rightButtonTouched:(id)sender;

@end

@implementation MyBooksListViewController

#pragma mark Memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{ 
    [super dealloc];
}

#pragma mark View life-cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBarTitle = NSLocalizedString(@"IDS_MY_BOOKS_LIST", @"");

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(rightButtonTouched:)];
	background.image = [UIImage imageNamed:@"background_vert.jpg"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initializeWithCache:[NWDataModel sharedModel].purchasedBooksCache];
    [super viewWillAppear:animated];
}

#pragma mark Public methods

+ (MyBooksListViewController*)createViewController
{
    return [[[MyBooksListViewController alloc] initWithNibName:@"MyBooksListViewController" bundle:nil] autorelease];
}

#pragma mark Private methods

- (IBAction)rightButtonTouched:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IDS_PURCHASE_RESTORING", nil)
                                                    message:NSLocalizedString(@"IDS_IS_NEED_LOAD_PURCHASED", nil)
                                                   delegate:self
                                          cancelButtonTitle:@"Да"
                                          otherButtonTitles:@"Нет", nil];

    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)//yes
    {
        [[NWApiClient sharedClient] getPurchasedBooksWithDelegate:self];
    }
}

- (void)apiClientReceivedPurchasedBooks:(NWBooksList*)books
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_SYNCHRONIZATION_PURCHASED_LIST", nil)];
    
    [[NWDataModel sharedModel].purchasedBooksCache synchronizeWithBookList:books];
    [[NWDataModel sharedModel].purchasedBooksCache save];
    
    [self initializeWithCache:[NWDataModel sharedModel].purchasedBooksCache];
    [SVProgressHUD dismiss];
}

- (void)apiClientDidFailedExecuteMethod:(NSString *)methodName error:(NSError *)error
{
    [SVProgressHUD dismiss];
}
@end
