//
//  BookCacheViewControllerDescription.m
//  NewspaperWorld
//

#import "BookCacheViewControllerDescription.h"
#import "NWBooksCache.h"

@implementation BookCacheViewControllerDescription

@synthesize title;

@synthesize cache;

- (id)init
{
    self = [super init];
    if (self)
    {
        title = nil;
        
        cache = nil;
    }
    return self;
}

- (void)dealloc
{
    [title release];
    [cache release];
    
    [super dealloc];
}

@end
