//
//  BookTitleView.m
//  NewspaperWorld
//

#import "BookTitleView.h"

@implementation BookTitleView

@synthesize bookTitle;

@synthesize bookAuthor;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        _titleLabel = nil;
        _authorLabel = nil;
    }
    return self;
}

- (void)dealloc
{
    [_titleLabel release]; 
    [_authorLabel release];
    [super dealloc];
}

#pragma mark Property accessors

- (void)setBookTitle:(NSString *)value
{
    [_titleLabel setText:value];
}

- (NSString*)bookTitle
{
    return _titleLabel.text;
}

- (void)setBookAuthor:(NSString *)value
{
    [_authorLabel setText:value];
}

- (NSString*)bookAuthor
{
    return _authorLabel.text;
}

@end
