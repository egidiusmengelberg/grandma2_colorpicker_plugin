# grandma2_colorpicker_plugin

Attention: this is a fork and therefore an extended version of the plugin written by Egidius Mengelberg.

A LUA plugin to automatically create a color picker layout view.
I also added a function to create High and Low FX presets for use in a effect engine.
This is the plugin called HighLowFX.lua.

### Be sure to first run the colorpicker and then the HighLowFX plugin! 
I have not tested it the otherway around.  
But I will try to merge the two plugins before the start of 2019

## Configuration
In the ColorPicker.lua file, you will find the config section at the top.

With `grpNum`, you can change the groups you would like to use in your color picker.
Just edit the numbers in the array. They correspond with the group pool items.
You can add as many as you would like.

`macStart` and `seqStart` are the pool items where the plugin will start with adding all the macros and sequences.

`startingPage` and `startingFader` correspond to the page and fader where all your sequences will be stored.

`layoutView` sets the layout view where all the macros will be stored to.
And `spacing` sets the space between the macros in the layout pool.

With `imgStart` you can set the image pool item where the plugin wll start copying images to.
The `allImgStart` defines the place where the images for the All macros will be stored.

`filledImages` constains an array of image pool numbers with all the filled images.
The order of these images is the same as the colors. Please read below to find out what the default order is.

`unfilledImages` contains the array of image pool numbers with all the unfilled images. 

## Colors

The colors are in the following order:
White, Red, Orange, Yellow, Green, Seagreen, Cyan, Blue, Lavender, Violet, Magenta, Pink.


## Images 
The images folder contains all the images you can use in this plugin.

### New Features

1. Added the automated creation of the ready to use layout view with assigned images
so there is no need to assign the specific images from the pool to the layout view items. (Leon Reucher)
