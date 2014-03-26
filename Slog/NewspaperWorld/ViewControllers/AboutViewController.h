//
//  AboutViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AboutViewController : BaseViewController
{
    IBOutlet UILabel*       _applicationNameLabel;
    
    IBOutlet UILabel*       _applicationVersionLabel;
    
    IBOutlet UILabel*       _applicationCopyrightsLabel;
    
    IBOutlet UITextView*    _applicationDescriptionView;
    
    IBOutlet UIImageView*   _applicationLogoView;
    
    NSString*   _descriptionText;
}

+ (AboutViewController*)createViewController;

- (BOOL)initializeWithDescription:(NSString*)text;

@end
