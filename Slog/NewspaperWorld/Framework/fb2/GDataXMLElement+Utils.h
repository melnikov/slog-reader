//
//  GDataXMLElement+Utils.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 30.10.12.
//
//

#import "GDataXMLNode.h"

@interface GDataXMLElement (Utils)

- (GDataXMLElement*)firstChildElementWithName:(NSString*)elementName;

@end
