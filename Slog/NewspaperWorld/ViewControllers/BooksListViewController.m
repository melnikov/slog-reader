//
//  BooksListViewController.m
//  NewspaperWorld
//

#import <QuartzCore/QuartzCore.h>
#import "BooksListViewController.h"
#import "BookCardViewController.h"
#import "Constants.h"
#import "UIStyleManager.h"
#import "BookItemCell.h"
#import "Utils.h"
#import "NWBookCard.h"
#import "NWDataModel.h"
#import "SVProgressHUD.h"
#import "NWApiClient.h"
#import "ReadBookViewController.h"
#import "AFNetworking.h"
#import "NWLocalizationManager.h"

const int booksInRowIpad = 3;

const int booksInRowIphone = 2;

@interface BooksListViewController (Private)

- (void)initializeDefaults;

- (void)deinitializeControls;

- (void)fillTabletCell:(BookItemCell*)cell AtIndexPath:(NSIndexPath*)indexPath;

- (void)fillCell:(BookItemCell*)cell AtIndexPath:(NSIndexPath*)indexPath;

- (void)handleNotification:(NSNotification*)notification;

- (void)showBookCard:(NWBookCard*)bookCard;

- (void)setupBookItemView:(BookItemView*)bookItem withBookCard:(NWBookCard*)bookCard;

- (void)createEmptyListLabel;

@end

@implementation BooksListViewController

@synthesize emptyListText;

#pragma mark Memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initializeDefaults];
    }
    return self;
}

- (void)dealloc
{
    [self deinitializeControls];
    [_booksList release]; _booksList = nil;
    _purchasingBook = nil;
    [super dealloc];
}

#pragma mark View life-cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.separatorColor = [UIColor clearColor];
    //_tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf_bg.png"]] autorelease];
    [self createEmptyListLabel];

    self.emptyListText = NSLocalizedString(@"IDS_EMPTY_LIST", nil);
	
	background.image = [UIImage imageNamed:@"background_vert.jpg"];
}

- (void)viewDidUnload
{
    [self deinitializeControls];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:BOOK_PURCHASED_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark TableViewDataSource Protocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookItemCell* cell = [tableView dequeueReusableCellWithIdentifier:BookItemCellID];
    if (!cell)
    {
        cell = [BookItemCell createCell];
       
        UIImage* bgImage = [UIImage imageNamed:[Utils isDeviceiPad] ? @"cell_bookshelf_bg_iPad.png" : @"cell_bookshelf_bg_iPhone.png"] ;
        static const int iPadCapWidth = 40;
        int capWidth = [Utils isDeviceiPad] ? iPadCapWidth: 0;
        cell.backgroundImage = [bgImage stretchableImageWithLeftCapWidth:capWidth topCapHeight:0];        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [self fillCell:cell AtIndexPath:indexPath];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if ([Utils isDeviceiPad])
//    {
        return ([self booksCount] % ([Utils isDeviceiPad] ? booksInRowIpad : booksInRowIphone) == 0) ?[self booksCount]/([Utils isDeviceiPad] ? booksInRowIpad : booksInRowIphone) : [self booksCount]/([Utils isDeviceiPad] ? booksInRowIpad : booksInRowIphone) + 1;
//    }
//    return [self booksCount];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark Table implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [BookItemCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (![Utils isDeviceiPad])
//    {
//        NWBookCard* bookCard = [self bookAtIndex:(int)indexPath.row];
//        [self showBookCard:bookCard];
//    }
}

#pragma mark Private implementation

- (NWBookCard*)bookAtIndex:(int)index
{
    return [_booksList bookAtIndex:index];
}

- (NWBookCard*)bookWithID:(int)ID
{
    return [_booksList bookWithID:ID];
}

- (int)booksCount
{
    return [_booksList count];
}

- (void)initializeDefaults
{
    _booksList = nil;
    _tableView = nil;
    _emptyListLabel = nil;
    _purchasingBook = nil;
}

- (void)deinitializeControls
{
    [_tableView release]; _tableView = nil;
}

- (void)setupBookItemView:(BookItemView*)bookItem withBookCard:(NWBookCard*)bookCard
{
    if (!bookItem || !bookCard)
        return;

    NSMutableString* bookTechData = [NSMutableString string];
    if (bookCard.approximateReadingInHours > 0)
    {
        if (bookTechData.length > 0)
            [bookTechData appendString:@", "];
        [bookTechData appendFormat:@"~%d %@",  bookCard.approximateReadingInHours,  NSLocalizedString(@"IDS_HOURS", @"")];
    }
    if (bookCard.fileType.length > 0)
    {
        if (bookTechData.length > 0)
            [bookTechData appendString:@", "];
        [bookTechData appendString:bookCard.fileType];
    }
    if (bookCard.language.length > 0 && ![[NWLocalizationManager sharedManager].interfaceLanguage isEqualToString:bookCard.language])
    {
        if (bookTechData.length > 0)
            [bookTechData appendString:@", "];
       
        NSString *displayName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:bookCard.language];        
        [bookTechData appendString:displayName];
    }
    if (bookTechData.length > 0)
        [bookTechData appendString:@"."];
    
    bookItem.bookTitle      = bookCard.title;
    bookItem.bookAuthors    = bookCard.authors;
    bookItem.bookDuration   = bookTechData;
    bookItem.bookPrice      = bookCard.bookPrice;
    bookItem.bookID         = bookCard.ID;
    bookItem.bookIsSold     = bookCard.isSold;
    bookItem.bookCoverURL   = bookCard.coverURL;
    bookItem.delegate       = self;
}

