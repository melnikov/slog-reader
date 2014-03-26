//
//  FB2PageDataItem.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>

@interface FB2PageDataItem : NSObject <NSCopying>
{
    CGRect _frame;
        
    id _data;
    
    int _fb2ItemID;
}

+ (FB2PageDataItem*)itemWithData:(id)data frameRect:(CGRect)frame fb2ItemID:(int)ID;

- (id)initWithData:(id)aData
         frameRect:(CGRect)aFrame
         fb2ItemID:(int)ID;

@property (nonatomic, readonly) id data;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, readonly) int fb2ItemID;

@end
