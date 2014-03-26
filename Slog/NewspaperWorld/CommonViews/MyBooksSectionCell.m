//
//  MyBooksSectionCell.m
//  NewspaperWorld
//

#import "MyBooksSectionCell.h"

@implementation MyBooksSectionCell

@synthesize icon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        _iconView = nil;
    }
    return self;
}

- (void)dealloc
{
    [_iconView release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setIcon:(UIImage *)newValue
{
    [_iconView setImage:newValue];
}

- (UIImage*)icon
{
    return _iconView.image;    
}
@end
