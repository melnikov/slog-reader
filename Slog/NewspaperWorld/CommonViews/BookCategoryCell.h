//
//  BookCategoryCell.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>

@interface BookCategoryCell : UITableViewCell
{
    IBOutlet UILabel*    _titleLabel;
    
    IBOutlet UIImageView* _bottomSeparator;
    
    IBOutlet UIImageView* _topSeparator;    
}

@property (nonatomic, retain) NSString* title;

@property (nonatomic, assign) BOOL showBottomSeparator;

@property (nonatomic, assign) BOOL showTopSeparator;

+ (NSString*)reuseIdentifier;

+ (NSString*)nibName;

@end
