//
//  FlycutClipping.m
//  Flycut
//
//  Flycut by Gennadiy Potapov and contributors. Based on Jumpcut by Steve Cook.
//  Copyright 2011 General Arcade. All rights reserved.
//
//  This code is open-source software subject to the MIT License; see the homepage
//  at <https://github.com/TermiT/Flycut> for details.
//


#import "FlycutClipping.h"
#import <TargetConditionals.h>
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

NSString * const FlycutImageClippingType = @"com.generalarcade.flycut.image";
const NSUInteger FlycutMaxImageClippingBytes = 20 * 1024 * 1024;
// Source pasteboard data above this size is not even converted.
static const NSUInteger FlycutMaxImageSourceBytes = 100 * 1024 * 1024;
// Unreferenced image files younger than this are left alone by cleanup.
static const NSTimeInterval FlycutImageCleanupGracePeriod = 60.0;

@implementation FlycutClipping

-(id) init
{
    [self initWithContents:@""
                  withType:@""
         withDisplayLength:40
      withAppLocalizedName:@""
          withAppBundleURL:nil
             withTimestamp:0];
    return self;
}

-(id) initWithContents:(NSString *)contents withType:(NSString *)type withDisplayLength:(int)displayLength withAppLocalizedName:(NSString *)localizedName withAppBundleURL:(NSString*)bundleURL withTimestamp:(NSInteger)timestamp
{
    [super init];
    clipContents = [[[NSString alloc] init] retain];
    clipDisplayString = [[[NSString alloc] init] retain];
    clipType = [[[NSString alloc] init] retain];

    [self setContents:contents setDisplayLength:displayLength];
    [self setType:type];
    [self setAppLocalizedName:localizedName];
    [self setAppBundleURL:bundleURL];
    [self setTimestamp:timestamp];
    [self setHasName:false];
    
    return self;
}

/* - (id)initWithCoder:(NSCoder *)coder
{
    NSString * newContents;
    int newDisplayLength;
    NSString *newType;
    BOOL newHasName;
    if ( self = [super init]) {
        newContents = [NSString stringWithString:[coder decodeObject]];
        [coder decodeValueOfObjCType:@encode(int) at:&newDisplayLength];
        newType = [NSString stringWithString:[coder decodeObject]];
        [coder decodeValueOfObjCType:@encode(BOOL) at:&newHasName];
        [self 	     setContents:newContents
                setDisplayLength:newDisplayLength];
        [self setType:newType];
        [self setHasName:newHasName];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    int codeDisplayLength = [self displayLength];
    BOOL codeHasName = [self hasName];
    [coder encodeObject:[self contents]];
    [coder encodeValueOfObjCType:@encode(int) at:&codeDisplayLength];
    [coder encodeObject:[self type]];
    [coder encodeValueOfObjCType:@encode(BOOL) at:&codeHasName];
} */

-(void) setContents:(NSString *)newContents setDisplayLength:(int)newDisplayLength
{
    id old = clipContents;
    [newContents retain];
    clipContents = newContents;
    [old release];
    if ( newDisplayLength  > 0 ) {
        clipDisplayLength = newDisplayLength;
    }
   [self resetDisplayString];
}

-(void) setContents:(NSString *)newContents
{
    id old = clipContents;
    [newContents retain];
    clipContents = newContents;
    [old release];
    [self resetDisplayString];
}

-(void) setType:(NSString *)newType
{
    BOOL wasImage = [self isImage];
    id old = clipType;
    [newType retain];
    clipType = newType;
    [old release];
    if ( wasImage != [self isImage] )
        [self resetDisplayString];
}

-(void) setDisplayLength:(int)newDisplayLength
{
    if ( newDisplayLength > 0 && clipDisplayLength != newDisplayLength ) {
        clipDisplayLength = newDisplayLength;
        [self resetDisplayString];
    }
}

-(void) setAppLocalizedName:(NSString *)new
{
    id old = appLocalizedName;
    [new retain];
    appLocalizedName = new;
    [old release];
}