- (void)fillTabletCell:(BookItemCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    if (!cell || !indexPath)
        return;

    int startBookIndex = (int)indexPath.row * ([Utils isDeviceiPad] ? booksInRowIpad : booksInRowIphone);
    [cell.item1 setHidden:YES];
    [cell.item2 setHidden:YES];
    [cell.item3 setHidden:YES];

    BookItemView* item = nil;
    for (int i = 0; i < ([Utils isDeviceiPad] ? booksInRowIpad : booksInRowIphone); i++)
    {
        item = nil;
        if (startBookIndex + i < [self booksCount] && i == 0)     item = cell.item1;
        if (startBookIndex + i < [self booksCount] && i == 1)     item = cell.item2;
        if (([Utils isDeviceiPad] ? booksInRowIpad : booksInRowIphone) == 3 && startBookIndex + i < [self booksCount] && i == 2)     item = cell.item3;

        NWBookCard* book = [self bookAtIndex:startBookIndex + i];
        if (!book)
            break;
        
        [[NWDataModel sharedModel].purchasedBooksCache load];
        NWBookCacheItem* purchasedBook = [[NWDataModel sharedModel].purchasedBooksCache cacheItemWithID:book.ID];
        
        if ((purchasedBook) && (purchasedBook.bookCard.isSold)) {
            book.isSold = YES;
        }

        if (item)
        {
            [self setupBookItemView:item withBookCard:book];
            [item setHidden:NO];
        }
    }
}

- (void)fillCell:(BookItemCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    if (!cell || !indexPath)
        return;

//    if ([Utils isDeviceiPad])
//    {
        [self fillTabletCell:cell AtIndexPath:indexPath];
//    }
//    else
//    {
//        NWBookCard* book = [self bookAtIndex:(int)indexPath.row];
//        [[NWDataModel sharedModel].purchasedBooksCache load];
//        NWBookCacheItem* purchasedBook = [[NWDataModel sharedModel].purchasedBooksCache cacheItemWithID:book.ID];
//
//        if ((purchasedBook) && (purchasedBook.bookCard.isSold)) {
//            book.isSold = YES;
//        }
//        
//        if (!book)
//            return;
//
//
//        [self setupBookItemView:cell.item1 withBookCard:book];
//    }
}

