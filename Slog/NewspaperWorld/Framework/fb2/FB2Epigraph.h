//
//  FB2Epigraph.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "FB2TextItem.h"
#import "FB2TextAuthor.h"

@interface FB2Epigraph : FB2TextItem

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element;
+ (FB2Epigraph*)itemFromXMLElement:(GDataXMLElement *)element;

@property (nonatomic, readonly) FB2TextAuthor* textAuthor;
@property (nonatomic, readonly) FB2TextItem* text;

@end
