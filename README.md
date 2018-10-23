# grandma2_colorpicker_plugin
=============================
A LUA plugin to automaticly create a color picker layout view.

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

---

## Colors

The colors are in the following order:
White, Red, Orange, Yellow, Green, Seagreen, Cyan, Blue, Lavender, Violet, Magenta, Pink.

---

## Images 
The images folder contains all the images you can use in this plugin.

---

## Further development

When I have some more free time, I will further develop this plugin.

### Next Features

1. Automaticly change the icon of each macro in the layout view --> If you know how this can be achieved via the commandline, please let me know by adding an issue.
2. Making sure it works with different colors.