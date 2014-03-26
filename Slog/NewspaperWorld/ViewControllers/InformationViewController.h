//
//  InformationViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface InformationViewController : BaseViewController
{    
    IBOutlet UITextView* _textView;
    
    NSString* _informationText;
    
    NSString* _informationTitle;
}

+ (InformationViewController*)createViewController;

+ (InformationViewController*)informationWithTitle:(NSString*)title text:(NSString*)text;

- (BOOL)initializeWithTitle:(NSString*)title text:(NSString*)text;

@end
