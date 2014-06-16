//
//  NWCategories.m
//  NewspaperWorld
//


#import "NWCategories.h"
#import "NWCategory.h"

@implementation NWCategories

@synthesize count;

#pragma mark Memory management

- (id)init
{
    self = [super init];
    if (self)
    {
        _categories = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (NWCategories*)categoriesFromResponseData:(NSObject*)data
{
    NWCategories* result = [[[NWCategories alloc] init] autorelease];
    if ([result loadFromResponseData:data])
        return result;
    return nil;
}

+ (NWCategories*)categoriesFromCategoriesArray:(NSArray*)categoriesArray
{
    NWCategories* result = [[[NWCategories alloc] init] autorelease];
    if ([result loadFromCategoriesArray:categoriesArray])
        return result;
    return nil;
}

- (void)dealloc
{
    [_categories release];
    
    [super dealloc];
}

#pragma mark Public methods

- (BOOL)loadFromResponseData:(NSObject*)data
{
    if (![data isKindOfClass:[NSArray class]])
        return NO;
    
    [_categories removeAllObjects];
    
    NSArray* jsonArray = (NSArray*)data;
    for (NSObject* categoryJson in jsonArray)
    {
        NWCategory* category = [NWCategory categoryFromResponseData:categoryJson];
        if (category)
        {
            [_categories addObject:category];
        }
    }
    return ([_categories count] > 0) ? YES : NO;
}

- (BOOL)loadFromCategoriesArray:(NSArray*)categoriesArray
{   
    [_categories removeAllObjects];
      
    for (NSObject* categoryItem in categoriesArray)
    {
        if (![categoryItem isKindOfClass:[NWCategory class]])
            continue;
        
        NWCategory* category = (NWCategory*)categoryItem;        
        [_categories addObject:category];        
    }
    return ([_categories count] > 0) ? YES : NO;
}

- (NWCategory*)categoryAtIndex:(int)index
{
    if (_categories && index >= 0 && index < [_categories count])
    {
        return (NWCategory*)[_categories objectAtIndex:index];
    }
    return nil;
}

- (NWCategory*)categoryWithID:(int)ID recursive:(BOOL)recursive
{
    NWCategory* result = nil;
    
    for (NWCategory* category in _categories)
    {
        if (category.ID == ID)
        {
            result =  category;
            break;
        }
        if (recursive)
        {            
            result = [category.subcategories categoryWithID:ID recursive:recursive];
            if (result)
                break;
        }
    }
    return result;
}

#pragma mark Property accessors

- (int)count
{   
    return (int)[_categories count];
}

@end
