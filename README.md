## Welcome to IRIS Processing
IRIS (Interference Reflectance Imaging Sensor) is a label-free microarray technology, capable of making hundreds or thousands of measurements of biological affinity and concentration simultaneously. IRIS Processing is an essential utility for converting raw data collected with IRIS to measurements of molecular binding. 

You can learn more about IRIS on our lab website - https://ultra.bu.edu - or the following selected publications:
* G. G. Daaboul _et al._ ["LED-based Interferometric Reflectance Imaging Sensor for quantitative dynamic monitoring of biomolecular interactions,"](http://www.sciencedirect.com/science/article/pii/S0956566310006524) Biosensors and Bioelectronics, January 2011.
* E. Ozkumur _et al._ ["Label-free microarray imaging for direct detection of DNA hybridization and single-nucleotide mismatches,"](http://www.sciencedirect.com/science/article/pii/S0956566309007106) Biosensors and Bioelectronics, March 2010.
* E. Ozkumur _et al._ ["Label-free and dynamic detection of biomolecular interactions for high-throughput microarray applications,"](http://www.pnas.org/content/105/23/7988) Proceedings of the National Academy of Science, June 2008.

## Getting Started 

### Dependencies
* IRIS Processing is supported on MATLAB version 2013a or later, on either Windows or OS X.
* It's helpful to have a specialized image viewing and analysis program. MATLAB works alright for this, but [ImageJ](http://imagej.nih.gov/ij/) is highly recomended.
* At this time, IRIS Processing does not provide any microarray analysis utilities (spot finding, etc). You will probably want to use a dedicated [microarray analysis software](https://duckduckgo.com/?q=microarray%20analysis%20software) later in your analysis pipeline.

### Installation
IRIS Processing functions and scripts are run entirely from the MATLAB command window. If you're new to programming, don't worry - there's very little you need to know about MATLAB or programming in general.

Download the latest version of the program from http://dd7ler.github.io/iris-processing/ and unpack it somewhere on your computer that you have write access. The 'MATLAB' subdirectory in your 'Documents' folder is not a bad place. You'll want to edit and save your MATLAB path to include this directory. One way to do this is by starting MATLAB and typing this into the command window:
```
addpath(genpath('/full/path/to/iris-processing'));
```

### Configuration

IRIS Processing needs to know the spectra of the illumination that your IRIS instrument uses. At this time, IRIS Processing is configured with the spectra measured from a particular ACCULED composite RGYB surface-mounted LED packages that we have been using in all of our new instruments. If you are unsure if this is the right set of spectra for your instrument or want to record them yourself to use, don't hesistate to contact me at derin@bu.edu about how to get that set up.

### Image formats

At this time, IRIS Processing supports TIFF images (acquired through Micro-Manager, for example) or \*.mat MATLAB data files that are used by Zoiray acquisition software. 

### Image acquisition considerations

IRIS Processing is sensitive to small spatial variations in the illumination brightness. In order to account for spatial variations in illumination, images are always first normalized by acquiring reference images of a featureless reflecting bare Silicon substrate (called 'mirror' images). Mirror images generally need only be acquired when the optical alignment of the instrument is changed (e.g., if an optical component or stage component is adjusted). Acquire a mirror image in exactly the same way you do normally - use every channel, and average several frames for each channel.

## Using IRIS Processing
There are two steps to using IRIS Processing for converting IRIS raw data to film thickness measurements. The first step is to generate a lookup table. The second step is to use the lookup table on the IRIS raw data.

### Generating a lookup table
A single script is provided for generating look up tables, called `generateLUT`. This script has two methods - `accurate` and `relative`. The `accurate` method performs an additional step in order to measure the background film thickness with high precision. The `relative` method does not perform this step - intead, you must provide the baseline film thickness.

Unfortunately, the `accurate` method can only be used with films thicker than a certain threshold. If you acquired measurements on IRIS substrates in air, you can use the accurate method for film thicknesses over 80nm. If you aquired measurements on IRIS substrates immersed in water or buffer, this threshold is closer to 200nm. The relative method may be used with any film thickness in any conditions, but *a priori* knowledge of the film thickness is required. The relative method can provide equally accurate measurements of spot heights if you are confident you know the film thickness precisely (nominally within 5%).

When you run the script, you will be presented with a dialog box with the following parameters that you must provide:
* **Immersion** - select `air` or `water` to indicate the immersion medium.
* **Film Material** - Select `SiO2` or `PMMA` to indicate the film material.
* **Approximate film thickness d** - enter the film thickness to the best of your knowledge, in nanometers. **NOTE:** the `accurate` method uses this number as an initial guess, and uses nonlinear least squares fitting to accurately measure the average baseline film thickness. In contrast, the `relative` method will not perform this fitting - it will simply use your input as the ground truth.
* **Increment** - This defines the resolution of the lookup table. A higher-resolution table will take longer to generate, but provide more precise measurements.
* **look above** and **look below** - Together, these define the span of the lookup table. Using `look below = 5` and `look above = 10` will generate a lookup table over the range `(d-5, d+10)`, where `d` is the average baseline film thickness. If you select the `accurate` method, the baseline thickness `d` will be the measured film thickness (the `relative` method will set `d` to the approximate value you provide). A larger range is sometimes required for microarray spots with very high immobilization, but a larger lookup table will take longer to generate.
* **Temperature** - Enter the temperature, in degrees celcius.
* **Method** - Select either `accurate` or `relative`, based on your film thickness and immersion medium (see the beginning of this section for details).

After setting these, you will be presented with a dialog box to open the image you wish to measure. Then, you will be presented with a dialog box to select a mirror file. The mirror image data must have the same height and width as the image you are measuring.

You will next be presented with a window of to select a region of bare Silicon. The purpose of this to account for temporal variations in illumination (exposure time, temporal fluctuations in illumination intensity, etc). Select a region by drawing a rectangle using click-and-drag. You can resize and move this rectangle, which should include only bare Silicon. Try to select a region that is blemish-free - dark patches caused by dust particles can reduce the quality of this measurement. Accept your crop region by double-clicking within your rectangle.

Following this, you will be presented with a similar window, this time asking you to select a region of film. Again, try to select a region of film that is blemish-free, and includes no spots or other features. The thickness of the film in the region you select will either be measured (using curvefitting) or set to the number you provided in the first dialog box, and used as the baseline for the look-up table. Region selection works the same as in the previous windows.

Once you have provided the values and selected the regions, a progressbar will show while the lookup table is generated. Following the completion of this step, film thicknesses across the entire image will be measured and displayed in a window for your inspection. One way to expore these results is with the MATLAB data cursor. Regions which were the limits of the lookup table (either too bright or too dim) are set to 0, and display as black. During this step, see that your spots were all measured appropriately. You may find that some of your spots are partly black. During microarray drying, salt deposition onto the spots is normal. It can result in small patches on the spot which are much (perhaps 2x) brighter than the background. If this is the cause of black regions within your spots, everything is working normally. However, if you have spots with very high immobilization, it is sometimes possible for the spot height to exceed the maximum value of the lookup table. If this seems to be the case, you will need to generate a new lookup table with a larger value of *look above*.

Once you close the results window, you will be presented with a dialog box asking where you would like to save the results. This results file contains not only the measured film image but also the lookup table that was used.

### Applying a lookup table to a single image
If you want to analyze a batch of chips that all have the same film thickness, it is not necessary to generate a new lookup table for each. Instead, you may use the lookup table from the first image to measure the rest. To measure a single image with a previously generated lookup table, run the script `useLUTsingle`. You will be asked for the data and mirror files, as before, but also the results file that contains the lookup table you wish to use. The output that will be saved contains not only the height measurements from this image but also the lookup table that was used, and the name of the original results file from which it was copied.

### Applying a lookup table to a series of images
This feature is not included in this release. The next update will include it however, so stay tuned.

Last updated 25 August 2015 by [Derin Sevenler](mailto:derin@bu.edu)