//
//  BookContentViewController.h
//  NewspaperWorld
//

#import "BaseViewController.h"
#import "BookTitleView.h"
#import "NWBookCacheItem.h"
#import "NWBookContentItem.h"

@protocol BookContentViewControllerDelegate<NSObject>

- (void)contentItemSelected:(NWBookContentItem*)item;

@end

@interface BookContentViewController : BaseViewController<UIPopoverControllerDelegate>
{
    IBOutlet UITableView*    _table;
    
    IBOutlet BookTitleView*  _bookTitleView;
    
    NWBookCacheItem*    _cacheItem;
    
    UIPopoverController* _parentPopover;
    
    NSObject<BookContentViewControllerDelegate>* _delegate;
}

+ (BookContentViewController*)createViewController;

- (void)initializeWithBookCacheItem:(NWBookCacheItem*)item;

@property (nonatomic, retain) UIPopoverController* parentPopover;

@property (nonatomic, retain) NSObject<BookContentViewControllerDelegate>* delegate;

@end
