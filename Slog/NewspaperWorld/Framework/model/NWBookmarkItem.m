//
//  NWBookmarkItem.m
//  NewspaperWorld
//

#import "NWBookmarkItem.h"

static const NSString * const NWPListKeyTitle = @"title";
static const NSString * const NWPListKeyFB2ItemID  = @"fb2itemID";
static const NSString * const NWPListKeyPositionInBook = @"position_in_book";
static const NSString * const NWPListKeyOffset = @"offset_in_book";

@implementation NWBookmarkItem

@synthesize title           = _title;
@synthesize fb2ItemID       = _fb2ItemID;
@synthesize positionInBook  = _positionInBook;
@synthesize offset          = _offset;

- (id)init
{
    self = [super init];
    if (self)
    {
        _title = nil;
        _fb2ItemID = -1;
        _positionInBook = 0.0;
    }
    return self;
}

- (id)initWithTitle:(NSString*)aTitle  fb2ItemID:(int)itemID
{
    self = [self init];
    if (self)
    {
        _title          = [aTitle copy];
        _fb2ItemID      = itemID;
        _positionInBook = 0.0;
    }
    return self;
}

- (void)dealloc
{
    [_title release];
    [super dealloc];
}

#pragma mark Public methods

- (BOOL)loadFromDictionary:(NSDictionary*)dictionary
{
    if (!dictionary)
        return NO;
    
    if (![dictionary.allKeys containsObject:NWPListKeyFB2ItemID])
        return NO;    
   
    _fb2ItemID = [[dictionary objectForKey:NWPListKeyFB2ItemID] intValue];
    
    if ([dictionary.allKeys containsObject:NWPListKeyTitle])
    {
        [_title release];
        _title = [[dictionary objectForKey:NWPListKeyTitle] retain];
    }    
    if ([dictionary.allKeys containsObject:NWPListKeyPositionInBook])
    { 
        _positionInBook = [[dictionary objectForKey:NWPListKeyPositionInBook] doubleValue];
    }
    
    if ([dictionary.allKeys containsObject:NWPListKeyOffset])
    {
        _offset = [[dictionary objectForKey:NWPListKeyOffset] intValue];
    }
    return YES;
}

- (NSDictionary*)dictionary
{
    NSDictionary* result = [NSMutableDictionary dictionaryWithObjectsAndKeys:   _title,                                     NWPListKeyTitle,
                                                                                [NSNumber numberWithInt:_fb2ItemID],        NWPListKeyFB2ItemID ,
                                                                                [NSNumber numberWithDouble:_positionInBook],   NWPListKeyPositionInBook,
                                                                [NSNumber
                                                                 numberWithInt:_offset],
                                                                    NWPListKeyOffset,
                                                                                nil];
    return result;
}

+ (NWBookmarkItem*)itemWithTitle:(NSString*)title fb2ItemID:(int)itemID
{
    return [[[NWBookmarkItem alloc] initWithTitle:title fb2ItemID:itemID] autorelease];
}

+ (NWBookmarkItem*)itemFromDictionary:(NSDictionary*)dictionary
{
    NWBookmarkItem* item = [[[NWBookmarkItem alloc] init] autorelease];
    if ([item loadFromDictionary:dictionary])
        return item;
    return nil;
}
@end
