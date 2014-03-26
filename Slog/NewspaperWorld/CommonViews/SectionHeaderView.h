//
//  SectionHeaderView.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>

@interface SectionHeaderView : UIView
{
    IBOutlet UILabel* _titleLabel;
}

@property (nonatomic, retain) NSString* title;

@end
