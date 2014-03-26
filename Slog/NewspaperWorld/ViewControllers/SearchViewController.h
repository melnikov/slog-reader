//
//  SearchViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BooksListViewController.h"
#import "NWApiClientDelegate.h"

@interface SearchViewController : BooksListViewController <UISearchBarDelegate,
                                                           UITableViewDelegate,
                                                           UITableViewDataSource,
                                                           NWApiClientDelegate>
{
    IBOutlet UIToolbar*          _searchToolbar;
    IBOutlet UINavigationItem*   _searchItem;
    IBOutlet UISearchBar*        _searchBar;
}

+ (SearchViewController*)createViewController;

@end
