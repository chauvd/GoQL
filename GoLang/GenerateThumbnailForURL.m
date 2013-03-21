#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include <Cocoa/Cocoa.h>
#include <WebKit/WebKit.h>


OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
  @autoreleasepool {
    if (QLThumbnailRequestIsCancelled(thumbnail)) {
      return noErr;
    }
    
    NSString *_content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url encoding:NSUTF8StringEncoding error:nil];
    
    if (_content) {
      NSString *_html = [NSString stringWithFormat:@"<html><body><pre>%@</pre></body></html>", _content];
      NSData *_data   = [_html dataUsingEncoding:NSUTF8StringEncoding];
      
      NSRect _rect = NSMakeRect(0.0, 0.0, 600.0, 800.0);
      float _scale = maxSize.height / 800.0;
      NSSize _scaleSize = NSMakeSize(_scale, _scale);
      CGSize _thumbSize = NSSizeToCGSize((CGSize) { maxSize.width * (600.0/800.0), maxSize.height});
      
      WebView *_webView = [[WebView alloc] initWithFrame:_rect];
      [_webView scaleUnitSquareToSize:_scaleSize];
      [[[_webView mainFrame] frameView] setAllowsScrolling:NO];
      [[_webView mainFrame] loadData:_data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
      
      while([_webView isLoading]) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
      }
      
      [_webView display];
      
      CGContextRef _context = QLThumbnailRequestCreateContext(thumbnail, _thumbSize, false, NULL);
      if (_context) {
        NSGraphicsContext* _graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)_context flipped:_webView.isFlipped];
        [_webView displayRectIgnoringOpacity:_webView.bounds inContext:_graphicsContext];
        QLThumbnailRequestFlushContext(thumbnail, _context);
        CFRelease(_context);
      }
    }
    else {
      NSLog(@"Could not get source from CFURLref");
    }
  }
  
  return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
