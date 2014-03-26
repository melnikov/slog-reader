//
//  FB2PageData.m
//  NewspaperWorld
//

#import "FB2PageData.h"

@implementation FB2PageData

- (id)init
{
    self = [super init];
    if (self)
    {
        _items = [[FB2PageDataItems alloc] init];
        _links = [[FB2PageDataItems alloc] init];
        _nodeIDs = [[NSMutableArray alloc] init];
        _contentHeight = 0;
    }
    return self;
}

+ (id)pageData
{
    return [[[FB2PageData alloc] init] autorelease];
}

- (void)dealloc
{
    [_items release];
    [_links release];
    [_nodeIDs release];
    [super dealloc];
}

@end
