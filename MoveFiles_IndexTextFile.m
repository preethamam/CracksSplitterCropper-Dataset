clc; close all; clear;

textfilename = 'index_cleaned.txt';
textfilefolder = 'K:\Project MegaCRACK-RoboCRACK\Real World Data\External Dataset\Xincong Yang Automatic Pixel-Level\image indices\valid';


folder2copy_move_imagesfrom = 'K:\Project MegaCRACK-RoboCRACK\Real World Data\External Dataset\Xincong Yang Automatic Pixel-Level\images\annotation';
copy_move2_imagesFolder = 'D:\OneDrive\Team Work\Team RoboCRACK\Program\11-07-2017\data\Testing\Dataset VI (Xincong)\Testing Cracks_Groundtruth';


%%
% Load txt file
textfileName = fullfile(textfilefolder, textfilename);
T = readtable(textfileName, 'ReadVariableNames', false);
filenames = table2array(T);
filenames = filenames(:,2);

%% 
for i = 1:length(filenames)
    i
    copyfile(fullfile(folder2copy_move_imagesfrom,filenames{i}), copy_move2_imagesFolder)
clc;
end

