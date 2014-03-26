//
//  ContentItemCell.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>

@interface BookmarkCell : UITableViewCell
{
    IBOutlet UILabel* _titleLabel;
    
    IBOutlet UILabel* _offsetLabel;  
    
    IBOutlet UIView* _grayView; 
    
    double _relativeOffset;
    
    BOOL _isGrayBackground;
}

+ (NSString*)reuseIdentifier;

+ (NSString*)nibName;

+ (CGFloat)cellHeight;

@property (nonatomic, assign)  double relativeOffset;

@property (nonatomic, retain)  NSString* title;

@property (nonatomic, assign)  BOOL isGrayBackground;

@end
