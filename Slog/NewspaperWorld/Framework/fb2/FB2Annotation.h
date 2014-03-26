//
//  FB2Annotation.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "FB2TextItem.h"

@interface FB2Annotation : FB2TextItem

- (BOOL)loadFromXMLElement:(GDataXMLElement*)element;
+ (FB2Annotation*)itemFromXMLElement:(GDataXMLElement *)element;

@property (nonatomic, readonly) FB2TextItem* text;

@end
