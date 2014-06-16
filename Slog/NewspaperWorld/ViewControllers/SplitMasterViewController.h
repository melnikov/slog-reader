//
//  SplitMasterViewController.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>
#import "BookCategoriesViewController.h"
#import "ExpandableView.h"

/**
 This class is used in ipad version. 
 It provide main navigation functions in application.
 */
@interface SplitMasterViewController : BookCategoriesViewController<ExpandableViewDelegate, UITextFieldDelegate>
{
    /// expandable panel for table with store catalog
    IBOutlet ExpandableView* _storeBackgroundView;
    
    /// expandable panel for last readed book, fragments, purchased books
    IBOutlet ExpandableView* _myBooksBackgroundView;
    
    ///static panel for search and help button
    IBOutlet UIView* _bottomView;
    
    ///talbeView for my books section
    IBOutlet UITableView* _myBooksTable;
        
    ///array of titles for my books sections
    NSArray* _myBooksSectionTitles;
    
    ///array of icons for my books sections
    NSArray* _myBooksSectionImages;
    
    CGFloat _yOrigin;
    
    NSIndexPath* _myBooksLastSelectedIndex;
    
    NSIndexPath* _storeLastSelectedIndex;
	
	IBOutlet UIView *searchView;
	IBOutlet UITextField *searchTextField;
}
///TODO: comment
- (IBAction)searchButtonTouched:(id)sender;

///TODO: comment
- (IBAction)helpButtonTouched:(id)sender;

+ (SplitMasterViewController*)createViewController;

@end
