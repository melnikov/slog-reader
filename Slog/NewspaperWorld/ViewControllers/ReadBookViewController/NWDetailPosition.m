//
//  NWDetailPosition.m
//  NewspaperWorld
//
//  Created by Эльдар Пикунов on 01.04.13.
//
//

#import "NWDetailPosition.h"

@implementation NWDetailPosition

- (id)initWithID:(int)itemID offset:(int)offset
{
    self  = [super init];
    if (self)
    {
        _offset = offset;
        _itemID = itemID;
    }
    return self;
}
@end
