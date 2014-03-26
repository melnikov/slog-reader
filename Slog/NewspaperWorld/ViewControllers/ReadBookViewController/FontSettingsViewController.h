//
//  FontSettingsViewController.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol FontSettingsDelegate;

@interface FontSettingsViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>
{
    IBOutlet UITableView*       _table;
    
    IBOutlet UITableViewCell*   _fontSizeCell;
    
    IBOutlet UITableViewCell*   _textExampleCell;
    
    int                         _oldFontSize;
    
    UIColor*                    _oldTextColor;
    
    NSString*                   _oldFontFamily;
}

+ (FontSettingsViewController*)createViewController;

@property (nonatomic, retain) UIPopoverController* parentPopover;
@property (nonatomic, assign) id<FontSettingsDelegate> delegate;

@end

@protocol FontSettingsDelegate <NSObject>

- (void)fontSettingsViewControllerWillDismiss:(FontSettingsViewController*)vc fontSettingsModified:(BOOL)fontSettingsChanged textColorModified:(BOOL)textColorChanged;

@end