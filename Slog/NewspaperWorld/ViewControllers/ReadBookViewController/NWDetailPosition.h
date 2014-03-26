//
//  NWDetailPosition.h
//  NewspaperWorld
//
//  Created by Эльдар Пикунов on 01.04.13.
//
//

#import <Foundation/Foundation.h>

@interface NWDetailPosition : NSObject

@property (nonatomic, assign) int offset;
@property (nonatomic, assign) int itemID;

- (id)initWithID:(int)itemID offset:(int)offset;

@end