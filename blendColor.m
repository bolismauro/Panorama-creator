function res = blendColor(img1, img2, numOfIterations)
% Blenda due immagini utilizzando la tecnica del blending piramidale.
    
    % genero le due piramidi laplaciane
    cLA = genPyr(img1,'lap',numOfIterations);
    cLB = genPyr(img2,'lap',numOfIterations);
   
    
    % Calcolo la maschera delle due immagini
    mask1 = zeros(size(img1));
    mask2 = zeros(size(img2));
    mask1(find(img1 > 0)) = 1;
    mask2(find(img2 > 0)) = 1;
    % Unisco le due maschere per trovare intersezione
    composed_mask = imadd(mask1, mask2);
    composed_mask = composed_mask(:,:,1);
    %imagesc(composed_mask);
    [Rows Columns Layers] = find(composed_mask == 2);
    c_right = max(Columns);
    c_left = min(Columns);
    c_mean = (c_right+c_left) / 2;
    
    % creo maschera da utilizzare nel blending piramidale
    mask = zeros(size(img1));
    mask(:,1:ceil(c_mean),:) = 1;
    
    %figure(), imshow(mask);
    
    %creo piramide gaussiana della maschera
    cMask = genPyr(mask, 'gauss', numOfIterations);
    
    % blendo i livelli
    LS = cell(1, numOfIterations);

    for p = 1:numOfIterations
        LS{p} = cLA{p}.*cMask{p} + cLB{p}.*(1-cMask{p});
    end

    for p = length(LS)-1:-1:1
        % 64 -> 127, problema divisione per due
        [M, N, noP] = size(LS{p});
        LS{p} = LS{p}+imresize(LS{p+1}, [M N]);
    end  
    
    res = LS{p};
    
    % elimino "sporco" fuori dall'immagine
    composed_mask( composed_mask > 1 ) = 1;
    res(:,:,1) = res(:,:,1) .* composed_mask;
    res(:,:,2) = res(:,:,2) .* composed_mask;
    res(:,:,3) = res(:,:,3) .* composed_mask;
    
end




function [ pyr ] = genPyr( img, type, level )
% Genera una piramide (gaussiana o laplaciana a secondo del parametro "type")
% avente "level" livelli
    pyr = cell(1,level);
    pyr{1} = im2double(img);
    
    for p = 2:level
        pyr{p} = impyramid(pyr{p-1}, 'reduce');
    end
    
    if strcmp(type,'gauss'), return; end

    for p = 1:level-1
        [M, N, noP] = size(pyr{p});
        actual = pyr{p};
        next = imresize(pyr{p+1}, [M N]);
        diff = zeros(M,N,3);
        for i=1:3
            diff(:,:,i) = actual(:,:,i) - next(:,:,i);
        end
        pyr{p} = diff;
    end

end