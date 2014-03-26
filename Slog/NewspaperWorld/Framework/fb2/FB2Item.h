//
//  FB2Item.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "FB2ItemGenerator.h"

@interface FB2Item : NSObject
{
    NSString* _ID;
    NSObject<FB2ItemGenerator>* _generator;
}
@property (nonatomic, readonly) int       itemID;
@property (nonatomic, readonly) NSString* ID;
@property (nonatomic, retain  ) NSObject<FB2ItemGenerator>* generator;

- (BOOL)containsItemWithID:(int)itemID;
- (void)generatePagesWithContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle;
@end
