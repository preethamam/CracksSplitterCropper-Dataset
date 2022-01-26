function [oriheight, oriwidth, bytesppix, f_orig, IMconverted] ...
                        = imconversion2gray (ImageID, input)

%//%************************************************************************%
%//%*                         Crack Splitter						       *%
%//%*           Splits the cracks with/without overlap region              *%
%//%*           Increases the crack dataset by spliiting the cracks        *%
%//%*                                                                      *%
%//%*             Name: Preetham Manjunatha    		                       *%
%//%*             Github link: https://github.com/preethamam               %*
%//%*             Submission Date: --/--/2018                              *%
%//%************************************************************************%
%//%*             Viterbi School of Engineering,                           *%
%//%*             Sonny Astani Dept. of Civil Engineering,                 *%
%//%*             University of Southern california,                       *%
%//%*             Los Angeles, California.                                 *%
%//%************************************************************************%
%
%************************************************************************%
%
% Usage: metrics  = multiclass_metrics_common(confmat)
% Inputs:   Image_g_ID    - image location/path with filename
%           input         - input struct
%                           input.gpuarray = 'no';                  store in GPU array 'yes' | 'no'
%                           input.resizeImage = 'yes';              'yes' | 'no'
%                           input.resizeImageSize = [480 640];      resize image size
%                           input.maxImageResizePixels = 700;       maximum dimension to check
%                           input.contrast_type = 'image_adjust';   image enhancement (keep default)
% 
%
% Outputs:  oriheight     - Image height (rows)
%           oriwidth      - Image height (columns)
%           bytesppix     - Image channels
%           f_orig        - Original image
%           IMconverted   - Converted image

    % Load image file
    if (strcmp(input.gpuarray, 'yes'))
        f_orig = gpuArray(imread(ImageID));
    else
        f_orig = imread(ImageID);
    end
        
    [oriheight, oriwidth, bytesppix] = size (f_orig);

    if(strcmp(input.resizeImage,'yes') && (max(oriheight, oriwidth) > input.maxImageResizePixels))
        f_orig = imresize(f_orig,input.resizeImageSize);
        [oriheight, oriwidth, bytesppix] = size (f_orig);  
    end
        
    % Check for grayscale or color
    switch bytesppix
        case 1
            IMconverted = double(f_orig);      
        case 3

           % Color 2 grayscale
           if (strcmp(input.contrast_type ,'adaphist'))
               IMconverted = double(adapthisteq(rgb2gray(f_orig)));    
           elseif (strcmp(input.contrast_type ,'image_adjust'))
               IMconverted = double(imadjust(rgb2gray(f_orig)));
           elseif (strcmp(input.contrast_type ,'hist_equi'))
               IMconverted = double(histeq(rgb2gray(f_orig)));
           else
               IMconverted = double(rgb2gray(f_orig));
           end    

        otherwise
            error (['Invalid image type. Please check your image channel' ...
                    '(maximum bytes per pixel.']);
    end
end
