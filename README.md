# Introduction
[![View Cracks splitter/cropper/augment on a large dataset on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/105785-cracks-splitter-cropper-augment-on-a-large-dataset) [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=preethamam/CracksSplitterCropper-Dataset)

Cracks are the precursor of defects. Labeling the cracks is a tedious process. To augment the cracks with similar geometric properties, cracks can be split into tile images. In this program, the thinned cracks are traversed with a certain overlap ratio between the adjacent tiles, each pixel and interpolated points to split into tile images on a large dataset. This will ensure to produce the cracks with similar attributes. Note that some cracks artifacts may show in the tiled images.

# Sample images
| Type | Images |
| --- | --- |
| Original image | ![original](https://user-images.githubusercontent.com/28588878/151207556-9e7886d3-9c62-439e-8e5d-5c3fe6bf48e4.png) |
| Cropped bounding boxes | ![split](https://user-images.githubusercontent.com/28588878/151207592-6825ac5d-1ead-4a36-8242-dcd32629e282.png) |

# Requirements
MATLAB <br />
MATLAB Image Processing Toolbox <br />

# Citation
Crack splitter code for cropping the cracks to the dataset augmentation on large datasets is available to the public. If you use this code in your research, please use the following BibTeX entry to cite:
```bibtex
@PhdThesis{preetham2021vision,
author = {{Aghalaya Manjunatha}, Preetham},
title = {Vision-Based and Data-Driven Analytical and Experimental Studies into Condition Assessment and Change Detection of Evolving Civil, Mechanical and Aerospace Infrastructures},
school =  {University of Southern California},
year = 2021,
type = {Dissertations & Theses},
address = {3550 Trousdale Parkway Los Angeles, CA 90089},
month = {December},
note = {Condition assessment, Crack localization, Crack change detection, Synthetic crack generation, Sewer pipe condition assessment, Mechanical systems defect detection and quantification}
}
```

# Feedback
Please rate and provide feedback for the further improvements.
