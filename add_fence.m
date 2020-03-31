function [J, P_n] = add_fence(img, theta, scale, color_num, noise, real)
% ************************************
% theta�i�t�F���X�p�x�j = 0, 15, 30, 45
% scale(�t�F���X�����j = 1, 1.4
% color_num�i�t�F���X�F�j 5���
% fence_size�i�t�F���X�͈́j = 320�ŌŒ�
% ************************************

if nargin <1
    img = im2single(imread('dataset/evaluation/color/lena.png'));
    theta = 10;
    scale = 1.5;
    color_num = 5;
    noise = false;
    real = true;
end

fence_mask = zeros(size(img));


if real
    
    flist = dir('matsui_dataset/train/label/*.png');
    fence = im2single(imread(['matsui_dataset/train/label/' flist(randi(numel(flist))).name]));
else
    fence = im2single(imread('dataset/fence2.png'));
    
end
fence = padarray(fence, [size(fence,1)/8, size(fence,1)/8], 'symmetric');



fence = imrotate(fence, theta, 'bilinear');
fence = imresize(fence, scale, 'bilinear');

color = [84, 94, 109; % �Â��O���[
            200, 200, 210; % ���邢�O���[
            60, 100, 60; % �[��
            120, 185, 160; % ���邢��
            110, 85, 100; % ���F
            255, 255, 255]/255;


P = fence(max(0, floor( (size(fence, 1) - size(img, 1)) / 2 )) + (1 : size(img, 1)), ...
          max(0, floor( (size(fence, 2) - size(img, 2)) / 2 )) + (1 : size(img, 2)),...
          1);

P = min(P * 1.5, 1);
%P = P > 0.2;

for i = 1:3

    fence_mask(:, :, i) = color(color_num, i);
end

P = repmat(single(P), 1, 1, 3);

if noise
    J = imnoise(fence_mask .* P, 'gaussian', 0, 0.001).*P ...
            + img .* (1-P); % �A���t�@����
else
    J = fence_mask .* P + img .* (1 - P);
end
%J = 1-(1 - img).*(1-fence_mask); % �u�����h����
%J = img + fence_mask; % ���Z����

P_n = single(P > 0.2);
if nargin <1
    figure(100); imshow([J, P_n]);
end
end