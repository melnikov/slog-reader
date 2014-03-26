//
//  FB2PageDataItems.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 26.03.13.
//
//

#import "FB2PageDataItems.h"
#import "FB2PageDataItem.h"

@implementation FB2PageDataItems

- (id)init
{
    self = [super init];
    if (self)
    {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)dealloc
{
    [_items release];
    
    [super dealloc];
}


#pragma mark Public methods

- (FB2PageDataItem*)itemAtIndex:(int)index
{
    if (index < 0 || index >= _items.count)
        return  nil;

    return [_items objectAtIndex:index];
}

- (FB2PageDataItem*)itemWithID:(int)ID
{
    FB2PageDataItem* item = nil;
    for (item in _items)
    {
        if ([item isKindOfClass:[FB2PageDataItem class]])
        {
            if (item.fb2ItemID == ID)
                break;
        }
    }
    return item;
}

- (void)addItem:(FB2PageDataItem*)newItem
{
    if (!newItem)
        return;

    [_items addObject:newItem];
}

#pragma mark Property accessors

- (int)count
{
    return _items.count;
}

@end
