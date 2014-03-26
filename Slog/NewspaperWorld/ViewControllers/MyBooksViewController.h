//
//  MyBooksViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MyBooksViewController : BaseViewController
{
    ///tableview for menu items
    IBOutlet UITableView* _tableView;
    
    ///array for title of sections
    NSArray* _myBooksSectionTitles;
    
    ///array of icons for sections
    NSArray* _myBooksSectionImages;

}

+ (MyBooksViewController*)createViewController;

@end
