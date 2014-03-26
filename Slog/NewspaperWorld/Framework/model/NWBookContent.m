//
//  NWBookContent.m
//  NewspaperWorld
//

#import "NWBookContent.h"
#import "NWBookContentItem.h"
#import "FB2Section.h"
#import "FB2Body.h"

@implementation NWBookContent

@synthesize count;

#pragma mark Memory management

- (id)init
{
    self = [super init];
    if (self) {
      
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_items release];
    [super dealloc];
}

#pragma mark Private methods

- (void)readItemsFromSection:(FB2Section*)section depth:(int)depth
{
    depth++;
    for (FB2Section* child in section.subSections)
    {        
        NWBookContentItem* item = [NWBookContentItem itemWithTitle:child.title.plainText fb2ItemID:child.itemID depth:depth titleID:child.title.itemID];
        if (item)
        {
            [_items addObject:item];
        }
        [self readItemsFromSection:child depth:depth];
    }
}


#pragma mark Public methods

- (void)loadFromFB2File:(FB2File*)file
{
    _fb2File = [file retain];
    
    NSArray* bodies = _fb2File.bodies;
    int depth = SectionDepthMainChapter;
    
    [_items removeAllObjects];
    
    for (FB2Body* body in bodies)
    {
        for (FB2Section* section in body.sections)
        {
            NWBookContentItem* item = [NWBookContentItem itemWithTitle:section.title.plainText
                                                             fb2ItemID:section.itemID
                                                                 depth:depth
                                                               titleID:section.title.itemID];
            if (item)
            {
                [_items addObject:item];
            }
            [self readItemsFromSection:section depth:depth];
        }
    }
    [_fb2File release];
}

- (NSArray*)contentTitles
{
    NSMutableArray* titles = [NSMutableArray array];
    
    for (NWBookContentItem* item in _items)
    {        
        [titles addObject:item.title];        
    }
    return [NSArray arrayWithArray:titles];
}

- (NWBookContentItem*)contentItemWithID:(int)ID
{
    for (NWBookContentItem* item in _items)
    {
       if (item.fb2ItemID == ID)
           return item;
    }
    return nil;
}

- (NWBookContentItem*)contentItemAtIndex:(int)index
{
    if (index < 0 || index >= _items.count)
        return nil;
    
    return [_items objectAtIndex:index];
}

- (int)count
{
    return _items.count;
}

@end
