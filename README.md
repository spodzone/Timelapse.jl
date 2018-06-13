Timelapse.jl
============

Many years ago, I created the original [Timelapse.py](https://github.com/spodzone/timelapse.py) utility, in Python.

This is a partial rewrite, rewritten in Julia for speed.

Overview
--------

The purpose of Timelapse.jl is to generate a larger number of images by linear interpolation of a small set. 

Typically, you might take a camera out and make images every few (5, 10, 15) seconds. However, if you're triggering the camera by hand, or otherwise mess-up and fail to take a shot at the exact same intervals, the resultant movie might look irregular or jerky. This script allows you to generate (potentially many more) frames by smoothly interpolating between the nearest two frames.

Example: you shoot frames at times
0, 5, 10, 15.5, 25, 30, 35.2, 40.1, 45, 49.5, 56, 61 seconds since start. Note the missing frame at 20s and the fractional parts arising from manual triggering.

If you run timelapse.jl requesting 24 output frames, it will compute the nearest frame to the timestamps
0.0, 2.54167, 5.08333, 7.625, .... , 17.7917, 20.3333, 22.875, ... 55.9167, 58.4583, 61.0
seconds. In this case, "nearest" is defined as identifying the two images either side of the desired timestamp and the fractional part in between them, and performing linear interpolation.

Notably, it currently determines the timestamp for each image by using the file modification time. 

Requirements
------------

   * familiariry with a Linux, Unix or Cygwin environment
   * [Julia](http://julialang.org/)
   * `Pkg.add("Images")`
   * optional, but very useful: exiv2

It will work with an image format that the Images module understands - testing uses simple JPEGs.


Usage
-----

   * Create and populate an input directory, such as `./images-in/*.jpg`
   * use `exiv2 -T rename images-in/*jpg` to set the file modification times
   * `mkdir images-out`
   * `./timelapse.jl 1800 images-in images-out`
   * Create a movie using `ffmpeg -f image2 -i images-out/image-%05d.jpg -sameq -r 50 timelapse.flv`

A couple of sample images are included - by running the interpolation you'll see a fade between colour and desaturated+vignetted versions.

Performance
-----------

Representative example - a baseline, but your mileage will vary:

   * Intel Core i7 CPU at 2.2GHz
   * input: 95 JPEG images (sRGB, 1080p)
   * output: 1000 JPEGs (similar)
   * time taken: 3.5 minutes

ToDo
----

   * EXIF-awareness.
   * Global and image-specific modifiers: crop, resize, gamma, overlays (maybe). Meanwhile, use other software to manipulate the input images in advance.
