%//%************************************************************************%
%//%*                         Crack Splitter						       *%
%//%*           Splits the cracks with/without overlap region              *%
%//%*           Increases the crack dataset by spliiting the cracks        *%
%//%*                                                                      *%
%//%*             Name: Preetham Aghalaya Manjunatha    		           *%
%//%*             Github link: https://github.com/preethamam               %*
%//%*             Submission Date: --/--/2018                              *%
%//%************************************************************************%
%//%*             Viterbi School of Engineering,                           *%
%//%*             Sonny Astani Dept. of Civil Engineering,                 *%
%//%*             University of Southern california,                       *%
%//%*             Los Angeles, California.                                 *%
%//%************************************************************************%

clear; close all; clc;
Start = tic;
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);

%% Inputs
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Split Image details 
%--------------------------------------------------------------------------
image_size_rows = 50; 
image_size_cols = 100;

%--------------------------------------------------------------------------
% Dataset files I/O 
%--------------------------------------------------------------------------
dataFolderPath = pwd;

crack_folders    = {'CrackGroundTruth', 'CrackOriginals'}; % crack folders

% Images patches save folder
crack_image_folder = 'Cropped_Crack_Images';
crack_image_GTfolder = 'Cropped_Groundtruth_Crack_Images';

%--------------------------------------------------------------------------
% Image enchancement options
%--------------------------------------------------------------------------
boundary_smooth = 1; % 0 - none | 1 - morphClose | 2 - kernel
morphclose_disksize = 35; % Morphological disk size
windowSize = 25; % Kernel size

% Thining method
thinPruneMethod = 'alex';  % conventional | alex | voronoi | fast_marching
thinPruneThresh = 0.1;

% Image conversion input struct
imconv_input.gpuarray = 'no';
imconv_input.resizeImage = 'yes';
imconv_input.resizeImageSize = [480 640];
imconv_input.maxImageResizePixels = 700;
imconv_input.contrast_type = 'image_adjust';

%% File names and location
fileDetails = dir(fullfile(dataFolderPath,crack_folders{1}));
fileDetailsArray = fileDetails(~ismember({fileDetails.name},{'.','..','desktop.ini','thumbs.db'}));

%% Load images
% Loop on all the available files to
% Waitbar handler (dynamic for video files)
h = waitbar(0,'1','Name', 'Creating Patch Image Files',...
        'CreateCancelBtn',...
        'setappdata(gcbf,''canceling'',1)');
setappdata(h,'canceling',0)

% Read image
for i = 1:length(fileDetailsArray)
    
    % Image conversion
    ImageID = fullfile(fileDetailsArray(i).folder, fileDetailsArray(i).name);
    ImageID_original = fullfile(dataFolderPath, crack_folders{2}, fileDetailsArray(i).name);
    
    % Obtain the grountruth image
    [Iground, Inoisy, Ioriginal_GT] = groundNnoisy_BWimage(ImageID, imconv_input, 235, [], 'hsv');
    
    % Obtain the original image patch
    [~, ~, Ioriginal] = groundNnoisy_BWimage(ImageID_original, imconv_input, 235, [], 'hsv');

    % Image smoothing
    switch boundary_smooth 
        case 1
            se = strel('disk', morphclose_disksize);
            Iground_smoothed = imclose(Iground,se);
        case 2
            kernel = ones(windowSize) / windowSize ^ 2;
            blurryImage = conv2(single(Iground), kernel, 'same');
            Iground_smoothed = blurryImage > 0.5; % Rethreshold
        otherwise
            Iground_smoothed = Iground;
    end
    
    
    % Image size
    [rows, columns, ~] = size(Iground_smoothed);

    % Skeleton prune threshold
    skelPruneThresh = floor(max(rows,columns) * thinPruneThresh);

    Ifilled = imfill(Iground_smoothed,'holes');

    % Image branch/end points extraction
    switch thinPruneMethod
        case 'conventional'
            BW_thin = bwmorph(Ifilled,'thin',Inf);
        case 'alex'
            if ismac
                % Code to run on Mac platform
                BW3 = skeleton_mac(Ifilled) > skelPruneThresh;
            elseif isunix
                % Code to run on Linux platform
                BW3 = skeleton_unix(Ifilled) > skelPruneThresh;
            elseif ispc
                % Code to run on Windows platform
                BW3 = skeleton_win(Ifilled) > skelPruneThresh;
            else
                disp('Platform not supported')
            end
            BW_thin = bwmorph(BW3,'thin',Inf);
        case 'voronoi'
            [BW3, v, e] = voronoiSkel(Ifilled,'trim',5,'fast',1.23);
            BW_thin = bwmorph(BW3,'thin',Inf);          
        case 'fast_marching'
            % Crack centerline using the FMM
            S = skeletonFMM(Iground_smoothed);

            % Poplutate the skeleton in binary image
            BW_thin = false(size(Iground_smoothed));
            for j=1:length(S)
                L=S{j};
                x = round(L(:,1));
                y = round(L(:,2));
                for m = 1:numel(x)
                        BW_thin(x(m),y(m)) = 1;
                end
            end
    end
    
    % Extract the file path, name and extension
    [pathstr,imagename,ext] = fileparts(fileDetailsArray(i).name);
    
    % Get the main image size
    [oriheight, oriwidth, bytesppix] = size(Ioriginal_GT);

    % Interpolate and extract centering points using parametric splines
    stats = regionprops(BW_thin, 'PixelList');
    
    for m = 1:length(stats)
        pixel_coords = stats(m).PixelList;
        intermediate_points{m} = interparc(15, pixel_coords(:,1), pixel_coords(:,2),'pchip');
    end
    plot_points = round(vertcat(intermediate_points{:}));
    
    for j = 1 : length(plot_points)
        
        % Check for Cancel button press
        if getappdata(h,'canceling')
            break
        end
    
        % Pixel coordinates
        y = plot_points(j,2);
        x = plot_points(j,1);
        
        % Crop - add a : in order to get 3 or more dimensions at the end
        rows2scan = image_size_rows/2;
        cols2scan = image_size_cols/2;
        
        if (~((y - rows2scan) < 1) && ~((y + rows2scan) > oriheight) && ...
           ~((x - cols2scan) < 1) && ~((x + cols2scan) > oriwidth))

            crop_Ioriginal_GT = Iground(y - rows2scan : y + rows2scan - 1, ...
                                       x - cols2scan : x + cols2scan - 1, :); 
            crop_Ioriginal   = Ioriginal(y - rows2scan : y + rows2scan - 1, ...
                                       x - cols2scan : x + cols2scan - 1, :);
                                   
            % Base filename 
            outputBaseFileName_Ioriginal = sprintf('%s_%d.jpg', imagename, j);
            outputBaseFileName_Iground = sprintf('%s_%d.jpg', imagename, j);

            % Image write
            imwrite(crop_Ioriginal, fullfile(crack_image_folder,outputBaseFileName_Ioriginal), 'jpg');
            imwrite(crop_Ioriginal_GT, fullfile(crack_image_GTfolder,outputBaseFileName_Iground), 'jpg');
        end
        
        % Report current estimate in the waitbar's message field
        waitbar(i/length(fileDetailsArray), h, sprintf('Image: %i/%i | Patch: %i/%i' , i, length(fileDetailsArray), j, length(pixel_coords)))

    end                               
end
delete(h);

%% End
%--------------------------------------------------------------------------
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);
Runtime = toc(Start);
