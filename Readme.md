//
//  Readme.md
//  Text
//  ----------------------------------
//  Developed with embedXcode
//
//  Project 	scraper
//  Created by 	michael on 09.01.15
//  Copyright 	© 2015 michael
//  License	<#license#>
//



Use preprocessor macros to do this. Go to Target -> Build Setting and choose "All configurations" (this is very important). Next find field "Preprocessor Macros".

In this field, add the flag in ex. PAID_VERSION. Now you can use this flag in code:

#ifdef PAID_VERSION
NSLog(@"Paid version");
#else
NSLog(@"Lite version");
#endif


Adding Version number automatically (only for .app):
https://developer.apple.com/library/ios/qa/qa1827/_index.html


Adding libxml2 in Xcode 4.3 / 5 / 6
Adding libxml2 is a big, fat, finicky pain in the ass. If you're going to do it, do it before you get too far in building your project.

You need to add it in two ways:

1. Target settings

Click on your target (not your project) and select Build Phases.

Click on the reveal triangle titled Link Binary With Libraries. Click on the + to add a library.

Scroll to the bottom of the list and select libxml2.dylib. That adds the libxml2 library to your project.

2. Project settings

Now you have to tell your project where to look for it three more times.

Select the Build Settings tab.

Scroll down to the Linking section. Under your projects columns double click on the Other Linker Flags row. Click the + and add -lxml2 to the list.

Still more.

In the same tab, scroll down to the Search Paths section.

Under your projects column in the Framework Search Paths row add /usr/lib/libxml2.dylib.

In the Header Search Paths and the User Header Search Paths row add $(SDKROOT)/usr/include/libxml2.

In those last two cases make sure that path is entered in Debug and Release.

3. Clean

Under the Product Menu select Clean.

Then, if I were you (and lets face it, I probably am) I'd quit Xcode and walk away. When you come back and launch you should be good to go.