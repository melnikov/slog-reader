//
//  BooksListViewController.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NWBooksList.h"
#import "BooksListViewControllerDescription.h"
#import "NWApiClientDelegate.h"
#import "BookItemViewDelegate.h"

@class BookItemCell;
@class BookItemView;

@interface BooksListViewController : BaseViewController <UITableViewDelegate,
                                                         UITableViewDataSource,
                                                         NWApiClientDelegate,
                                                         BookItemViewDelegate>
{    
    NWBooksList*    _booksList;
    
    IBOutlet UITableView*    _tableView;
    
    UILabel* _emptyListLabel;
    
    NWBookCard* _purchasingBook;
}

+ (BooksListViewController*)createViewController;

- (void)initializeWithBooksList:(NWBooksList*)booksList title:(NSString*)title;

- (void)reloadTable;

- (NWBookCard*)bookAtIndex:(int)index;

- (NWBookCard*)bookWithID:(int)ID;

- (int)booksCount;

@property (nonatomic, retain) NSString* emptyListText;

@end
