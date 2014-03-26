//
//  NWCategory.m
//  NewspaperWorld
//

#import "NWCategory.h"
#import "NWCategories.h"
#import "NWModelConstants.h"

@interface NWCategory(Private)

- (void)initializeDefaults;

@end

@implementation NWCategory

@synthesize ID = _ID;

@synthesize title = _title;

@synthesize subcategories = _subcategories;

@synthesize isSpecial = _isSpecial;

#pragma mark Memory management

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initializeDefaults];
    }
    return self;
}

+ (NWCategory*)categoryFromResponseData:(NSObject*)data
{
    NWCategory* result = [[[NWCategory alloc] init] autorelease];
    
    if ([result loadFromResponseData:data])
        return result;
    return nil;
}

- (void)dealloc
{
    [_title release];
    [_subcategories release];
    
    [super dealloc];
}

#pragma mark Private methods

- (void)initializeDefaults
{
    _ID    = NWSpecialCategoryUndefined;
    _title = nil;
    _subcategories = nil;
    _isSpecial = NO;
}

#pragma mark Public methods


- (BOOL)loadFromResponseData:(NSObject*)data
{
    if (![data isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    NSDictionary* jsonDictionary = (NSDictionary*)data;
    
    if ([[jsonDictionary allKeys] indexOfObject:NWApiJSONKeyCategoryID] == NSNotFound)
    {
        [self initializeDefaults];
        return NO;
    }
    _ID = [[jsonDictionary objectForKey:NWApiJSONKeyCategoryID] intValue];
    
    if ([[jsonDictionary allKeys] indexOfObject:NWApiJSONKeyCategoryTitle] == NSNotFound)
    {
        [self initializeDefaults];
        return NO;
    }
    [_title release];
    _title  = [[jsonDictionary objectForKey:NWApiJSONKeyCategoryTitle] retain];    
    
    _isSpecial = [[jsonDictionary objectForKey:NWApiJSONKeySpecialCategory] boolValue];
    
    [_subcategories release]; _subcategories = nil;
    NSArray* subCategoriesJson = [jsonDictionary objectForKey:NWApiJSONKeySubcategories];
    NWCategories* subCategories = [NWCategories categoriesFromResponseData:subCategoriesJson];    
    _subcategories  = [subCategories retain];
    
    return YES;
}
@end
