//
//  GDataXMLElement+Utils.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 30.10.12.
//
//

#import "GDataXMLElement+Utils.h"

@implementation GDataXMLElement (Utils)

- (GDataXMLElement*)firstChildElementWithName:(NSString*)elementName
{
    NSArray* children = [self elementsForName:elementName];
    if (children.count > 0)
        return [children objectAtIndex:0];
    
    return nil;
}
@end
