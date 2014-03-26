//
//  NWBookCard.m
//  NewspaperWorld
//


#import "NWBookCard.h"
#import "NWModelConstants.h"

@interface NWBookCard(Private)

- (void)initializeDefaults;

- (void)releaseAllData;

@end

@implementation NWBookCard

@synthesize ID = _ID;

@synthesize title = _title;

@synthesize  coverURL = _coverURL;

@synthesize  authors = _authors;

@synthesize approximateReadingInHours = _approximateReadingInHours;

@synthesize publisher = _publisher;

@synthesize  isSold = _isSold;

@synthesize  demoFragmentURL = _demoFragmentURL;

@synthesize bookAnnotation = _bookAnnotation;

@synthesize bookPrice = _bookPrice;

@synthesize language = _language;

@synthesize fileType = _fileType;

@synthesize timestamp = _timestamp;

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

+ (NWBookCard*)bookFromResponseData:(NSObject*)data
{
    NWBookCard* result = [[[NWBookCard alloc] init] autorelease];
    
    if ([result loadFromResponseData:data])
        return result;
    return nil;
}

- (void)dealloc
{
    [self releaseAllData];
    [super dealloc];
}

#pragma mark Public methods

- (NSDictionary*)saveToDictionary
{
    NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:   
        [NSNumber numberWithInt:_ID],                                   NWApiJSONKeyBookID,
        (!_title)?@"":_title,                                           NWApiJSONKeyBookTitle,
        (!_coverURL)?@"":_coverURL,                                     NWApiJSONKeyBookCoverURL,
        (!_authors)?@"":_authors,                                       NWApiJSONKeyBookAuthors,
        [NSNumber numberWithInt:_approximateReadingInHours],            NWApiJSONKeyBookDuration,
        (!_publisher)?@"":_publisher,                                   NWApiJSONKeyBookPublisher,
        [NSNumber numberWithBool:_isSold],                              NWApiJSONKeyBookSaled,
        (!_demoFragmentURL)?@"":_demoFragmentURL,                       NWApiJSONKeyBookFragmentURL,
        (!_bookAnnotation)?@"":_bookAnnotation,                         NWApiJSONKeyBookAnnotation,
        (!_bookPrice)?@"":_bookPrice,                                   NWApiJSONKeyBookPrice,
        (!_language)?@"":_language,                                     NWApiJSONKeyLanguage,
        (!_fileType)?@"":_fileType,                                     NWApiJSONKeyFileType,
        (!_timestamp)?@"":_timestamp,                                   NWApiJSONKeyTimestamp,
        nil];
    return result;
}

- (BOOL)loadFromResponseData:(NSObject*)data
{
    if (![data isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    NSDictionary* jsonDictionary = (NSDictionary*)data;
    
    if ([[jsonDictionary allKeys] indexOfObject:NWApiJSONKeyBookID] == NSNotFound)
    {
        [self releaseAllData];
        [self initializeDefaults];
        return NO;
    }
    _ID = [[jsonDictionary objectForKey:NWApiJSONKeyBookID] intValue];
    
    if ([[jsonDictionary allKeys] indexOfObject:NWApiJSONKeyBookTitle] == NSNotFound)
    {
        [self releaseAllData];
        [self initializeDefaults];
        return NO;
    }
    [_title release];
    _title = [[jsonDictionary objectForKey:NWApiJSONKeyBookTitle] retain];
    
    [_coverURL release];
    _coverURL = [[jsonDictionary objectForKey:NWApiJSONKeyBookCoverURL] retain];
    
    [_authors release];
    _authors = [[jsonDictionary objectForKey:NWApiJSONKeyBookAuthors] retain];
    
    _approximateReadingInHours = [[jsonDictionary objectForKey:NWApiJSONKeyBookDuration] intValue];
    
    [_publisher release];
    _publisher = [[jsonDictionary objectForKey:NWApiJSONKeyBookPublisher] retain];
    
    if ([[jsonDictionary allKeys] indexOfObject:NWApiJSONKeyBookSaled] == NSNotFound)
    {
        [self releaseAllData];
        [self initializeDefaults];
        return NO;
    }
    _isSold = [[jsonDictionary objectForKey:NWApiJSONKeyBookSaled] boolValue];
    
    if ([[jsonDictionary allKeys] indexOfObject:NWApiJSONKeyBookFragmentURL] == NSNotFound)
    {
        [self releaseAllData];
        [self initializeDefaults];
        return NO;
    }
    [_demoFragmentURL release];
    _demoFragmentURL = [[jsonDictionary objectForKey:NWApiJSONKeyBookFragmentURL] retain];
    
    [_bookAnnotation release];
    _bookAnnotation = [[jsonDictionary objectForKey:NWApiJSONKeyBookAnnotation] retain];
    
    [_bookPrice release];
    _bookPrice = [[jsonDictionary objectForKey:NWApiJSONKeyBookPrice] retain];

    [_language release];
    _language = [[jsonDictionary objectForKey:NWApiJSONKeyLanguage] retain];

    [_fileType release];
    _fileType = [[jsonDictionary objectForKey:NWApiJSONKeyFileType] retain];

    [_timestamp release];
    _timestamp = [[jsonDictionary objectForKey:NWApiJSONKeyTimestamp] retain];
    
    return YES;
}

#pragma mark Private methods

- (void)initializeDefaults
{
    _ID     = NWBookIDUndefined;
    _isSold = NO;
    _approximateReadingInHours = 0;
}

- (void)releaseAllData
{
    [_title release];    
    [_coverURL release];
    [_authors release];  
    [_publisher release];
    [_demoFragmentURL release];
    [_bookAnnotation release];
    [_bookPrice release];
    [_language release];
    [_fileType release];
    [_timestamp release];
}

@end
