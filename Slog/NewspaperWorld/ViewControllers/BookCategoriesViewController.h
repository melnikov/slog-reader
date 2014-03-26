//
//  BookStoreViewController.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NWCategories.h"
#import "NWApiClientDelegate.h"

/**
 This class is used for showing main book store categories
 */
@interface BookCategoriesViewController: BaseViewController<UITableViewDelegate, UITableViewDataSource, NWApiClientDelegate>
{    
    NSArray* _sectionTitles;
    
    UIView* _sectionHeaderView;
    
    BOOL    _needShowSections;
    
    IBOutlet UITableView* _tableView;
    
    UILabel* _emptyListLabel;
    
    UIActivityIndicatorView* _activityIndicator;
    
    NWCategories* _categories;
    
    NWCategories* _specialCategories;
    
    NWCategories* _genres;
    
    NSString* _selectedCategoryName;
    
    BOOL _loadingData;
}

+ (BookCategoriesViewController*)createViewController;

- (void)initializeWithCategories:(NWCategories*)categories title:(NSString*)title;

- (void)performGetCategoriesRequest;

@property (nonatomic, assign) BOOL                  needShowSections;

@property (nonatomic, readonly) NWCategories*       genres;

@property (nonatomic, readonly)   NWCategories*     specialCategories;

@end
