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
tileHeight = 50;  % tile height
tileWidth = 100;  % tile width
overlapRatio = 0.2; % overlap bewteen adjacent tiles
difference_limit = 5; % Pixel difference
writeImage = 1;  % write/save spilt images

%--------------------------------------------------------------------------
% Dataset files I/O 
%--------------------------------------------------------------------------
dataFolderPath = pwd;

crack_folders    = {'CrackGroundTruth', 'CrackOriginals'}; % crack folders

% Patches images save folder
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
 
% Loop on all the available files to
% Waitbar handler (dynamic for video files)
h = waitbar(0,'1','Name', 'Creating Patch Image Files',...
        'CreateCancelBtn',...
        'setappdata(gcbf,''canceling'',1)');
setappdata(h,'canceling',0)

%% Load images
% Read image
for i = 1:length(fileDetailsArray)
    
    % initiate progress bar
    % Check for Cancel button press
    if getappdata(h,'canceling')
        break
    end
    
    % Image conversion
    ImageID = fullfile(fileDetailsArray(i).folder, fileDetailsArray(i).name);
    ImageID_original = fullfile(dataFolderPath, crack_folders{2}, fileDetailsArray(i).name);
    
    % Obtain the grountruth image
    [Iground, Inoisy, Ioriginal_GT] = groundNnoisy_BWimage(ImageID, imconv_input, 235, [], 'hsv');
    
    % Obtain the original image patch
    [~, ~, Ioriginal] = groundNnoisy_BWimage(ImageID_original, imconv_input, 235, [], 'hsv');

    %% Image smoothing and thining
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

    % Split cracks and save
    % Extract the file path, name and extension
    [pathstr,imagename,ext] = fileparts(fileDetailsArray(i).name);

    cracksSplitter(tileHeight, tileWidth, overlapRatio, difference_limit, ...
        Ioriginal, Iground, BW_thin, writeImage, crack_image_folder, crack_image_GTfolder,...
        imagename)
end

%% End
%--------------------------------------------------------------------------
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);
Runtime = toc(Start);
