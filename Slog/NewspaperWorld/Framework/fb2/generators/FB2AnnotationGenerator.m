//
//  FB2AnnotationGenerator.m
//  NewspaperWorld
//
//  Created by Эльдар Пикунов on 08.04.13.
//
//

#import "FB2AnnotationGenerator.h"
#import "FB2Annotation.h"
#import "FB2PageGeneratorContext.h"

@implementation FB2AnnotationGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (![item isKindOfClass:[FB2Annotation class]])
        return;

    FB2Annotation* annotation = (FB2Annotation*)item;
    annotation.textStyle.textType = TEXTTYPE_EPIGRAPH;

    if (!annotation.text.subItems.count)
        return;
    
    for (FB2Item* subItem in annotation.text.subItems)
    {
        [subItem generatePagesWithContext:context parentStyle:annotation.textStyle];
    }
    
    [context nextStringWithLineHeight:annotation.textStyle.textFont.lineHeight];
   

     if (item.ID.length > 0)
         [context.page.nodeIDs addObject:item.ID];
}

@end
