//
//  BookCardViewController.m
//  NewspaperWorld
//

#import "BookCardViewController.h"
#import "ReadBookViewController.h"
#import "NWBookCard.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"
#import "NWApiClient.h"
#import "SVProgressHUD.h"
#import "NWDataModel.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "ReaderViewController.h"
#import "ReaderDocument.h"

@interface BookCardViewController ()

- (void)reloadBookCard;

- (void)loadDemoFragment;

- (void)loadFullVersion;

- (void)handleNotification:(NSNotification*)notification;

- (void)updateButtonsPoitionsForOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation BookCardViewController

#pragma mark Memory managment

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isDetailViewController = NO;
    }
    return self;
}

- (void)dealloc
{
    [_bookItemView release];
    [_bookAnnotation release];
    [_readBookButton release];
    [_readDemoButton release];
    
    [super dealloc];
}

#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadBookCard];
	
	background.image = [UIImage imageNamed:@"background_vert.jpg"];
}

- (void)viewDidUnload
{
    [_bookItemView release];   _bookItemView = nil;
    [_bookAnnotation release]; _bookAnnotation = nil;
    [_readBookButton release]; _readBookButton = nil;
    [_readDemoButton release]; _readDemoButton = nil;

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateButtonsPoitionsForOrientation:self.statusBarOrientation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:BOOK_PURCHASED_NOTIFICATION object:nil];
    [super viewWillAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation))
    {
        [self updateButtonsPoitionsForOrientation:UIInterfaceOrientationPortrait];
    }
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation))
    {
        [self updateButtonsPoitionsForOrientation:UIInterfaceOrientationLandscapeLeft];
    }
}

#pragma mark Public implementation

+ (BookCardViewController*)createViewController
{
    return [[[BookCardViewController alloc] initWithNibName:@"BookCardViewController" bundle:nil] autorelease];
}

- (void)initializeWithBookCard:(NWBookCard*)bookCard
{
    if (!bookCard)
        return;

    if (![bookCard isKindOfClass:[NWBookCard class]])
        return;

    [_bookCard release];
    _bookCard = [bookCard retain];

    [self reloadBookCard];
}

- (IBAction)readDemoFragmentButtonTouched:(id)sender
{
    if (!_bookCard)
        return;

    NWBookCacheItem* item  = [[NWDataModel sharedModel].demoFragmentsCache cacheItemWithID:_bookCard.ID];
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (!item || !item.localPath || (![manager fileExistsAtPath:item.localPath]))
        [self loadDemoFragment];
    else {
        [ReadBookViewController readBookCacheItem:item parent:self];
    }
}

- (IBAction)readBookButtonTouched:(id)sender
{
    [[NWDataModel sharedModel].purchasedBooksCache load];
    NWBookCacheItem* item  = [[NWDataModel sharedModel].purchasedBooksCache cacheItemWithID:_bookCard.ID];
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (!item || !item.localPath || (![manager fileExistsAtPath:item.localPath]))
        [self loadFullVersion];
    else {
        [ReadBookViewController readBookCacheItem:item parent:self];
    }
}


- (IBAction)buyBookButtonTouched:(id)sender;
{
    NWBookCacheItem* item  = [[NWDataModel sharedModel].purchasedBooksCache cacheItemWithID:_bookCard.ID];
    if (!item)
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_PERFORMING_PURCHASE", @"")];
        [[NWApiClient sharedClient] buyBookWithID:_bookCard.ID delegate:self];
    }
    else
        [ReadBookViewController readBookCacheItem:item parent:self];
}

#pragma mark Private methods

- (void)updateButtonsPoitionsForOrientation:(UIInterfaceOrientation)orientation
{
    if ([Utils isDeviceiPad])
        return;
    
    CGRect annFrame = _bookAnnotation.frame;
    const int verticalMargin = 5;
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        CGRect buttonFrame = _readBookButton.frame;
        buttonFrame.origin.y = _bookItemView.frame.origin.y + _bookItemView.frame.size.height - buttonFrame.size.height;
        [_readBookButton setFrame:buttonFrame];

        buttonFrame = _readDemoButton.frame;
        buttonFrame.origin.y = _bookItemView.frame.origin.y + _bookItemView.frame.size.height - buttonFrame.size.height * 2 - 10;
        [_readDemoButton setFrame:buttonFrame];

        buttonFrame = _buyBookButton.frame;
        buttonFrame.origin.y = _bookItemView.frame.origin.y + _bookItemView.frame.size.height - buttonFrame.size.height;
        [_buyBookButton setFrame:buttonFrame];

        annFrame.origin.y = _bookItemView.frame.origin.y + _bookItemView.frame.size.height + verticalMargin;
    }
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        int marginiOS7 = 0;

        if ([Utils isiOS7])
        {
            marginiOS7 = 60;
        }
        
        CGRect buttonFrame = _readBookButton.frame;
        buttonFrame.origin.y = _bookItemView.bookCoverView.frame.origin.y + _bookItemView.bookCoverView.frame.size.height - buttonFrame.size.height + marginiOS7;
        [_readBookButton setFrame:buttonFrame];

        buttonFrame = _readDemoButton.frame;
        buttonFrame.origin.y = _bookItemView.bookCoverView.frame.origin.y + _bookItemView.bookCoverView.frame.size.height - buttonFrame.size.height * 2 - 10 + marginiOS7;
        [_readDemoButton setFrame:buttonFrame];

        buttonFrame = _buyBookButton.frame;
        buttonFrame.origin.y = _bookItemView.bookCoverView.frame.origin.y + _bookItemView.bookCoverView.frame.size.height - buttonFrame.size.height +marginiOS7;
        [_buyBookButton setFrame:buttonFrame];

        annFrame.origin.y = _bookItemView.frame.origin.y + _bookItemView.bookCoverView.frame.origin.y + _bookItemView.bookCoverView.frame.size.height + verticalMargin;
    }
   
    int marginiOS7 = 0;
    if ([Utils isiOS7])
    {
        marginiOS7 = 40;
    }
    annFrame.size.height = self.view.bounds.size.height - annFrame.origin.y - 2*verticalMargin - marginiOS7;
    [_bookAnnotation setFrame:annFrame];
}

