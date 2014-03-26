//
//  BookItemCell.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>
#import "BookItemView.h"

#define BookItemCellID @"BookItemCellID"

@interface BookItemCell : UITableViewCell
{
@private
    
    BookItemView*    _item1;
    
    BookItemView*   _item2;
    
    BookItemView*   _item3;
    
    IBOutlet UIImageView*    _backgroundImageView;
}

+ (BookItemCell*)createCell;

+ (int)cellHeight;

@property (nonatomic, retain) IBOutlet BookItemView* item1;

@property (nonatomic, retain) IBOutlet BookItemView* item2;

@property (nonatomic, retain) IBOutlet BookItemView* item3;

@property (nonatomic, retain) UIImage* backgroundImage;

@end
