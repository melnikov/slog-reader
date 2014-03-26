//
//  FB2Cite.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2Cite : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@property (nonatomic, readonly) FB2TextItem* textAuthor;

@property (nonatomic, readonly) NSString* ID;

@end