- (void)handleNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:BOOK_PURCHASED_NOTIFICATION])
    {
        if ([notification.userInfo.allValues count] > 0)
        {
            int bookID = [[notification.userInfo.allValues objectAtIndex:0] intValue];
            NWBookCard* bookCard = [self bookWithID:bookID];
            if (bookCard)
            {
                bookCard.isSold = YES;
                [self reloadTable];
            }
        }
    }
}

- (void)showBookCard:(NWBookCard*)bookCard
{
    if (!bookCard)
        return;

    [self hideMasterView];

    BookCardViewController* bookCardViewController = [BookCardViewController createViewController];
    [bookCardViewController initializeWithBookCard:bookCard];
    [self.navigationController pushViewController:bookCardViewController animated:YES];
}

- (void)createEmptyListLabel
{
    _emptyListLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _emptyListLabel.center = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height/2.0f);
    _emptyListLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    _emptyListLabel.textColor = [UIColor whiteColor];
    _emptyListLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    _emptyListLabel.textAlignment = UITextAlignmentCenter;
    _emptyListLabel.font = [UIFont systemFontOfSize:17.0f];
    _emptyListLabel.layer.cornerRadius = 4.0f;
    [_emptyListLabel setHidden:[self booksCount] > 0];
    [self.view addSubview:_emptyListLabel];
}

#pragma mark Public methods

- (void)initializeWithBooksList:(NWBooksList*)booksList title:(NSString*)title;
{
    self.navigationBarTitle = title;

    [_booksList release];
    _booksList = [booksList retain];

    [_emptyListLabel setHidden:[self booksCount] > 0];
    [_tableView reloadData];
}

+ (BooksListViewController*)createViewController
{
    return [[[BooksListViewController alloc] initWithNibName:@"BooksListViewController" bundle:nil] autorelease];
}

- (void)initializeWithClassDescription:(NSObject*)classInfo
{
    if (![classInfo isKindOfClass:[BooksListViewControllerDescription class]])
        return;

    BooksListViewControllerDescription* description = (BooksListViewControllerDescription*)classInfo;
    [self initializeWithBooksList:description.booksList title:description.title];
}

- (void)reloadTable
{
    [_tableView reloadData];
}

#pragma mark Property accessors

- (void)setEmptyListText:(NSString*)text
{
    if (_emptyListLabel)
    {
        [_emptyListLabel setText:text];
    }
}

- (NSString*)emptyListText
{
    if (_emptyListLabel)
    {
        return _emptyListLabel.text;
    }
    return nil;
}


#pragma mark NWApiClientDelegate


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
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_ERROR_PURCHASE_BOOK", nil)];
        _purchasingBook = nil;
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
    [self loadBook:_purchasingBook URL:bookURL toPath:destinationPath cache:[NWDataModel sharedModel].purchasedBooksCache];
    _purchasingBook = nil;
}

- (void)apiClientDidFailedExecuteMethod:(NSString*)methodName error:(NSError*)error
{
    [SVProgressHUD dismiss];
}

#pragma mark BookItemView delegate

- (void)buyButtonOnBookItemTouchedWithBookID:(int)bookID
{ 
  _purchasingBook = [self bookWithID:bookID];
  
  NWBookCacheItem* item  = [[NWDataModel sharedModel].purchasedBooksCache cacheItemWithID:bookID];
  if (!item)
  {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_PERFORMING_PURCHASE", @"")];
    [[NWApiClient sharedClient] buyBookWithID:bookID delegate:self];
  }
}

- (void)bookItemTouchedWithBookID:(int)bookID
{
  NWBookCard* bookCard = [self bookWithID:bookID];
  [self showBookCard:bookCard];
}

- (void)deleteButtonOnBookItemTouchedWithBookID:(int)bookID
{
    
}
@end
