//
//  NWBookmarkItem.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>

@interface NWBookmarkItem : NSObject
{
    NSString*   _title;
    
    int         _fb2ItemID;
    
    double      _positionInBook;
    
    int         _offset;
}

- (BOOL)loadFromDictionary:(NSDictionary*)dictionary;

- (NSDictionary*)dictionary;

- (id)initWithTitle:(NSString*)aTitle  fb2ItemID:(int)itemID;

- (id)init;

+ (NWBookmarkItem*)itemWithTitle:(NSString*)title fb2ItemID:(int)itemID;

+ (NWBookmarkItem*)itemFromDictionary:(NSDictionary*)dictionary;

@property (nonatomic, readonly) NSString* title;

@property (nonatomic, readonly) int fb2ItemID;

@property (nonatomic, assign) double positionInBook;

@property (nonatomic, assign) int offset;

@end
