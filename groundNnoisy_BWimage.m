function  [Iground, Inoisy, Ioriginal] = groundNnoisy_BWimage (Image_g_ID, input, startBin, inputBW_image, colorspace)

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
% Usage: [Iground, Inoisy, Ioriginal] = groundNnoisy_BWimage (Image_g_ID, 
%                                       input, startBin, inputBW_image, colorspace)
% Inputs:   Image_g_ID    - image location/path with filename
%           input         - input struct
%                           input.gpuarray = 'no';                  store in GPU array 'yes' | 'no'
%                           input.resizeImage = 'yes';              'yes' | 'no'
%                           input.resizeImageSize = [480 640];      resize image size
%                           input.maxImageResizePixels = 700;       maximum dimension to check
%                           input.contrast_type = 'image_adjust';   image enhancement (keep default)
%           startBin      - [0,255] for RGB based color segmentation of the
%                           annotated image
%           inputBW_image - Input binary image []
%           colorspace    - color segmentation of annotatations by color space 'rgb' | 'hsv'
%                           (keep 'hsv')
%
% Outputs:  Iground       - Binary ground-truth image
%           Inoisy        - Remaining noise connected components (not needed)
%           Ioriginal     - Original color image

    % Check for colorpsce input and assign default
    if (nargin == 5)
        colorspace = 'hsv';
    end
    
    % Read the ground truth image
    [imheight, imwidth, imbytesppix, Ioriginal, Igray] ...
            = imconversion2gray(Image_g_ID, input); %#ok<*ASGLU>
                            
    % Switch statement for RGB and grayscale image
    switch colorspace
        case 'hsv'
            switch imbytesppix
                case 3
                    % RED | GREEN | BLUE
                    hsvImage        = rgb2hsv(Ioriginal);       % Convert the image to HSV space
                    hPlane          = 360.*hsvImage(:,:,1);     % Get the hue plane scaled from 0 to 360
                    sPlane          = hsvImage(:,:,2);          % Get the saturation plane
                    vPlane          = hsvImage(:,:,3);          % Get the saturation plane

                    nonRedIndex     = (((hPlane >= 20)  & (hPlane <= 340)) | ...  
                                      ((sPlane <= 0.8)  | (vPlane <= 0.8)));        % Select "non-red" pixels

                    nonGreenIndex   = ((hPlane >= 0)    & (hPlane <= 110)) | ...
                                      ((hPlane >= 130)  & (hPlane <= 360)) | ...
                                      ((sPlane <= 0.8)  | (vPlane <= 0.8));         % Select "non-green" pixels

                    nonBlueIndex    = ((hPlane >= 0)    & (hPlane <= 220)) | ...
                                      ((hPlane >= 260)  & (hPlane <= 360)) | ...
                                      ((sPlane <= 0.8)  | (vPlane <= 0.8));         % Select "non-blue" pixels

                    nonRGBIndex     = {nonRedIndex, nonGreenIndex, nonBlueIndex};

                    [val, index] = min([sum(nonRedIndex(:)), sum(nonGreenIndex(:)), ...
                                        sum(nonBlueIndex(:))]);

                    sPlane(nonRGBIndex{index}) = 0;      % Set the selected pixel saturations to 0
                    vPlane(nonRGBIndex{index}) = 0;      % Set the selected pixel values to 0
                    hsvImage(:,:,2) = sPlane;            % Update the saturation plane
                    hsvImage(:,:,3) = vPlane;            % Update the value plane
                    rgbImage = hsv2rgb(hsvImage);        % Convert the image back to RGB space

                    % Convert RGB to binary
                    Iground  = logical(rgbImage(:,:,1) + rgbImage(:,:,2) + ...
                                       rgbImage(:,:,3));
                                   
               case 1
                    % Ground truth image
                    Iground = false(size(Ioriginal,1), size(Ioriginal,2));
            end

        case 'rgb'
            switch imbytesppix
                case 3
                    % Image histogram for extracting R/G/B only pixels
                    Rcount = imhist(Ioriginal(:,:,1));
                    Gcount = imhist(Ioriginal(:,:,2));
                    Bcount = imhist(Ioriginal(:,:,3));

                    % Find maximum channel
                    RGBsum = [sum(Rcount(startBin : end)), sum(Gcount(startBin : end)),...
                                 sum(Bcount(startBin : end))];
                    [RGBsumcount, RGBsumIdx] = max(RGBsum);

                    % Extract the indices that have R or G or B channel only
                    switch RGBsumIdx
                        case 1
                            [rows, cols, page] = ind2sub(size(Ioriginal), ....
                                find(Ioriginal(:,:,1) > startBin & ...
                                Ioriginal(:,:,2) < 0.15 * startBin & ...
                                Ioriginal(:,:,3) < 0.15 * startBin)); %#ok<*NASGU>
                        case 2
                            [rows, cols, page] = ind2sub(size(Ioriginal), ....
                                find(Ioriginal(:,:,2) > startBin & ...
                                Ioriginal(:,:,1) < 0.15 * startBin & ...
                                Ioriginal(:,:,3) < 0.15 * startBin));
                        case 3
                            [rows, cols, page] = ind2sub(size(Ioriginal), ....
                                find(Ioriginal(:,:,3) > startBin & ...
                                Ioriginal(:,:,1) < 0.15 * startBin & ...
                                Ioriginal(:,:,2) < 0.15 * startBin));
                    end

                    % Ground truth image
                    Iground = zeros(size(Ioriginal,1), size(Ioriginal,2));
                    for ii = 1:length(rows)
                       Iground(rows(ii),cols(ii)) = 1; 
                    end

                    % Final ground truth image after low-level filtering.
                    % True signal (crack objects)
                    Iground = filter_stage_I (Iground);
                    
                case 1
                    % Ground truth image
                    Iground = false(size(Ioriginal,1), size(Ioriginal,2));
            end
    end
    
    % Noisy objects
    Inoisy = []; %imsubtract(inputBW_image, logical(Iground));  

end