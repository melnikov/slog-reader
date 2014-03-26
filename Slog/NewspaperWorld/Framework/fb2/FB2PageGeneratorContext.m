//
//  FB2PageGeneratorContext.m
//  NewspaperWorld
//


#import "FB2PageGeneratorContext.h"

@implementation FB2PageGeneratorContext

@synthesize position;
- (id)init
{
    self = [super init];
    if (self)
    {
        _pages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_pages release];
    
    [super dealloc];
}

- (CGPoint*)position
{
    return &_position;
}

- (void)clear
{
    _page = nil;

    self.fb2File = nil;

    [_pages removeAllObjects];

    _position = CGPointZero;

    _pageHeight = 0;
    _pageWidth = 0;
}

- (void)nextPage
{
    if (!self.page)
        return;

    [self.pages addObject:self.page];
    self.page = nil;
    
    self.position->y = 0;
    self.position->x = 0;
}

- (void)nextStringWithLineHeight:(CGFloat)lineHeight
{
    if (self.position->y + lineHeight > self.pageHeight)
    {
        [self nextPage];
        return;
    }
    self.position->x = 0;
    self.position->y         += lineHeight;
    if (self.page)
        self.page.contentHeight  += lineHeight;
}

@end
