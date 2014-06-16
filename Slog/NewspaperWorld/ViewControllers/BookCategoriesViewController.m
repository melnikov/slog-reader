 //
//  BookStoreViewController.m
//  NewspaperWorld
//

#import "BookCategoriesViewController.h"
#import "BooksListViewController.h"
#import "Constants.h"
#import "Utils.h"
#import "SectionHeaderView.h"
#import "BookCategoryCell.h"
#import "NWDataModel.h"
#import "NWCategory.h"
#import "NWApiClient.h"
#import "SVProgressHUD.h"
#import "BooksListViewControllerDescription.h"
#import <QuartzCore/QuartzCore.h>
#import "NWApiConstants.h"

#define RECOMMENDED_SECTION_ID  0
#define GENRES_SECTION_ID       1

@interface BookCategoriesViewController(Private)

- (SectionHeaderView*)sectionHeader;

- (void)customizeCategoryCell:(UITableViewCell*)cell;

- (void)deinitialize;

- (void)defaultInitializeCategories;

- (void)createEmptyListLabel;

- (void)createActivityIndicator;

- (void)reloadBooksForCategoryID:(int)ID withLanguages:(NSArray*)languages;

@end

@implementation BookCategoriesViewController

@synthesize needShowSections = _needShowSections;

@synthesize genres = _genres;

@synthesize specialCategories = _specialCategories;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _sectionHeaderView = nil;
        _needShowSections = YES;
        _tableView = nil;
        _emptyListLabel = nil;
        _activityIndicator = nil;
        _categories =  nil;
        _genres = nil;
        _specialCategories = nil;
        _selectedCategoryName = nil;
        _loadingData = NO;
        if ([Utils isDeviceiPad])
        {
            self.isDetailViewController = NO;
        }
    }
    return self;
}

- (void)dealloc
{
    [self deinitialize];
    _selectedCategoryName = nil;
    [_categories release];
    [_genres release];
    [_specialCategories release];
    [super dealloc];
}

#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self createEmptyListLabel];
    [self createActivityIndicator];
    
    if (self.navigationController.tabBarItem)
    {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"IDS_BOOKSTORE_TAB_TITLE", @"");
    }    
    _sectionTitles = [[NSArray alloc] initWithObjects:NSLocalizedString(@"IDS_RECOMMENDED",@""),
                                                      NSLocalizedString(@"IDS_GENRES", @""), nil];
    [self defaultInitializeCategories];
    
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithR:249 G:241 B:194 A:255];
    [Utils setEmptyFooterToTable:_tableView];
    
    [_tableView reloadData];
    
    [[super view] setNeedsDisplay];
	
	if([Utils isDeviceiPad])
		background.image = [UIImage imageNamed:@"background_menu.jpg"];
	else
		background.image = [UIImage imageNamed:@"background_vert.jpg"];
}

- (void)viewDidUnload
{
    [self deinitialize];
    
    [super viewDidUnload];  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    if (_categories.count == 0)
    {
        [self performGetCategoriesRequest];
    }
}

#pragma mark TableViewDataSource Protocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{      
    BookCategoryCell* cell = [tableView dequeueReusableCellWithIdentifier:[BookCategoryCell reuseIdentifier]];    
    if (!cell)    
        cell = (BookCategoryCell*)[Utils loadViewOfClass:[BookCategoryCell class] FromNibNamed:[BookCategoryCell nibName]];        
    

    NWCategory* category = nil;
    if (indexPath.section == RECOMMENDED_SECTION_ID) category = [self.specialCategories categoryAtIndex:(int)indexPath.row];
    if (indexPath.section == GENRES_SECTION_ID)      category = [self.genres categoryAtIndex:(int)indexPath.row];
    
    if (cell)
    {
        BOOL needShowBottomSeparator = NO;
        if (indexPath.section == RECOMMENDED_SECTION_ID) needShowBottomSeparator = (indexPath.row == [self.specialCategories count]-1);
        if (indexPath.section == GENRES_SECTION_ID)      needShowBottomSeparator = (indexPath.row == [self.genres count]-1);
        needShowBottomSeparator &= (indexPath.section == _sectionTitles.count - 1);
        cell.showBottomSeparator = needShowBottomSeparator;
        cell.title = category.title;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if (section == RECOMMENDED_SECTION_ID) count += [self.specialCategories count];
    if (section == GENRES_SECTION_ID)      count += [self.genres count];
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionTitles count];
}