- (void)handleNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:BOOK_PURCHASED_NOTIFICATION])
    {
        if ([notification.userInfo.allValues count] > 0)
        {
            int bookID = [[notification.userInfo.allValues objectAtIndex:0] intValue];
            if (bookID == _bookCard.ID)
                _bookCard.isSold = YES;
            [self reloadBookCard];
        }
    }
}

- (void)loadFullVersion
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_LOADING", @"")];

    [[NWApiClient sharedClient] getURLOfFullVersionBookWithID:_bookCard.ID delegate:self];
}

- (void)loadDemoFragment
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_LOADING", @"")];

    NSString* destinationPath = [[Utils cacheDirectoryPath] stringByAppendingPathComponent:DemoFragmentsFolder];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:destinationPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    destinationPath = [destinationPath stringByAppendingPathComponent:[Utils uniqueString]];
    
    if ([_bookCard.fileType isEqualToString:@"pdf"]) {
    //    destinationPath = [destinationPath stringByAppendingString:@".pdf"];
    }
    
    [self loadBook:_bookCard URL:_bookCard.demoFragmentURL toPath:destinationPath cache:[NWDataModel sharedModel].demoFragmentsCache];
}

- (void)reloadBookCard
{
    if (_bookCard)
    {
        self.navigationBarTitle = _bookCard.title;

        _bookItemView.bookAuthors = [[_bookCard.authors componentsSeparatedByString:@","] firstObject];
        _bookItemView.bookTitle = _bookCard.title;
    
        NSMutableString* bookTechData = [NSMutableString string];
        if (_bookCard.approximateReadingInHours > 0)
        {
            if (bookTechData.length > 0)
                [bookTechData appendString:@", "];
            [bookTechData appendFormat:@"~%d %@",  _bookCard.approximateReadingInHours,  NSLocalizedString(@"IDS_HOURS", nil)];
        }
        if (_bookCard.fileType.length > 0)
        {
            if (bookTechData.length > 0)
                [bookTechData appendString:@", "];
            [bookTechData appendString:_bookCard.fileType];
        }
        if (_bookCard.language.length > 0 && ![[NWLocalizationManager sharedManager].interfaceLanguage isEqualToString:_bookCard.language])
        {
            if (bookTechData.length > 0)
                [bookTechData appendString:@", "];

            NSString *displayName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:_bookCard.language];
            [bookTechData appendString:displayName];
        }
        if (bookTechData.length > 0)
            [bookTechData appendString:@"."];

        _bookItemView.bookDuration = bookTechData;

        _bookItemView.bookCoverURL  = _bookCard.coverURL;
        _bookItemView.bookPrice     = _bookCard.bookPrice;
        _bookItemView.bookIsSold    = _bookCard.isSold;
        _bookItemView.bookID        = _bookCard.ID;

        [_readDemoButton setHidden:_bookCard.isSold];
        [_readBookButton setHidden:!_bookCard.isSold];
		[_buyBookButton setHidden:_bookCard.isSold];

        [_bookAnnotation setText:_bookCard.bookAnnotation];
    }
}

#pragma mark NWApiClientDelegate methods

- (void)apiClientPurchaseResult:(BOOL)purchase bookID:(int)bookID
{    
    if (purchase)
    {
        [SVProgressHUD dismiss];
        [self notifySuccessfullyPurchaseBookWithID:bookID];
        [[NWApiClient sharedClient] getURLOfFullVersionBookWithID:bookID delegate:self];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_ERROR_PURCHASE_BOOK", @"")];   
    }
}

- (void)apiClientReceivedFullVersionURL:(NSString*)bookURL
{
    NSString* destinationPath = [[Utils cacheDirectoryPath] stringByAppendingPathComponent:PurchasedBooksFolder];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:destinationPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    destinationPath = [destinationPath stringByAppendingPathComponent:[Utils uniqueString]];
    [self loadBook:_bookCard URL:bookURL toPath:destinationPath cache:[NWDataModel sharedModel].purchasedBooksCache];
}

- (void)apiClientDidFailedExecuteMethod:(NSString*)methodName error:(NSError*)error
{
    [SVProgressHUD dismiss];
}


@end
