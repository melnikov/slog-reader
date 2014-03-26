//
//  FB2PageData.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "FB2PageDataItem.h"
#import "FB2PageDataItems.h"

@interface FB2PageData : NSObject

@property (nonatomic, assign)   CGFloat   contentHeight;
@property (nonatomic, readonly) NSMutableArray* nodeIDs;
@property (nonatomic, readonly) FB2PageDataItems*   items;
@property (nonatomic, readonly) FB2PageDataItems*   links;

+ (id)pageData;

@end
