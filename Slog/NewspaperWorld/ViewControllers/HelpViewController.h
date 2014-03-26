//
//  HelpViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface HelpViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView* _tableView;
    
    NSArray* _helpCategoriesTitles;
}

+ (HelpViewController*)createViewController;

@end
