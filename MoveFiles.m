clc; close all; clear;
folder2readimages = 'K:\Project MegaCRACK-RoboCRACK\Real World Data\Original Set 02 - Concrete\Aayushi-Young Labeled\Aayushi Crack Images';
folder2deleteimages = 'K:\Project MegaCRACK-RoboCRACK\Real World Data\Original Set 02 - Concrete\Original Crack - Milind Unlabeled';
folder2copy_move_imagesfrom = 'K:\Project MegaCRACK-RoboCRACK\Real World Data\Original Set 02 - Concrete\Aayushi-Young Labeled\Aayushi Crack Images';
moveimagesFolder = 'D:\OneDrive\Team Work\Team RoboCRACK\Program\11-07-2017\data\Testing\Dataset II\Painted_thin';
move2folder = 'C:\Users\Preetham Manjunatha\Downloads';

filename = dir(folder2readimages);
filename = {filename(3:end).name};
[filepath_1,name_1,ext_1] = cellfun(@fileparts,filename, 'UniformOutput',false);

filename2del = dir(folder2deleteimages);
filename2del = {filename2del(3:end).name};
[filepath_2,name_2,ext_2] = cellfun(@fileparts, filename2del, 'UniformOutput',false);

files2delete = setdiff(name_2,name_1,'stable');


% [shuffledData,idx] = datasample(filename,100, 'Replace', false);

shuffledData = filename;
% shuffledData = files2delete;

%%
for i = 1:length(shuffledData)
    i
%     movefile(fullfile(folder2copy_move_imagesfrom,shuffledData{i}), fullfile(move2folder,shuffledData{i}))
%     copyfile(fullfile(folder2copy_move_imagesfrom,[shuffledData{i} '.JPG']), fullfile(move2folder, [shuffledData{i} '.JPG']), 'f')
%     copyfile(fullfile(folder2copyimagesfrom,shuffledData{i}), fullfile(move2folder,shuffledData{i}))
    delete(fullfile(folder2deleteimages,shuffledData{i}))

clc;
end
