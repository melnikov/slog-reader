//
//  BookCardViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NWApiClientDelegate.h"
#import "BookItemView.h"

@class NWBookCard;

@interface BookCardViewController : BaseViewController<UIAlertViewDelegate,
                                                       NWApiClientDelegate, UITextViewDelegate>
{
    IBOutlet BookItemView* _bookItemView;
         
    IBOutlet UITextView*  _bookAnnotation;
        
    IBOutlet UIButton*    _readDemoButton;
    
    IBOutlet UIButton*    _readBookButton;

    IBOutlet UIButton*    _buyBookButton;
    
    NWBookCard*           _bookCard;
}

- (IBAction)readDemoFragmentButtonTouched:(id)sender;

- (IBAction)readBookButtonTouched:(id)sender;

- (IBAction)buyBookButtonTouched:(id)sender;

- (void)initializeWithBookCard:(NWBookCard*)card;

+ (BookCardViewController*)createViewController;

@end
