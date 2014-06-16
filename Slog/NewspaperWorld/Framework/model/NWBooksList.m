//
//  NWBooksList.m
//  NewspaperWorld
//

#import "NWBooksList.h"
#import "NWBookCard.h"

@implementation NWBooksList

@synthesize count;

#pragma mark Memory management

- (id)init
{
    self = [super init];
    if (self)
    {
        _books = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_books release];
    
    [super dealloc];
}

#pragma mark Public methods

+ (NWBooksList*)booksFromResponseData:(NSObject*)data
{
    NWBooksList* result = [[[NWBooksList alloc] init] autorelease];
    if ([result loadFromResponseData:data])
        return result;
    return nil;
}

- (BOOL)loadFromResponseData:(NSObject*)data
{
    if (![data isKindOfClass:[NSArray class]])
        return NO;
    
    [_books removeAllObjects];
    
    NSArray* categoriesArray = (NSArray*)data;
    for (NSObject* bookItem in categoriesArray)
    {
        NWBookCard* book = [NWBookCard bookFromResponseData:bookItem];
        if (book)
        {
            [_books addObject:book];
        }
    }
    return ([_books count] > 0) ? YES : NO;
}



- (NWBookCard*)bookAtIndex:(int)index
{
    if (_books && index >= 0 && index < [_books count])
    {
        return (NWBookCard*)[_books objectAtIndex:index];
    }
    return nil;
}

- (NWBookCard*)bookWithID:(int)ID
{
    NWBookCard* result = nil;
    
    for (NWBookCard* book in _books)
    {
        if (book.ID == ID)
        {
            result =  book;
            break;
        }        
    }
    return result;
}

#pragma mark Property accessors

- (int)count
{
    return (int)[_books count];
}

@end
