//
//  FB2Date.h
//  NewspaperWorld
//

#import "FB2TextItem.h"
#import "GDataXMLNode.h"

@interface FB2Date : FB2TextItem

+ (FB2Date*)itemFromXMLElement:(GDataXMLElement *)element;

@property (nonatomic, readonly) NSString* dateString;

@end
