#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Cocoa/Cocoa.h>

#define THUMB_WIDTH  600
#define THUMB_HEIGHT 800
#define ASPECT       0.5
#define BADGE        @".go"

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);
static CGContextRef createRGBABitmapContext(CGSize pixelSize);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
  @autoreleasepool {
    NSString *data = [NSString stringWithContentsOfURL:(__bridge NSURL *)url encoding:NSUTF8StringEncoding error:nil];
    CGSize imgSize = CGSizeMake(THUMB_WIDTH, THUMB_HEIGHT);
    
    CGContextRef cgContext = createRGBABitmapContext(imgSize);
    
    if (!QLThumbnailRequestIsCancelled(thumbnail)) {
      if (cgContext) {
        CGContextScaleCTM(cgContext, 1.f, -1.f);
        CGContextTranslateCTM(cgContext, 0, -imgSize.height);
        
        CGRect imgRect = CGRectMake(0, 0, imgSize.width, imgSize.height);
        
        NSGraphicsContext *nsContext;
        nsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)cgContext flipped:YES];
        
        if (nsContext) {
          [NSGraphicsContext saveGraphicsState];
          [NSGraphicsContext setCurrentContext:nsContext];
          
          NSRect text = NSRectFromCGRect(imgRect);
          
          NSFont *textFont = [NSFont systemFontOfSize:8.f];
          NSColor *textColor = [NSColor blackColor];
          NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          textFont, NSFontAttributeName,
                                          textColor, NSForegroundColorAttributeName, nil];
          
          [data drawInRect:text withAttributes:textAttributes];
        }
        else {
          NSLog(@"Could not initialize ncContext!");
        }
        
        CGImageRef fullIcon = CGBitmapContextCreateImage(cgContext);
        CGImageRef usedIcon = CGImageCreateWithImageInRect(fullIcon, imgRect);
        CGImageRelease(fullIcon);
        
        CGContextRef thumbCGContext = QLThumbnailRequestCreateContext(thumbnail, imgSize, false, nil);
        CGContextDrawImage(thumbCGContext, imgRect, usedIcon);
        CGImageRelease(usedIcon);
        
        NSGraphicsContext *thumbNSContext = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)thumbCGContext flipped:NO];
        
        if (thumbNSContext) {
          [NSGraphicsContext saveGraphicsState];
          [NSGraphicsContext setCurrentContext:thumbNSContext];
          CGFloat badgeFontSize = ceilf(imgSize.width * 0.38f);
          NSFont *badgeFont = [NSFont boldSystemFontOfSize:badgeFontSize];
          NSColor *badgeColor = [NSColor colorWithCalibratedRed:0/255.f green:0/255.f blue:255/255.f alpha:0.8f];
          
//          NSShadow *badgeShadow = [[NSShadow alloc] init];
//          [badgeShadow setShadowOffset:NSMakeSize(0.f, 0.f)];
//          [badgeShadow setShadowBlurRadius:imgSize.width * 0.008f];
//          [badgeShadow setShadowColor:[NSColor blueColor]];
          
          NSDictionary *badgeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           badgeFont, NSFontAttributeName,
                                           badgeColor, NSForegroundColorAttributeName, nil];
//                                           badgeShadow, NSShadowAttributeName, nil];
          
          NSSize badgeSize = [BADGE sizeWithAttributes:badgeAttributes];
          CGFloat badgeX = (imgSize.width / 2) - (imgSize.width / 3.5);
          CGFloat badgeY = (imgSize.height * 0.030f);
          
          NSRect badgeRect = NSMakeRect(badgeX, badgeY, 0.f, 0.f);
          badgeRect.size = badgeSize;
          
          [BADGE drawWithRect:badgeRect options:NSStringDrawingUsesLineFragmentOrigin attributes:badgeAttributes];
        }
        else {
          NSLog(@"Could not initialize thumbCGContext!");
        }
        
        QLThumbnailRequestFlushContext(thumbnail, thumbCGContext);
        CGContextRelease(thumbCGContext);
        CGContextRelease(cgContext);
      }
    }
    else {
      NSLog(@"Could not create snapshot of file form path");
    }
  }
  
  return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}

// From example...
static CGContextRef createRGBABitmapContext(CGSize pixelSize)
{
  NSUInteger width = pixelSize.width;
  NSUInteger height = pixelSize.height;
  NSUInteger bitmapBytesPerRow = width * 4;                               
  NSUInteger bitmapBytes = bitmapBytesPerRow * height;
  
  // allocate needed bytes
  void *bitmapData = malloc(bitmapBytes);
  if (NULL == bitmapData) {
    fprintf(stderr, "Oops, could not allocate bitmap data!");
    return NULL;
  }
  
  // create the context
  CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
  CGContextRef context = CGBitmapContextCreate(bitmapData, width, height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(colorSpace);
  
  // context creation fail
  if (NULL == context) {
    free(bitmapData);
    fprintf(stderr, "Oops, could not create the context!");
    return NULL;
  }
  
  return context;
}