#pragma mark TableViewDelegate Protocol

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (_needShowSections == NO)
//        return 0;
//    
//    const int defaultSectionHeaderHeight = 21;
//    int categoryCount = 0;
//    if (section == RECOMMENDED_SECTION_ID) categoryCount = [self.specialCategories  count];
//    if (section == GENRES_SECTION_ID)      categoryCount = [self.genres count];
//  
//    return (categoryCount == 0) ? 0 : defaultSectionHeaderHeight;
	
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    if (_needShowSections == NO)
//        return nil;
//    SectionHeaderView* sectionView = [self sectionHeader];
//    sectionView.title = [_sectionTitles objectAtIndex:section];
//    return sectionView;
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NWCategory* category = nil;
    if (indexPath.section == RECOMMENDED_SECTION_ID) category = [self.specialCategories  categoryAtIndex:(int)indexPath.row];
    if (indexPath.section == GENRES_SECTION_ID)      category = [self.genres categoryAtIndex:(int)indexPath.row];

    if (!category)
        return;
    
    if (!category.subcategories)
    {
        _selectedCategoryName = category.title;

        [self reloadBooksForCategoryID:category.ID withLanguages:NWSupportedBookLanguages];
    }
    else
    {
        BookCategoriesViewController* subCat = [BookCategoriesViewController createViewController];
        subCat.needShowSections = NO;
        [subCat initializeWithCategories:category.subcategories title:category.title];
        [self.navigationController pushViewController:subCat animated:YES];
    }    
}

#pragma mark Private implementation

- (void)reloadBooksForCategoryID:(int)ID withLanguages:(NSArray *)languages
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_RETRIEVING_LIST", @"")];
    [[NWApiClient sharedClient] getBooksInCategoryWithID:ID delegate:self languages:languages fileTypes:NWSupportedBookFileTypes];
}

- (SectionHeaderView*)sectionHeader
{
    SectionHeaderView* result = nil;
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"SectionHeaderView" owner:nil options:nil];
    for (UIView* view in views)
    {
        if ([view isKindOfClass:[SectionHeaderView class]])
        {
            result = (SectionHeaderView*)view;
            break;
        }
    }
    return result;
}

- (void)deinitialize
{
    [_tableView release];           _tableView = nil;  
    [_sectionHeaderView release];   _sectionHeaderView = nil;
    [_emptyListLabel release];      _emptyListLabel = nil;
    [_activityIndicator release];   _activityIndicator = nil;
}

- (void)defaultInitializeCategories
{
    if (!_categories)
    {
        _needShowSections = YES;
        [self initializeWithCategories:[NWDataModel sharedModel].categories title:NSLocalizedString(@"IDS_BOOKSTORE_TAB_TITLE", @"")];
    }
}

- (void)createEmptyListLabel
{
    _emptyListLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 225, 40)];
    _emptyListLabel.center = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height/2.0f);
    _emptyListLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    _emptyListLabel.textColor = [UIColor whiteColor];
    _emptyListLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    _emptyListLabel.textAlignment = UITextAlignmentCenter;
    _emptyListLabel.font = [UIFont systemFontOfSize:17.0f];
    _emptyListLabel.layer.cornerRadius = 4.0f;
    _emptyListLabel.hidden = YES;
    
    _emptyListLabel.text = NSLocalizedString(@"IDS_EMPTY_LIST", nil);
    
    [self.view addSubview:_emptyListLabel];
}

- (void)createActivityIndicator
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    _activityIndicator.hidesWhenStopped = YES;
    
    CGRect labelFrame = _emptyListLabel.frame;
    CGRect activityFrame = _activityIndicator.frame;
    activityFrame.origin.x = labelFrame.origin.x + 10;
    activityFrame.origin.y = labelFrame.origin.y + labelFrame.size.height/2.0f - activityFrame.size.height/2.0f;
    _activityIndicator.frame = activityFrame;
    
    [self.view addSubview:_activityIndicator];
}