-(void) setAppBundleURL:(NSString *)new
{
    id old = appBundleURL;
    [new retain];
    appBundleURL = new;
    [old release];
}

-(void) setTimestamp:(NSInteger)newTimestamp
{
    clipTimestamp = newTimestamp;
}

-(void) setHasName:(BOOL)newHasName
{
        clipHasName = newHasName;
}

-(void) resetDisplayString
{
    NSString *newDisplayString, *firstLineOfClipping, *trimmedString;
	NSUInteger start, lineEnd, contentsEnd;
	NSRange startRange = NSMakeRange(0,0);
	NSRange contentsRange;
	// We're resetting the display string, so release the old one.
    [clipDisplayString release];
    if ( [self isImage] ) {
        clipDisplayString = [[FlycutClipping imageDisplayStringForContents:clipContents] retain];
        return;
    }
	// We want to restrict the display string to the clipping contents through the first line break.
    trimmedString = [clipContents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [trimmedString getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd forRange:startRange];
	contentsRange = NSMakeRange(0, contentsEnd);
	firstLineOfClipping = [trimmedString substringWithRange:contentsRange];
    if ( [firstLineOfClipping length] > clipDisplayLength ) {
        newDisplayString = [[NSString stringWithString:[firstLineOfClipping substringToIndex:clipDisplayLength]] stringByAppendingString:@"…"];   
    } else {
        newDisplayString = [NSString stringWithString:firstLineOfClipping];
    }
    [newDisplayString retain];
    clipDisplayString = newDisplayString;
}

-(NSString *) description
{
    NSString *description = [[super description] stringByAppendingString:@": "];
    description = [description stringByAppendingString:[self displayString]];   
    return description;
}

-(FlycutClipping *) clipping
{
    return self;
}

-(NSString *) contents
{
//    NSString *returnClipContents;
//    returnClipContents = [NSString stringWithString:clipContents];
//    return returnClipContents;
    return clipContents;
}

-(NSString *) appLocalizedName
{
    return appLocalizedName;
}

-(NSString *) appBundleURL
{
    return appBundleURL;
}

-(NSInteger) timestamp
{
    return clipTimestamp;
}

-(int) displayLength
{
    return clipDisplayLength;
}

-(NSString *) type
{
    return clipType;
}

-(NSString *) displayString
{
    // QUESTION
    // Why doesn't the below work?
    // NSString *returnClipDisplayString;
    // returnClipDisplayString = [NSString stringWithString:clipDisplayString];
    // return returnClipDisplayString;
    return clipDisplayString;
}

-(BOOL) hasName
{
    return clipHasName;
}

#pragma mark - Image clippings

-(BOOL) isImage
{
    return [FlycutClipping isImageType:clipType];
}

-(NSString *) imagePath
{
    if ( ![self isImage] )
        return nil;
    return [FlycutClipping imagePathForContents:clipContents];
}

+(BOOL) isImageType:(NSString *)type
{
    return [type isKindOfClass:[NSString class]] && [type isEqualToString:FlycutImageClippingType];
}

+(NSString *) imageDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if ( [paths count] == 0 )
        return nil;
    return [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Flycut"] stringByAppendingPathComponent:@"Images"];
}

// A valid image file name is a single path component ending in .png, so that a
// stored reference can never point outside the image directory.
+(BOOL) imageContentsAreWellFormed:(NSString *)contents
{
    if ( ![contents isKindOfClass:[NSString class]] || [contents length] < 5 || [contents length] > 128 )
        return NO;
    if ( ![[contents lastPathComponent] isEqualToString:contents]
        || [contents hasPrefix:@"."]
        || [contents rangeOfString:@"/"].location != NSNotFound )
        return NO;
    return [[[contents pathExtension] lowercaseString] isEqualToString:@"png"];
}

+(NSString *) imagePathForContents:(NSString *)contents
{
    if ( ![self imageContentsAreWellFormed:contents] )
        return nil;
    NSString *directory = [self imageDirectoryPath];
    if ( nil == directory )
        return nil;
    return [directory stringByAppendingPathComponent:contents];
}

+(BOOL) imageContentsAreValid:(NSString *)contents
{
    NSString *path = [self imagePathForContents:contents];
    return nil != path && [[NSFileManager defaultManager] fileExistsAtPath:path];
}

// Contents look like "<UUID>_1280x720.png".  Parse the pixel size back out so no
// file access is needed to build the menu label.
+(NSString *) imageDisplayStringForContents:(NSString *)contents
{
    if ( [contents isKindOfClass:[NSString class]] ) {
        NSString *base = [contents stringByDeletingPathExtension];
        NSRange underscore = [base rangeOfString:@"_" options:NSBackwardsSearch];
        if ( underscore.location != NSNotFound ) {
            NSArray *parts = [[base substringFromIndex:underscore.location + 1] componentsSeparatedByString:@"x"];
            if ( [parts count] == 2 ) {
                NSInteger width = [[parts objectAtIndex:0] integerValue];
                NSInteger height = [[parts objectAtIndex:1] integerValue];
                if ( width > 0 && height > 0 )
                    return [NSString stringWithFormat:@"[Image %ld×%ld]", (long)width, (long)height];
            }
        }
    }
    return @"[Image]";
}

+(NSString *) storeImageData:(NSData *)data
{
#if TARGET_OS_OSX
    if ( nil == data || [data length] == 0 || [data length] > FlycutMaxImageSourceBytes )
        return nil;

    NSString *result = nil;
    @autoreleasepool {
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:data];
        if ( nil != rep && [rep pixelsWide] > 0 && [rep pixelsHigh] > 0 ) {
            NSData *png = nil;
            static const unsigned char pngSignature[8] = {0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A};
            if ( [data length] > 8 && 0 == memcmp([data bytes], pngSignature, 8) )
                png = data; // Already PNG; keep the original bytes.
            else
                png = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];

            if ( nil != png && [png length] > 0 && [png length] <= FlycutMaxImageClippingBytes ) {
                NSString *directory = [self imageDirectoryPath];
                if ( nil != directory
                    && [[NSFileManager defaultManager] createDirectoryAtPath:directory
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:nil] ) {
                    NSString *name = [NSString stringWithFormat:@"%@_%ldx%ld.png",
                                      [[NSUUID UUID] UUIDString],
                                      (long)[rep pixelsWide], (long)[rep pixelsHigh]];
                    if ( [png writeToFile:[directory stringByAppendingPathComponent:name] atomically:YES] )
                        result = [name retain];
                }
            }
        }
    }
    return [result autorelease];
