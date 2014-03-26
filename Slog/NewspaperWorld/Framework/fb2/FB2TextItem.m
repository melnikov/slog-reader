//
//  FB2FormattedTextItem.m
//  NewspaperWorld
//

#import "FB2TextItem.h"
#import "FB2ItemFactory.h"


@implementation FB2TextItem

@synthesize plainText = _plainText;
@synthesize subItems = _subItems;

- (id)init
{
    self = [super init];
    if (self)
    {
        _subItems  = [[NSMutableArray alloc] init];
        _plainText = @"";
        [self initTextStyle];
    }
    return self;
}

- (void)dealloc
{
    [_subItems release];
    [_plainText release];
    [_textStyle release];
    [super dealloc];
}

#pragma mark Public methods

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element
{
    FB2TextItem* item = [[[FB2TextItem alloc] init] autorelease];
    if ([item loadFromXMLElement:element])
        return item;
    return nil;
}

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element startChildIndex:(int)index
{
    FB2TextItem* item = [[[FB2TextItem alloc] init] autorelease];
    if ([item loadFromXMLElement:element startChildIndex:index])
        return item;
    return nil;
}

- (BOOL)loadFromXMLElement:(GDataXMLElement *)element startChildIndex:(int)index
{
    if (!element)
        return NO;

    for (int i = 0; i < element.childCount; i++)
    {
        GDataXMLElement* child = (GDataXMLElement*)[element childAtIndex:i];
        FB2TextItem* subItem = [FB2ItemFactory itemFromXMLElement:child];
        if (subItem)
            [_subItems addObject:subItem];
    }
    return YES;
}


- (BOOL)loadFromXMLElement:(GDataXMLElement *)element
{
    return [self loadFromXMLElement:element startChildIndex:0];
}

- (BOOL)containsItemWithID:(int)ID
{
    BOOL result = [super containsItemWithID:ID];
    if (result) return result;
    
    for (FB2Item* item in _subItems)
    {
        result |= [item containsItemWithID:ID];
        if (result) return result;
    }
    return result;
}

- (void)initTextStyle
{
    [_textStyle release];
    _textStyle = [[FB2TextStyle alloc] init];
}

#pragma mark Property accessors

- (NSString*)plainText
{
    NSMutableString* result = [NSMutableString  string];
    
    for (FB2TextItem* item in _subItems)
    {      
        if (![item isKindOfClass:[FB2TextItem class]])
            continue;
        
        [result appendString:item.plainText];
    }
    return result;
}

- (NSArray*)subItems
{
    return [NSArray arrayWithArray:_subItems];
}

- (FB2TextStyle*)textStyle
{
    [self initTextStyle];
    return _textStyle;
}

- (void)setTextStyle:(FB2TextStyle*)style
{
    _textStyle = style;
}

- (int)lastItemID
{
    int ID = self.itemID;

    if (self.subItems.count > 0)
    {
        FB2Item* lastItem = [self.subItems objectAtIndex:self.subItems.count - 1];
        if ([lastItem isKindOfClass:[FB2TextItem class]])
        {
            FB2TextItem* lastTextItem = (FB2TextItem*)lastItem;
            ID = lastTextItem.lastItemID;
        }
        else
        {
            ID = lastItem.itemID;
        }
    }
    return ID;
}

@end
