
function out = whiteBalance(in, method)
% WHITEBALANCE - white balance an image using gray world or normalization
% out = whiteBalance(in, method)

%% -------------------------------------------------------------------------
% Matlab code and data to reproduce results from the paper                  
% "Joint Demosaicing and Super-Resolution Imaging from a Set of             
% Unregistered Aliased Images"                                              
% Patrick Vandewalle, Karim Krichane, David Alleysson and Sabine S?sstrunk  
% available at http://lcavwww.epfl.ch/reproducible_research/VandewalleKAS07/
%                                                                           
% Copyright (C) 2007 Laboratory of Audiovisual Communications (LCAV),       
% Ecole Polytechnique Federale de Lausanne (EPFL),                          
% CH-1015 Lausanne, Switzerland.                                            
%                                                                           
% This program is free software; you can redistribute it and/or modify it   
% under the terms of the GNU General Public License as published by the     
% Free Software Foundation; either version 2 of the License, or (at your    
% option) any later version. This software is distributed in the hope that  
% it will be useful, but without any warranty; without even the implied     
% warranty of merchantability or fitness for a particular purpose.          
% See the GNU General Public License for more details                       
% (enclosed in the file GPL).                                               
%                                                                           
% Latest modifications: June 7, 2007.                                       
    
    in = im2double(in);

    if nargin == 1
        method = 'gray';
    end
    
    switch(method)
        case 'norm' % Channel normalization
            out(:,:,1) = in(:,:,1) * (1/max(max(in(10:end-10,10:end-10,1))));
            out(:,:,2) = in(:,:,2) * (1/max(max(in(10:end-10,10:end-10,2))));
            out(:,:,3) = in(:,:,3) * (1/max(max(in(10:end-10,10:end-10,3))));
        case 'gray' % Gray world
            mG = mean(mean(in(10:end-10,10:end-10,2)));
            mR = mean(mean(in(10:end-10,10:end-10,1)));
            mB = mean(mean(in(10:end-10,10:end-10,3)));
            out(:,:,1) = in(:,:,1) * (mG/mR);
            out(:,:,3) = in(:,:,3) * (mG/mB);
            out(:,:,2) = in(:,:,2);
            out = out / max(max(max(out(10:end-10,10:end-10, :))));
        otherwise
            error('unknown method')
    end
    out = im2uint8(out);

end

