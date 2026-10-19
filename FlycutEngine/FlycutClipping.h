//
//  FlycutClipping.h
//  Flycut
//
//  Flycut by Gennadiy Potapov and contributors. Based on Jumpcut by Steve Cook.
//  Copyright 2011 General Arcade. All rights reserved.
//
//  This code is open-source software subject to the MIT License; see the homepage
//  at <https://github.com/TermiT/Flycut> for details.
//

#import <Foundation/Foundation.h>

// Image clippings store only a reference to a PNG file on disk (never the image
// bytes) in their contents.  The contents are the file name, formatted as
// "<UUID>_<width>x<height>.png", inside +imageDirectoryPath.
extern NSString * const FlycutImageClippingType;
// Largest PNG that will be kept as an image clipping.
extern const NSUInteger FlycutMaxImageClippingBytes;

@interface FlycutClipping : NSObject {
// What must a clipping hold?
// The text
    NSString * clipContents;
// The text type
    NSString * clipType;
// The display length
    int clipDisplayLength;
// The display string
    NSString * clipDisplayString;
// Does it have a name?
    BOOL clipHasName;
// The app name it came from
    NSString * appLocalizedName;
// The the bunle URL of the app it came from
    NSString * appBundleURL;
// The time
    NSInteger clipTimestamp;
}

-(id) initWithContents:(NSString *)contents withType:(NSString *)type withDisplayLength:(int)displayLength withAppLocalizedName:(NSString *)localizedName withAppBundleURL:(NSString *)bundleURL withTimestamp:(NSInteger)timestamp;
/* -(id) initWithCoder:(NSCoder *)coder;
-(void) decodeWithCoder:(NSCoder *)coder; */
-(NSString *) description;

// set values
-(void) setContents:(NSString *)newContents setDisplayLength:(int)newDisplayLength;
-(void) setContents:(NSString *)newContents;
-(void) setType:(NSString *)newType;
-(void) setDisplayLength:(int)newDisplayLength;
-(void) setHasName:(BOOL)newHasName;

// Retrieve values
-(FlycutClipping *) clipping;
-(NSString *) contents;
-(int) displayLength;
-(NSString *) displayString;
-(NSString *) type;
-(NSString *) appLocalizedName;
-(NSString *) appBundleURL;
-(NSInteger) timestamp;
-(BOOL) hasName;

// Additional functions
-(void) resetDisplayString;

// Image clipping support
-(BOOL) isImage;
-(NSString *) imagePath; // nil unless this is an image clipping
+(BOOL) isImageType:(NSString *)type;
+(NSString *) imageDirectoryPath;
+(NSString *) imagePathForContents:(NSString *)contents;
+(BOOL) imageContentsAreValid:(NSString *)contents; // well-formed name whose file exists
// Converts PNG/TIFF data to PNG, writes it to the image directory and returns
// the contents string for a new image clipping, or nil on failure / too large.
+(NSString *) storeImageData:(NSData *)data;
// Deletes files in the image directory that are not in referencedContents.
// Files younger than a short grace period are kept, since they may belong to
// a clipping that is about to be added.
+(void) removeImageFilesNotIn:(NSSet *)referencedContents;

@end
