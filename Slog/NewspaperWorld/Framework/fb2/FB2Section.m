//
//  FB2Section.m
//  NewspaperWorld
//


#import "FB2Section.h"
#import "FB2Constants.h"
#import "GDataXMLElement+Utils.h"
#import "FB2ItemFactory.h"
#import "FB2EmptyLine.h"
#import "FB2Subtitle.h"
#import "FB2SectionGenerator.h"

@implementation FB2Section

@synthesize subSections = _subSections;
@synthesize subItems    = _subItems;
@synthesize title       = _title;

#pragma mark Memory management

- (id)init
{
    if (self = [super init])
    {
        _subSections = [[NSMutableArray alloc] init];
        _subItems = [[NSMutableArray alloc] init];

        self.generator = [[[FB2SectionGenerator alloc] init] autorelease];

        return self;
    }
    return nil;
}

- (void)dealloc
{
    [_subItems release];
    [_subSections   release];
    
    [super dealloc];
}

#pragma mark Private methods


#pragma mark Public methods

- (void)loadFromXMLElement:(GDataXMLElement*)element
{
    if (!element || ![element.name isEqualToString:FB2ElementSection])
        return;

    GDataXMLNode* idAttr = [element attributeForName:FB2ElementID];
    if (idAttr)
    {
        [_ID release];
        _ID = [[idAttr stringValue] retain];
    }

    for (GDataXMLElement* child in element.children)
    {
        if (child.kind == GDataXMLTextKind)
            continue;

        FB2Item* fb2Item = [FB2ItemFactory itemFromXMLElement:child];
        if (fb2Item)
        {
            [_subItems addObject:fb2Item];
        }
    }

    NSArray* sectionsElements = [element elementsForName:FB2ElementSection];
    for (GDataXMLElement* sectionElement in sectionsElements)
    {
        FB2Section* newSection = [[FB2Section alloc] init];
        [newSection loadFromXMLElement:sectionElement];
        [_subSections addObject:newSection];
        [newSection release];
    }
}

- (FB2Title*)title
{
    if (!_title) {
        for (FB2Item* subItem in _subItems)
        {
            if ([subItem isKindOfClass:[FB2Title class]] || [subItem isKindOfClass:[FB2Subtitle class]])
            {
                _title = (FB2Title*)subItem;
                break;
            }
        }
    }    
    return _title;
}

- (BOOL)containsItemWithID:(int)ID
{
    BOOL result = [super containsItemWithID:ID];
    if (result) return result;
         
    result |= [_title containsItemWithID:ID];
    if (result) return result;
    FB2Item* item = nil;
    
    for(int i = 0; i < _subItems.count; i++) {
        item = [_subItems objectAtIndex:i];
        if ([item containsItemWithID:ID]) {
            return YES;
        }
    }
    return result;
}
@end
