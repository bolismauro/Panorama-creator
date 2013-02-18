% File di test per la creazione del panorama
% TODO: Crop automatico al termine dei passaggi (o di ogni passaggio)
clc
clear all
addpath('sift');
addpath('filters');

img_c = imread('images/panorama-bilder-c.jpg');
img_d = imread('images/panorama-bilder-d.jpg');
img_e = imread('images/panorama-bilder-e.jpg');
img_1 = imread('images/panorama-bilder-1.jpg');
img_2 = imread('images/panorama-bilder-2.jpg');
img_3 = imread('images/panorama-bilder-3.jpg');


% testing
img_c = imresize(img_c, 0.3);
img_d = imresize(img_d, 0.3);
img_e = imresize(img_e, 0.3);
img_1 = imresize(img_1, 0.3);
img_2 = imresize(img_2, 0.3);
img_3 = imresize(img_3, 0.3);
% bilanciamento del bianco
img_c = whiteBalance(img_c);
img_d = whiteBalance(img_d);
img_e = whiteBalance(img_e);
img_1 = whiteBalance(img_1);
img_2 = whiteBalance(img_2);
img_3 = whiteBalance(img_3);

% figure(), imshow(img_c);
% figure(), imshow(img_d);
% figure(), imshow(img_e);
% figure(), imshow(img_1);
% figure(), imshow(img_2);

% combino le immagini.
% le immagini vengono combinate assumento che 
% img1_1 sia l'immagine centrale e attaccando via via a destra e 
% a sinistra altre immagini
c = combine(img_1, img_e);
c1 = combine(c, img_2);
c2 = combine(c1, img_d);
c3 = combine(c2, img_3);
c4 = combine(c3, img_c);

unsharpFilter = fspecial('unsharp');
c4 = imfilter(c4, unsharpFilter);
figure(), imshow(c4);
