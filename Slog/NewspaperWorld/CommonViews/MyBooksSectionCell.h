//
//  MyBooksSectionCell.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BookCategoryCell.h"

#define MyBooksSectionCellID @"MyBooksSectionCellID"

@interface MyBooksSectionCell : BookCategoryCell
{
    IBOutlet UIImageView* _iconView;
}

@property (nonatomic, retain) UIImage* icon;

@end