- (void)performGetCategoriesRequest
{
    if (_loadingData)
        return;
    
    _loadingData = YES;
    
    if ([NWApiClient sharedClient].applicationAuthorized == NO)
    {
        [[NWApiClient sharedClient] authorizeApplicationWithUID:[UIDevice currentDevice].uniqueDeviceIdentifier delegate:self];
    }
    else
    {
        [[NWApiClient sharedClient] getCategoriesWithDelegate:self];
    }
    
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    
    _emptyListLabel.hidden = NO;
    _emptyListLabel.text = NSLocalizedString(@"IDS_LOADING_CATEGORIES", nil);
    
    
    _tableView.userInteractionEnabled = NO;
}

#pragma mark Public implementation

+ (BookCategoriesViewController*)createViewController
{
    return [[[BookCategoriesViewController alloc] initWithNibName:@"BookCategoriesViewController" bundle:nil] autorelease];
}

- (void)initializeWithCategories:(NWCategories*)categories title:(NSString*)title
{
    [_categories release];
    _categories = [categories retain];
    
    if (_categories.count == 0)
    {
        _needShowSections = NO;
        _emptyListLabel.hidden = NO;
    }
        
    self.navigationBarTitle = title;
    
    NWCategory* category = nil;
    NSMutableArray* specCategoriesArray = [NSMutableArray array];
    NSMutableArray* categoriesArray = [NSMutableArray array];
    
    for (int i = 0; i < _categories.count; i++)
    {
        category  = [_categories categoryAtIndex:i];
        
        if (category.isSpecial == YES)
        {
            [specCategoriesArray addObject:category];
        }
        else
        {
            [categoriesArray addObject:category];
        }
    }
    
    [_specialCategories release];
    _specialCategories = [[NWCategories categoriesFromCategoriesArray:specCategoriesArray] retain];
   
    [_genres release];
    _genres = [[NWCategories categoriesFromCategoriesArray:categoriesArray] retain];
    
    [_tableView reloadData];
}

#pragma mark NWApiClientDelegate methods

- (void)apiClientReceivedToken:(NSString *)token
{
    [[NWApiClient sharedClient] getCategoriesWithDelegate:self];
}

- (void)apiClientReceivedCategories:(NWCategories *)categories
{
    [NWDataModel sharedModel].categories = categories;
    
    _needShowSections = YES;
    [self defaultInitializeCategories];
    
    [[NWApiClient sharedClient] getPurchasedBooksWithDelegate:self];
}

- (void)apiClientReceivedPurchasedBooks:(NWBooksList *)books
{
    [[NWDataModel sharedModel].purchasedBooksCache synchronizeWithBookList:books];
    
    [_activityIndicator stopAnimating];
    _tableView.userInteractionEnabled = YES;
    _emptyListLabel.hidden = YES;
    _loadingData = NO;
}

- (void)apiClientReceivedBooksForCategory:(NWBooksList*)books
{
    [SVProgressHUD dismiss];
    
    if ([Utils isDeviceiPad])
    {
        BooksListViewControllerDescription* description = [[[BooksListViewControllerDescription alloc] init] autorelease];
        description.booksList = books;
        description.title = _selectedCategoryName;
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOKLIST_SHOULDSHOW_NOTIFICATION
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:description, @"description", nil]];
    }
    else
    {
        BooksListViewController* bookList = [BooksListViewController createViewController];
        [bookList initializeWithBooksList:books title:_selectedCategoryName];
        [self.navigationController pushViewController:bookList animated:YES];
    }   
}

- (void)apiClientDidFailedExecuteMethod:(NSString*)methodName error:(NSError*)error
{
    if (_loadingData)
    {
        _loadingData = NO;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IDS_ERROR", nil)
                                                        message:NSLocalizedString(@"IDS_NETWORK_ERROR_OCCURED", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [_activityIndicator stopAnimating];
         _tableView.userInteractionEnabled = YES;
        _emptyListLabel.hidden = _categories.count > 0;
        _emptyListLabel.text = NSLocalizedString(@"IDS_EMPTY_LIST", nil);
    }
    else
    {
        [SVProgressHUD dismiss];
    }
}

@end