#else
    return nil;
#endif
}

+(void) removeImageFilesNotIn:(NSSet *)referencedContents
{
    NSString *directory = [self imageDirectoryPath];
    if ( nil == directory )
        return;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    NSDate *now = [NSDate date];
    for ( NSString *file in files ) {
        if ( [referencedContents containsObject:file] || ![self imageContentsAreWellFormed:file] )
            continue;
        NSString *path = [directory stringByAppendingPathComponent:file];
        NSDate *modified = [[fileManager attributesOfItemAtPath:path error:nil] fileModificationDate];
        if ( nil != modified && [now timeIntervalSinceDate:modified] < FlycutImageCleanupGracePeriod )
            continue;
        [fileManager removeItemAtPath:path error:nil];
    }
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    FlycutClipping * otherClip = (FlycutClipping *)other;
    return (/*[self.type isEqualToString:otherClip.type] &&*/ // Type is under-utilized a this time and will mismatch on cross-device (macOS <-> iOS) usage.  This should be revisited once we have support for more than just raw text clippings.
            [self.contents isEqualToString:otherClip.contents]);
}



-(void) dealloc
{
    [clipContents release];
    [clipType release];
    [appLocalizedName release];
    [appBundleURL release];
    clipDisplayLength = 0;
    [clipDisplayString release];
    clipHasName = 0;
    [super dealloc];
}
@end
