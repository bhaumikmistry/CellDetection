
%% Info.
% Created my Bhaumik Mistry Sunday, September 18, 2016 10:00 am,
% The data is read in a for loop for frame by frame processing
% functions like imdilate, imerode, bwlabel, bwperim

% Output
% the detected frames are saved int the file named
% 'detected_data.tif' 



%% Reading the data

fname = 'data.tif';
info = imfinfo(fname);
num_images = numel(info);
for k = 1:num_images
    A = imread(fname, k);
    % imshow(A), title('original image');
    % ... Do something with image A ...
    

if k == 1
%% Thresholding for the first frame

% finding Edge
[~, threshold] = edge(A, 'sobel');
fudgeFactor = .5;
BWs = edge(A,'sobel', threshold * fudgeFactor);
 %figure, imshow(BWs), title('binary gradient mask');

% Dilating 
se90 = strel('line', 3, 90);
se0 = strel('line', 4, 0);
BWsdil = imdilate(BWs, [se90 se0]);
 %figure, imshow(BWsdil), title('dilated gradient mask');

% Filling the Holes 
BWdfill = imfill(BWsdil, 'holes');
 %figure, imshow(BWdfill);
 %title('binary image with filled holes');

seD = strel('diamond',2);
BWfinal = imerode(BWdfill,seD);
BWfinal = imerode(BWfinal,seD);
% figure, imshow(BWfinal), title('segmented image');

% BWnobord = imclearborder(BWdfill, 4);
% figure, imshow(BWnobord), title('cleared border image');




%% To get the biggest blob
    
% Get all the blob properties. 
[labeledImage, numberOfBlobs] = bwlabel(BWfinal);
blobMeasurements = regionprops(labeledImage, 'area');

% Get all the areas
allAreas = [blobMeasurements.Area];

% Sort them.
[sortedAreas, sortIndexes] = sort(allAreas, 'descend');

% Extract the "numberToExtract" largest blob(a)s using ismember().
biggestBlob = ismember(labeledImage, sortIndexes(1));
	
% Convert from integer labeled image into binary (logical) image.
binaryImage = biggestBlob > 0;
    
% figure;imshow(binaryImage);title('without background');

%% image masking to remove just the maze out of all the frames.

%background=imresize(background,[size(object,1) size(object,2)]);
%Im3=uint8(zeros(size(object)));
%whiteImg=uint8(ones(size(A)));
%Array right division. A./B is the matrix with elements A(i,j)/B(i,j). A and B must
%have the same size, unless one of them is a scalar.
%Image Division

% Invertion Binary image
bi= (~(binaryImage));
bi =  255*uint8(bi);

% mask=whiteImg./bi;
%Logical AND
A= im2uint8(A);
im3=uint8(bi+A);%uint8(and(mask,background));
% figure,imshow(im3);title('Masking');
% figure,imshow(im3);title('Masking');

else
%% masking all the frames

    A= im2uint8(A);
    im3=uint8(bi+A);
    %uint8(and(mask,background));
    %imshow(im3);title('Masking');
    
% Storing the masked frame in im_data
    im_data(:,:,k) = im3;
    
    
end

end

%% Detecting the cell movement

for i = 2:num_images
    
    % Storing the difference of consecutive images
    x = imabsdiff(im_data(:,:,i-1),im_data(:,:,i));
    
    % Dilate the different to enhance
    se90 = strel('line', 7, 90);
    se0 = strel('line', 7, 0);
    x = imdilate(x, [se90 se0]);
    
    % Enhance the image to binary
    xt = x;
    xt(x<40) = 255; 
    xt(x>41) = 0;    

    % Edit the boundary outline
    BWoutline = bwperim(xt);
    BWoutline = imdilate(BWoutline, true(1));
    A = imread(fname, i);
    A= im2uint8(A);
    
    % To get Yellow boundary or any color
    SegoutR = A;
    SegoutG = A;
    SegoutB = A;
    % now set yellow, [255 255 0]
    % chage color witht he following three lines.
    SegoutR(BWoutline) = 255;
    SegoutG(BWoutline) = 255;
    SegoutB(BWoutline) = 0;
    SegoutRGB = cat(3, SegoutR, SegoutG, SegoutB);
    
    % display the final image.
    SegoutRGB = imresize(SegoutRGB, 2);
    imshow(SegoutRGB), title('outlined original image');
    
    % Data is stored to a file name detected_data.tif storing
    im_diff(:,:,i)= (xt);
    Segoutgray(:,:,i) = rgb2gray(SegoutRGB);
    outputFileName = 'detected_data.tif'
    imwrite(Segoutgray(:, :, i), outputFileName, 'WriteMode', 'append');


    
end



