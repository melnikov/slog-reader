//
//  DemoFragmentsViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BookCacheViewController.h"

@interface DemoFragmentsViewController : BookCacheViewController <UIAlertViewDelegate>
{
    BOOL _editModeEnabled;
    int _bookIDToDelete;
    NSIndexPath* _indexToDelete;
    UIBarButtonItem* _editButton;
}

+ (DemoFragmentsViewController*)createViewController;

@end
