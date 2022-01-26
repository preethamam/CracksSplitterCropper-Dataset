function cracksSplitter(tileHeight, tileWidth, overlapRatio, ...
                        difference_limit, color_image, gt_binary, thin_binary_image, writeImage, ...
                        crack_image_folder, crack_image_GTfolder, imagename) 
%//%************************************************************************%
%//%*                         Crack Splitter						       *%
%//%*           Splits the cracks with/without overlap region              *%
%//%*           Increases the crack dataset by spliiting the cracks        *%
%//%*                                                                      *%
%//%*             Name: Preetham Manjunatha    		                       *%
%//%*             Github link: https://github.com/preethamam               %*
%//%*             Submission Date: 01/26/2022                              *%
%//%************************************************************************%
%//%*             Viterbi School of Engineering,                           *%
%//%*             Sonny Astani Dept. of Civil Engineering,                 *%
%//%*             University of Southern california,                       *%
%//%*             Los Angeles, California.                                 *%
%//%************************************************************************%
%
%***************************************************************************%
%
% Usage: metrics  = multiclass_metrics_common(confmat)
% Inputs:   tileHeight           - Split tile height (pixels)
%           tileWidth            - Split tile width (pixels)
%           overlapRatio         - Overlap ratio between two adjacent tiles
%                                 (0.0-1.0)
%           difference_limit     - Difference between adjacent tile 
%                                 (integer - usually kept 5 pixels)
%           thin_binary_image         - binary image (original)
%           writeImage           - Save/write split/cropped images as .png
%                                 (1 or 0 - on/off)
%           crack_image_folder   - Save folder split original images
%           crack_image_GTfolder - Save folder split ground-truth images
%           imagename            - image file name
% 
% Outputs: Saved images / Bounding boxes image
%
% Authors: Preetham Manjunatha, Ph.D.
%          Mohsin Sheikh
%

% Get image sizes    
[image_rows, image_cols] = size(thin_binary_image);

% Obtain crack strands 
strand_collection = branchPointDetection(thin_binary_image);

% Save image counter 
image_counter = 1;

% Display figure
figure; imshow(color_image)
hold on;
for i = 1:length(strand_collection) 
    current_strand = strand_collection{i};
    start_point = current_strand.points(1,:);
    create_bounding_box(color_image, gt_binary, thin_binary_image, start_point, image_rows, image_cols, writeImage, image_counter, ...
                        tileWidth, tileHeight, crack_image_folder, crack_image_GTfolder, imagename)
    end_point = current_strand.points(end,:);
    
    for point = 1:length(current_strand.points)
        if( current_strand.points(point,:) == end_point)
            special_box_end_point(color_image, gt_binary, thin_binary_image, start_point,current_strand.points(point,:), image_rows, ...
                image_cols, writeImage, image_counter, tileWidth, tileHeight, crack_image_folder,...
                crack_image_GTfolder, imagename)
            break
        end
        l = abs(current_strand.points(point,2) - start_point(2));
        w = abs(current_strand.points(point,1) - start_point(1));
        if(overlapRatio ~= 0 && (((tileWidth-l)==0) || ((tileHeight-w)==0)))
            disp("point does not exist");
            break
        end
        if((((tileWidth-l)*(tileHeight-w))-tileHeight*tileWidth*overlapRatio)<=difference_limit)
            create_bounding_box(color_image, gt_binary, thin_binary_image, current_strand.points(point,:), image_rows, image_cols , ...
                writeImage, image_counter, tileWidth, tileHeight, crack_image_folder, crack_image_GTfolder, imagename)
            start_point = current_strand.points(point,:);
            image_counter = image_counter + 1;
        end
    end
end
end

%--------------------------------------------------------------------------------------------------
% Auxillary functions
%--------------------------------------------------------------------------------------------------
% Exceeds image boundary limit
function special_box_end_point(color_image, gt_binary, thin_binary_image, start_point, point, image_rows, image_cols, ...
            writeImage, image_counter, tileWidth, tileHeight, crack_image_folder, crack_image_GTfolder, imagename)
    if((abs(start_point(2)-point(2)) < tileWidth/2) && (abs(start_point(1)-point(1)) < tileHeight/2))
        disp("Exceeds image boundary limit!")
        return
    end
    create_bounding_box(color_image, gt_binary, thin_binary_image, point, image_rows, image_cols, writeImage, ...
        image_counter, tileWidth, tileHeight, crack_image_folder, crack_image_GTfolder, imagename)
end

% Bounding box maker
function create_bounding_box(color_image, gt_binary, ~, point, image_rows, image_cols, ...
    writeImage, image_counter, tileWidth, tileHeight, crack_image_folder, crack_image_GTfolder, imagename)
    top_left  = [(point(1)-tileHeight/2) , (point(2)-tileWidth/2)];
    if(top_left(1)<0)
        top_left(1) = 0;
    end
    if( top_left(2) < 0)
         top_left(2) = 0 ;
    end
    if(top_left(1)+tileHeight >= image_rows)
        top_left(1) = image_rows-tileHeight-1;
    end
    if(top_left(2)+tileWidth >= image_cols)
        top_left(2) = image_cols-1-tileWidth;
    end
    
    % Write cropped images
    if writeImage
        % Crop images
        crop_Ioriginal = imcrop(color_image,[top_left(2) top_left(1) tileWidth tileHeight]);
        crop_Ioriginal_GT = imcrop(gt_binary,[top_left(2) top_left(1) tileWidth tileHeight]);

        % Base filename 
        outputBaseFileName_Ioriginal = sprintf('%s_%d.png', imagename, image_counter);
        outputBaseFileName_Iground = sprintf('%s_%d.png', imagename, image_counter);

        % Image write
        imwrite(crop_Ioriginal, fullfile(crack_image_folder,outputBaseFileName_Ioriginal), 'png');
        imwrite(crop_Ioriginal_GT, fullfile(crack_image_GTfolder,outputBaseFileName_Iground), 'png');
        
    end
    rectangle('Position', [top_left(2) top_left(1) tileWidth tileHeight], 'EdgeColor', 'r');        
end
