##Quicklook Generator for Go Source files

Generates the thumbnail and preview passed to the appropriate QuickLook callbacks. The documentation for QuickLook programming on the Mac OS X developer website is pretty straight forward but there are also several online examples that are very helpful. Namely, [quicklook-csv](http://code.google.com/p/quicklook-csv/source/browse/GenerateThumbnailForURL.m). 

The last thing I plan on implementing is some __minor__ syntax highlighting. This feature was not implemented initially because I wanted to keep the preview panes consistent accross source files. Stock QuickLook does not syntax highlight for other source files. This makes sense since the point is to capture the quickest possible file representation without bogging the preview generator down on large file processing.


###Install

		cp GoLang.qlgenerator ~/Library/QuickLook/
		
###Uninstall

		rm -rf ~/Library/QuickLook/GoLang.qlgenerator

###Snapshot

![image](https://raw.github.com/chauvd/GoLang/master/GoLang/thumbnail.jpg)

Thumbnail

![image](https://raw.github.com/chauvd/GoLang/master/GoLang/preview.jpg)

Preview