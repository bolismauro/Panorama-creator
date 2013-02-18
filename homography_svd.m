% Calculate a homography that maps im1 to im2
function T = homography_svd(points1, points2)

% for more details, please see: Lecture 12, page 60, http://www.vision.ee.ethz.ch/~bleibe/multimedia/teaching/cv-ws08/cv08-part12-local-features2.pdf 
% Build matrix
xaxb = points2(:,1) .* points1(:,1);
xayb = points2(:,1) .* points1(:,2);
yaxb = points2(:,2) .* points1(:,1);
yayb = points2(:,2) .* points1(:,2);

A = zeros(size(points1, 1)*2, 9);
A(1:2:end,3) = 1;
A(2:2:end,6) = 1;
A(1:2:end,1:2) = points1;
A(2:2:end,4:5) = points1;
A(1:2:end,7) = -xaxb;
A(1:2:end,8) = -xayb;
A(2:2:end,7) = -yaxb;
A(2:2:end,8) = -yayb;
A(1:2:end,9) = -points2(:,1);
A(2:2:end,9) = -points2(:,2);

% Solve using smallest eigenvector
[U,S,V] = svd(A);
h = V(:,9) ./ V(9,9);
x = reshape(h,3,3);

T = maketform('projective', x);

% The Matlab way:
% (only works with 4 points)
%T = maketform('projective', points2, points1);
