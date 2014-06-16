//
//  ExpandableView.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>


#define EXPAND_ANIMATION_DELAY 0.001
#define EXPAND_ANIMATION_DURATION 0.3

@class ExpandableView;
@protocol ExpandableViewDelegate

- (BOOL)expandableViewShouldExpand:(ExpandableView*)view;

- (void)expandButtonTouched:(id)sender;

@end

/**
 This class is used for showing expandable view
 */
@interface ExpandableView : UIView
{
    int _expandButtonHeight;
    
    int _expandHeight;
    
    BOOL _isExpanded;
           
    IBOutlet UIButton* _expandButton;
    
    IBOutlet UIView*   _child;
    
    UIImage*           _expandImage;
    
    UIImage*           _rollupImage;    
}
/// Height for header button
@property (nonatomic, assign) int expandButtonHeight;

/// Maximum value for expandable view
@property (nonatomic, assign) int expandHeight;

/// Flag contains status of expandable view
@property (nonatomic, readonly) BOOL isExpanded;

/// View for expanding
@property (nonatomic, retain) UIView* childView;

//Delegate for button touch detecting
@property (nonatomic, assign) NSObject<ExpandableViewDelegate>* delegate;

@property (nonatomic, retain) UIImage* expandIndicatorImage;

@property (nonatomic, retain) UIImage* rollupIndicatorImage;

- (void)setButtonTitle:(NSString*)text;

- (void)expand:(BOOL)needExpand;

@end
