##Quicklook Generator for Go Source files

Thumbnail and preview UI passed to the appropriate QuickLook callbacks. The QuickLook programming guide on the Mac developer website is pretty straight forward but there are several other online examples that proved helpful. Namely, [quicklook-csv](http://code.google.com/p/quicklook-csv/source/browse/GenerateThumbnailForURL.m). It was a great opportunity to get more hands on with Objc and inevitably produce something useful. 

I plan on implementing __minor__ syntax highlighting. This feature was not initially implemented because I wanted to keep the preview panes consistent across source files. Stock QuickLook does not syntax highlight for other source files. This makes sense since the point is to capture the quickest possible file representation without bogging the preview generator down on large file processing.


###Install

Copy the __GoLang.qlgenerator__ into `~/Library/QuickLook` after building the project.
		
###Uninstall

		rm -rf ~/Library/QuickLook/GoLang.qlgenerator

###Troubleshooting

If there is a problem updating generated QuickLook information try:

	qlmanage -r 
	
		or
	
	qlmanage -r cache

and restart your machine.

###Snapshot

![image](https://raw.github.com/chauvd/GoQL/master/GoLang/thumbnail.jpg)

Thumbnail

![image](https://raw.github.com/chauvd/GoQL/master/GoLang/preview.jpg)

Preview