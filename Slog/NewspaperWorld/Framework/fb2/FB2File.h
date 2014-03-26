//
//  FB2File.h
//

@class FB2Description;
@class FB2Body;

@interface FB2File : NSObject
{
@private
    FB2Description* _description;
    
    NSMutableArray* _bodies;
    
    NSMutableArray* _binaries;
}

- (BOOL)openFb2File:(NSString *)filePath;

- (BOOL)openFb2FileWithData:(NSData *)fb2Data;

- (NSData*)dataForBinaryID:(NSString*)binaryID;

+ (int)nextID;

@property (nonatomic, readonly)  NSString* bookTitle;

@property (nonatomic, readonly)  NSString* bookAuthor;

@property (nonatomic, readonly)  NSArray* bodies;

@property (nonatomic, readonly)  NSArray* binaries;

@property (nonatomic, readonly)  UIImage* bookCover;

@property (nonatomic, readonly)  FB2Body* notes;

@end
