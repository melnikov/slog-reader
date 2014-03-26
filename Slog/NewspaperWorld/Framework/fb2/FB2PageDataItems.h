//
//  FB2PageDataItems.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 26.03.13.
//
//

#import <Foundation/Foundation.h>

@class FB2PageDataItem;

@interface FB2PageDataItems : NSObject
{
    NSMutableArray* _items;
}
@property (nonatomic, readonly) int count;

- (FB2PageDataItem*)itemAtIndex:(int)index;

- (FB2PageDataItem*)itemWithID:(int)ID;

- (void)addItem:(FB2PageDataItem*)newItem;

@end
