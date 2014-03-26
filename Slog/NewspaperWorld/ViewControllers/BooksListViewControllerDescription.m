//
//  BooksListViewControllerDescription.m
//  NewspaperWorld
//


#import "BooksListViewControllerDescription.h"

@implementation BooksListViewControllerDescription

@synthesize title;

@synthesize booksList;

- (id)init
{
    self = [super init];
    if (self)
    {
        title = nil;
        
        booksList = nil;
    }
    return self;
}

- (void)dealloc
{
    [title release];
    [booksList release];
    
    [super dealloc];
}
@end
