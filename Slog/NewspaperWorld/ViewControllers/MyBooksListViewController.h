//
//  MyBooksListViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BookCacheViewController.h"
#import "NWApiClientDelegate.h"

@interface MyBooksListViewController : BookCacheViewController <UIAlertViewDelegate,
                                                                NWApiClientDelegate>
{
   
}

+ (MyBooksListViewController*)createViewController;

@end
