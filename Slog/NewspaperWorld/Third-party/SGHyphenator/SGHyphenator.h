//
//  SGHyphenator.h
//  SGHyphenator
//
//  Created by Samuel Grau on 2/28/13.
//  Copyright (c) 2013 Samuel Grau. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief There is a proven algorithm for hyphenation, for TeX-documents by Liang,
 * called Liang's Algorithm.
 *
 * @details
 * The original algorithm is described here: http://www.tug.org/docs/liang/
 *
 * A shorter explanation is given here:
 * http://xmlgraphics.apache.org/fop/0.95/hyphenation.html
 *
 * Patterns can be generated with a Unix tool called patgen:
 * http://linux.die.net/man/1/patgen
 *
 * But there are some patterns already created here:
 * http://www.ctan.org/tex-archive/language/hyphenation/
 *
 * Nevertheless the german word "Ofen" is not hyphenated as "O-fen" because
 * it is considered to look "ugly".
 *
 */
@interface SGHyphenator : NSObject

+ (instancetype)sharedInstance;

/**
 * Creates a TexHyphenator without exceptions
 *
 * @param pathToPatternFile Path to file with patterns, separated line by
 * line
 */
//- (void)initWithPatternFile:(NSString *)pathToPatternFile;

/**
 * Method to hyphenate word
 *
 * @param word Word to hyphenate
 *
 * @return a Collection of strings representing the hyphens
 */
- (NSArray *)hyphenate:(NSString *)word;

/**
 * Method to set the file containing the patterns line by line, separated by
 *
 * @param path Path to file containing pattern.
 */
- (void)setPatternFile:(NSString *)path;
- (void)setExceptionFile:(NSString *)path;

@end
