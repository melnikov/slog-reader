//
//  SectionHeaderView.m
//  NewspaperWorld
//

#import "SectionHeaderView.h"

@implementation SectionHeaderView

@synthesize title;

#pragma mark Memory management

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = nil;
    }
    return self;
}

- (void)dealloc
{
    [_titleLabel release];
    [super dealloc];
}

#pragma mark View life cycle

#pragma mark Property Accessors

- (void)setTitle:(NSString*)newTitle
{
    if (_titleLabel)
    {
        [_titleLabel setText:newTitle];
    }
}

- (NSString*)title
{
    return _titleLabel.text;
}

@end
