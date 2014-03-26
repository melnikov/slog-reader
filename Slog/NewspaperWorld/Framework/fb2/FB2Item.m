//
//  FB2Item.m
//  NewspaperWorld
//

#import "FB2Item.h"
#import "FB2File.h"
#import "FB2SimpleItemGenerator.h"

@implementation FB2Item

@synthesize ID = _ID;
@synthesize generator = _generator;

- (id)init
{
    self = [super init];
    if (self) {
        _itemID = [FB2File nextID];
        _generator = [[FB2SimpleItemGenerator alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_ID release];
    [_generator release];
    [super dealloc];
}

- (BOOL)containsItemWithID:(int)itemID
{
    return _itemID == itemID;
}

- (void)generatePagesWithContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    [self.generator generatePagesForItem:self withContext:context parentStyle:parentStyle];
}
@end
