//
//  FB2CiteGenerator.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 09.04.13.
//
//

#import "FB2CiteGenerator.h"
#import "FB2Cite.h"

@implementation FB2CiteGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (![item isKindOfClass:[FB2Cite class]])
        return;

    FB2Cite* cite = (FB2Cite*)item;
    FB2TextStyle * style = parentStyle;
    style.textType = TEXTTYPE_EPIGRAPH;
    [cite generatePagesWithContext:context parentStyle:style];
    [cite.textAuthor generatePagesWithContext:context parentStyle:cite.textStyle];    
}
@end
