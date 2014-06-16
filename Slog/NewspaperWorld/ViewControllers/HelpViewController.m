//
//  HelpViewController.m
//  NewspaperWorld
//

#import "HelpViewController.h"
#import "AboutViewController.h"
#import "InformationViewController.h"
#import "Utils.h"
#import "BookCategoryCell.h"

#define HelpPlistKeyTitle @"title"
#define HelpPlistKeyText  @"text"

@interface HelpViewController ()

- (NSString*)titleAtIndex:(int)index;

- (NSString*)textAtIndex:(int)index;

- (NSDictionary*)dictionaryAtIndex:(int)index;

@end

@implementation HelpViewController


#pragma mark Memory managment

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _helpCategoriesTitles = [[NSArray arrayWithContentsOfFile:NWLocalizedPathForResource(@"Help", @"plist")] retain];
    }
    return self;
}

- (void)dealloc
{
    [_helpCategoriesTitles release];
    [super dealloc];
}
#pragma mark View life-cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"IDS_HELP", @"");
    if (self.navigationController.tabBarItem)
    {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"IDS_HELP", @"");
    }
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithR:249 G:241 B:194 A:255];
    [Utils setEmptyFooterToTable:_tableView];
	
	background.image = [UIImage imageNamed:@"background_vert.jpg"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark TableViewDataSource Protocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookCategoryCell* cell = [tableView dequeueReusableCellWithIdentifier:[BookCategoryCell reuseIdentifier]];
    if (!cell)
    {
        cell = (BookCategoryCell*)[Utils loadViewOfClass:[BookCategoryCell class] FromNibNamed:[BookCategoryCell nibName]];
    }
    if (cell)
    {
        cell.showBottomSeparator = (indexPath.row == [_helpCategoriesTitles count] - 1);
        cell.title = [self titleAtIndex:(int)indexPath.row];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_helpCategoriesTitles count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark Table implementation

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [_helpCategoriesTitles count] - 1)
    {
        AboutViewController* about = [AboutViewController createViewController];
        if ([about initializeWithDescription:[self textAtIndex:(int)indexPath.row]])
            [self.navigationController pushViewController:about animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:[InformationViewController informationWithTitle:[self titleAtIndex:(int)indexPath.row]
                                                                                                 text:[self textAtIndex:(int)indexPath.row]] animated:YES];
    }
}

#pragma mark Public methods

+ (HelpViewController*)createViewController
{
    return [[[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil] autorelease];
}

#pragma mark Private methods

- (NSString*)titleAtIndex:(int)index
{
    NSDictionary* dict = [self dictionaryAtIndex:index];
    
    return [dict objectForKey:HelpPlistKeyTitle];
}

- (NSString*)textAtIndex:(int)index
{
    NSDictionary* dict = [self dictionaryAtIndex:index];
    
    return [dict objectForKey:HelpPlistKeyText];
}

- (NSDictionary*)dictionaryAtIndex:(int)index
{
    if (index < 0 || index > [_helpCategoriesTitles count]-1)
        return nil;
    
    NSDictionary* dict = [_helpCategoriesTitles objectAtIndex:index];
    if (![dict isKindOfClass:[NSDictionary class]])
        return nil;
    
    return dict;
}
@end
