![screenshot](http://www.jeffreythompson.org/blog/wp-content/uploads/2012/12/02-web.png)

Pixel Sorting
============

A set of experiments in pixel sorting using Processing

\- \- \-

#### Seed Sorting
Using either edge-detection or random choice, start with a set of 'seed' pixels, grab all neighbors within a 1px radius, sort those, and repeat the process.

\[ [example](http://www.jeffreythompson.org/blog/2013/01/14/more-seed-sorting/) \]

#### Sort Image By Least Resistance
Similar to the 'seam carving' example, this is a little softer movement across the image by looking for least change between the current pixel and its neighbors.

#### Sort Image By N-px
Sees the image as a linear list of pixel values (rather than 2d), sorting in chunks.  Includes wrapping for weird distortions and patterns.

\[ [example](http://www.jeffreythompson.org/blog/2012/11/15/sort-by-n-pixels/) \]

#### Sort Image By N-px Block
Similar to the previous, but sorts the image by blocks.

See this video [this video](http://vimeo.com/53651911) for an example.

#### Sort Pixel Portal
Sorts a random column of pixels, then looks for the closest match to the last pixel in that column.  Sorts and repeats.  Imagined as a kind of "Chutes and Ladders" within the image.

#### Sort Through Seam Carving
Based on the algorithm used for Photoshop's "Content-Aware Scaling", find the path of "least energy" through the image, starting at the bottom center.  That path is sorted, then shifted over 1px and repeated across the entire image.  Versions include one phase, as well as rotate-and-iterate for serious pixel-mashing.

\[ [example](http://www.jeffreythompson.org/blog/2012/12/06/seam-sorting-rotate-and-iterate/) \]

#### amazing work
#### Spiral Sort
The entire image is loaded in order from outer edge in, then sorted and placed back.

\[ [example](http://www.jeffreythompson.org/blog/2012/12/10/spiral-sorting/) \]

\- \- \-

\[ all code available under [Creative Commons BY-NC-SA license](http://creativecommons.org/licenses/by-nc-sa/3.0/) - feel free to use but [please let me know](http://www.jeffreythompson.org) \]
