//
//  FB2StrikeThrough.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2StrikeThrough : FB2TextItem

+ (FB2StrikeThrough*)itemFromXMLElement:(GDataXMLElement*)element;

@end
