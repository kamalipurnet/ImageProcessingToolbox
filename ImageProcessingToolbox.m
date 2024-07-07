function image_processing_app
    % Create the main UI figure
    fig = uifigure('Position', [100 100 1000 600], 'Name', 'Image Processing App');

    % Create axes for displaying the image
    ax = uiaxes(fig, 'Position', [50 150 900 400]);

    % Initialize image data
    img = [];
    original_img = [];
    img_type = 'RGB'; % Add a variable to track the image type
    contrast_factor = 1; % Variable to track the contrast adjustment factor

    % Create buttons and other UI controls
    uibutton(fig, 'Position', [50 50 100 30], 'Text', 'Open Image', 'ButtonPushedFcn', @(btn, event) openImage());
    uibutton(fig, 'Position', [160 50 100 30], 'Text', 'Grayscale', 'ButtonPushedFcn', @(btn, event) convertToGrayscale());
    uibutton(fig, 'Position', [270 50 100 30], 'Text', 'Blur', 'ButtonPushedFcn', @(btn, event) blurImage());
    uibutton(fig, 'Position', [380 50 100 30], 'Text', 'Sharpen', 'ButtonPushedFcn', @(btn, event) sharpenImage());
    uibutton(fig, 'Position', [490 50 100 30], 'Text', 'Increase Contrast', 'ButtonPushedFcn', @(btn, event) increaseContrast());
    edButton = uidropdown(fig, 'Position', [600 50 100 30], 'Items', {'Edge Detection', 'Sobel', 'Canny'}, 'ValueChangedFcn', @(dd, event) edgeDetection(dd.Value));
    fdButton = uidropdown(fig, 'Position', [710 50 100 30], 'Items', {'Feature Detection', 'Harris', 'SIFT'}, 'ValueChangedFcn', @(dd, event) featureDetection(dd.Value));
    uibutton(fig, 'Position', [820 50 100 30], 'Text', 'Rotate 90', 'ButtonPushedFcn', @(btn, event) rotateImage());
    uibutton(fig, 'Position', [50 90 100 30], 'Text', 'Mirror', 'ButtonPushedFcn', @(btn, event) invertImage());
    uibutton(fig, 'Position', [160 90 100 30], 'Text', 'Reset', 'ButtonPushedFcn', @(btn, event) resetImage());
    uibutton(fig, 'Position', [270 90 100 30], 'Text', 'Save Image', 'ButtonPushedFcn', @(btn, event) saveImage());

    % Define the callback functions for each button
    function openImage()
        [filename, pathname] = uigetfile({'*.jpg;*.png', 'Image Files'}, 'Select an Image');
        if isequal(filename, 0)
            return;
        end
        img = imread(fullfile(pathname, filename));
        original_img = img;
        img_type = 'RGB'; % Update the image type
        contrast_factor = 1; % Reset the contrast factor
        imshow(img, 'Parent', ax);
        
        % Reset dropdowns to default values
        edButton.Value = 'Edge Detection';
        fdButton.Value = 'Feature Detection';
    end

    function convertToGrayscale()
        if isempty(img)
            return;
        end
        if size(img, 3) == 3  % Check if the image is RGB
            img = rgb2gray(img);
            img_type = 'Grayscale'; % Update the image type
        end
        imshow(img, 'Parent', ax);
        
        % Reset dropdowns to default values
        edButton.Value = 'Edge Detection';
        fdButton.Value = 'Feature Detection';
    end

    function blurImage()
        if isempty(img)
            return;
        end
        img = imgaussfilt(img, 2);
        imshow(img, 'Parent', ax);
        
        % Reset dropdowns to default values
        edButton.Value = 'Edge Detection';
        fdButton.Value = 'Feature Detection';
    end

    function sharpenImage()
        if isempty(img)
            return;
        end
        img = imsharpen(img);
        imshow(img, 'Parent', ax);
        
        % Reset dropdowns to default values
        edButton.Value = 'Edge Detection';
        fdButton.Value = 'Feature Detection';
    end

    function increaseContrast()
        if isempty(img)
            return;
        end
        contrast_factor = contrast_factor * 1.1; % Increase the contrast factor
        if size(img, 3) == 3
            % Apply imadjust to each channel separately for RGB images
            img = cat(3, imadjust(img(:,:,1), [], [], contrast_factor), ...
                         imadjust(img(:,:,2), [], [], contrast_factor), ...
                         imadjust(img(:,:,3), [], [], contrast_factor));
        else
            img = imadjust(img, [], [], contrast_factor);
        end
        imshow(img, 'Parent', ax);
        
        % Reset dropdowns to default values
        edButton.Value = 'Edge Detection';
        fdButton.Value = 'Feature Detection';
    end

    function edgeDetection(method)
        if isempty(img) || strcmp(method, 'Edge Detection')
            return;
        end
        gray_img = img;
        if strcmp(img_type, 'RGB')
            gray_img = rgb2gray(img); % Convert to grayscale if image is RGB
        end
        if strcmp(method, 'Sobel')
            img_edge = edge(gray_img, 'sobel');
        elseif strcmp(method, 'Canny')
            img_edge = edge(gray_img, 'canny');
        end
        imshow(img_edge, 'Parent', ax);
        
        % Reset the feature detection dropdown to default
        fdButton.Value = 'Feature Detection';
    end

    function featureDetection(method)
        if isempty(img) || strcmp(method, 'Feature Detection')
            return;
        end
        gray_img = img;
        if strcmp(img_type, 'RGB')
            gray_img = rgb2gray(img); % Convert to grayscale if image is RGB
        end
        if strcmp(method, 'Harris')
            corners = detectHarrisFeatures(gray_img);
            img_with_features = insertMarker(img, corners.Location, 'Color', 'red');
        elseif strcmp(method, 'SIFT')
            img_with_features = detectSIFTFeatures(gray_img);
        end
        imshow(img_with_features, 'Parent', ax);

        % Reset the edge detection dropdown to default
        edButton.Value = 'Edge Detection';
    end

    function img_with_features = detectSIFTFeatures(img)
        % Placeholder for SIFT feature detection code
        % This is a simple example of detecting keypoints
        % You should replace this with a full implementation of SIFT

        % For the sake of demonstration, we will use a simple method
        % This is NOT a complete SIFT implementation

        % Convert the image to single precision
        img = im2single(img);

        % Detect keypoints using a simple method (replace with actual SIFT)
        keypoints = detectSURFFeatures(img);

        % Extract features around keypoints
        [features, valid_keypoints] = extractFeatures(img, keypoints);

        % Show the detected keypoints on the image
        img_with_features = insertMarker(img, valid_keypoints.Location, 'Color', 'red');
    end

    function rotateImage()
        if isempty(img)
            return;
        end
        img = imrotate(img, 90);
        imshow(img, 'Parent', ax);
        
        % Reset dropdowns to default values
        edButton.Value = 'Edge Detection';
        fdButton.Value = 'Feature Detection';
    end

    function invertImage()
        if isempty(img)
            return;
        end
        img = flip(img, 2);  % Invert the image horizontally
        imshow(img, 'Parent', ax);
        
        % Reset dropdowns to default values
        edButton.Value = 'Edge Detection';
        fdButton.Value = 'Feature Detection';
    end

    function resetImage()
        if isempty(original_img)
            return;
        end
        img = original_img;
        img_type = 'RGB'; % Reset the image type
        contrast_factor = 1; % Reset the contrast factor
        imshow(img, 'Parent', ax);
        
        % Reset the dropdowns to default values
        edButton.Value = 'Edge Detection';
        fdButton.Value = 'Feature Detection';
    end

    function saveImage()
        if isempty(img)
            return;
        end
        [filename, pathname] = uiputfile({'*.jpg;*.png', 'Image Files'}, 'Save Image As');
        if isequal(filename, 0)
            return;
        end
        imwrite(img, fullfile(pathname, filename));
        
        % Reset dropdowns to default values
        edButton.Value = 'Edge Detection';
        fdButton.Value = 'Feature Detection';
    end
end
