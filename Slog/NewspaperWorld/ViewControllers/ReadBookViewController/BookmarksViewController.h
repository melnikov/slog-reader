//
//  BookmarksViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BookTitleView.h"
#import "FB2File.h"
#import "NWBookmarkItem.h"
#import "NWBookCacheItem.h"

@protocol BookmarksViewControllerDelegate<NSObject>

- (void)bookmarkItemSelected:(NWBookmarkItem*)item;

- (void)bookmarkItemDeleted;

@end

@interface BookmarksViewController : BaseViewController<UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView*    _table;
    
    IBOutlet BookTitleView*  _bookTitleView;
    
    NWBookCacheItem*    _cacheItem;
    
    UIPopoverController* _parentPopover;
}

+ (BookmarksViewController*)createViewController;

- (void)initializeWithBookCacheItem:(NWBookCacheItem*)item;

@property (nonatomic, retain) UIPopoverController* parentPopover;

@property (nonatomic, retain) NSObject<BookmarksViewControllerDelegate>* delegate;
@end
