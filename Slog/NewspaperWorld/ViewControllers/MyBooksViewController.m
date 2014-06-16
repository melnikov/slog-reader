//
//  MyBooksViewController.m
//  NewspaperWorld
//


#import "MyBooksViewController.h"
#import "MyBooksListViewController.h"
#import "DemoFragmentsViewController.h"
#import "ReadBookViewController.h"
#import "Utils.h"
#import "NWDataModel.h"
#import "MyBooksSectionCell.h"

const static int lastBookCellRow    = 0;
const static int fragmentsCellRow   = 1;
const static int myBooksCellRow     = 2;

@interface MyBooksViewController (Private)

@end

@implementation MyBooksViewController

#pragma mark Memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _myBooksSectionTitles = [[NSArray alloc] initWithObjects:NSLocalizedString(@"IDS_READ_LAST", @""),
                                                                 NSLocalizedString(@"IDS_FRAGMENTS", @""),
                                                                 NSLocalizedString(@"IDS_MY_BOOKS_LIST", @""), nil];
        _myBooksSectionImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"last_book"],
                                                                 [UIImage imageNamed:@"demo_books"],
                                                                 [UIImage imageNamed:@"purchased_books"],nil];

    }
    return self;
}

- (void)dealloc
{
    [_myBooksSectionImages release]; _myBooksSectionImages = nil;
    [_myBooksSectionTitles release]; _myBooksSectionTitles = nil;
    [super dealloc];
}

#pragma mark View life-cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBarTitle = NSLocalizedString(@"IDS_MY_BOOKS_TITLE", @"");
    if (self.navigationController.tabBarItem)
    {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"IDS_MY_BOOKS_TITLE", @"");
    }
    [Utils setEmptyFooterToTable:_tableView];
	
	background.image = [UIImage imageNamed:@"background_vert.jpg"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark TableViewDataSource Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_myBooksSectionTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
   
    MyBooksSectionCell* cell = [tableView dequeueReusableCellWithIdentifier:MyBooksSectionCellID];
    if (!cell)
    {
        cell = (MyBooksSectionCell*)[Utils loadViewOfClass:[MyBooksSectionCell class] FromNibNamed:@"MyBooksSectionCell"];
    }        
        
    cell.showBottomSeparator = (indexPath.row == [_myBooksSectionTitles count] - 1);        
    cell.title               = [_myBooksSectionTitles objectAtIndex:indexPath.row];
    cell.icon                = [_myBooksSectionImages objectAtIndex:indexPath.row];
        
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark TableView delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(![Utils isDeviceiPad])
		return;
	
    if (indexPath.row == lastBookCellRow)
    {
        [ReadBookViewController readBookCacheItem:[NWDataModel sharedModel].lastReadedBook parent:self];
    }
    if (indexPath.row == myBooksCellRow)
        [self.navigationController pushViewController:[MyBooksListViewController createViewController] animated:YES];
    if (indexPath.row == fragmentsCellRow)
        [self.navigationController pushViewController:[DemoFragmentsViewController createViewController] animated:YES];
}

#pragma mark Public methods

+ (MyBooksViewController*)createViewController
{
    return [[[MyBooksViewController alloc] initWithNibName:@"MyBooksViewController" bundle:nil] autorelease];
}

#pragma mark Private methods

- (void)customizeCell:(UITableViewCell*)cell
{
    cell.backgroundView = [[[UIImageView alloc] init] autorelease];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [((UIImageView*)cell.backgroundView) setImage:[UIImage imageNamed:@"cell_bg"]];
    
    UIView* bgCellView = [[UIView alloc] init];
    bgCellView.backgroundColor = [UIColor colorWithR:247 G:186 B:30 A:255];
    [cell setSelectedBackgroundView:bgCellView];
    [bgCellView release];
}

- (IBAction)continueReadingPressed
{
	[ReadBookViewController readBookCacheItem:[NWDataModel sharedModel].lastReadedBook parent:self];
}

- (IBAction)bookListPressed
{
	[self.navigationController pushViewController:[MyBooksListViewController createViewController] animated:YES];
}

- (IBAction)demoVersionsPressed
{
	[self.navigationController pushViewController:[DemoFragmentsViewController createViewController] animated:YES];
}

@end
