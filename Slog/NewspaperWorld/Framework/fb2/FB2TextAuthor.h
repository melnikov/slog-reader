//
//  FB2TextAuthor.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2TextAuthor : FB2TextItem

+ (FB2TextAuthor*)itemFromXMLElement:(GDataXMLElement*)element;

@end
