function combined_img = combine(imageFixed, imageToRotate)
% combina due immagini. Si assume che la prima immagine passata resti ferma
% mentre la seconda venga ruotata
    
    fprintf('finding sift');
    tic()
    imageFixedBW = rgb2gray(imageToRotate);
    imageToRotateBW = rgb2gray(imageFixed);
    % calcolo SIFT, il primo valore tornato contiene coordinate dei punti,
    % orientamento ecc mentre il secondo il descrittore
    [framesImageFixed, descrImageFixed] = sift(imageFixedBW);
    [framesImageToRotate, descrImageToRotate] = sift(imageToRotateBW);
    toc()
    
    fprintf('matching...');
    tic()
    % By passing to integers we greatly enhance the matching speed (we use
    % the scale factor 512 as Lowe's, but it could be greater without
    % overflow)
    % see demo.m
    descrImageFixed = uint8(512*descrImageFixed) ;
    descrImageToRotate = uint8(512*descrImageToRotate) ;
    % funzione matlab, molto lenta -> matchidxs = %matchFeatures(descrips_left',descrips_right');
    % trovo indici che mi indicano i punti in comune
    % il match viene effettuato secondo il suggerimento di Lowe
    % (Calcolo tutte le distanze, prendo e controllo che rapporto sia <
    % 0.8)
    matchidxs = siftmatch(descrImageFixed, descrImageToRotate);
    toc()
    
    % estraggo punti dai frames
    IntrestingPointsImageFixed = framesImageFixed(1:2, :)';
    IntrestingPointsImageToRotate = framesImageToRotate(1:2, :)';
 
    % estraggo solo quelli che matchano
    IntrestingPointsImageFixed = IntrestingPointsImageFixed(matchidxs(1,:), :);
    IntrestingPointsImageToRotate = IntrestingPointsImageToRotate(matchidxs(2,:), :);
    
    fprintf('ransac');
    tic()
    % Utilizzo RANSAC per determinate l'omografia che meglio approssima la
    % trasformazione reale tra i punti.
    % 8 è il numero di punti che vengono selezionati (random) per stimare
    % la trasformazione ad ogni iterazione
    [transformation, ~ ] = ransac( IntrestingPointsImageFixed, IntrestingPointsImageToRotate, 8 );
    toc()
    
    
    % creo due maschere delle immagini
    maskImageFixed = ones(size(imageFixed));
    maskImageToRotate = ones(size(imageToRotate));
    
    % applico la trasformazione trovata da RANSAC sulla maschera.
    % In questo modo posso estrarre i dati da XData e YData per stabilire
    % la dimensione del canvas da utilizzare
    [maskRotated, XDataRotated, YDataRotated] = imtransform(maskImageToRotate, transformation, 'XYScale', 1);
    
    % calcolo la dimensione del canvas
    [imageFixedRows, imageFixedCols, ~] = size(imageFixed);
    XDataFixed = [1 imageFixedCols];
    YDataFixed = [1 imageFixedRows];
    
    XData = [min(XDataRotated(1), XDataFixed(1)) max(XDataRotated(2), XDataFixed(2))];
    YData = [min(YDataRotated(1), YDataRotated(1)) max(YDataRotated(2), YDataFixed(2))];
    
    % trasformazione identità, utilizzata sull'immagine "ferma" con il
    % semplice scopo di ingrandire il canvas ottenuto
    idTransform = maketform('affine', eye(3));
    
    % applico le trasformazioni alle immagini
    imageRotated = imtransform(imageToRotate, transformation, 'XYScale', 1, 'XData', XData, 'YData', YData);
    imageFixedExtended = imtransform(imageFixed, idTransform, 'XYScale', 1, 'XData', XData, 'YData', YData);
    
    imageRotated = im2double(imageRotated);
    imageFixedExtended = im2double(imageFixedExtended);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MEDIA - Prova miglioramento blending  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %calcolo statistiche colore e tento di variare le immagini per
    %migliorare la transizione durante il blending
    
%    maskRotated = imtransform(maskImageToRotate, transformation, 'XYScale', 1, 'XData', XData, 'YData', YData);
%    maskFixed = imtransform(maskImageFixed, idTransform, 'XYScale', 1, 'XData', XData, 'YData', YData);

%     maskRotated = im2uint8(maskRotated);
%     maskFixed = im2uint8(maskFixed);
%     maskRotated( maskRotated > 0) = 10;
%     maskFixed( maskFixed > 0) = 10;
%     
%     combinedMask = imadd(maskRotated, maskFixed);    
%     combinedMask = combinedMask(:,:,1);
%     
%     intersectionPoints = find( combinedMask == 20 );
%     
%     for i=1:3     
%         levelFixed = imageFixedExtended(:,:,i);
%         levelRotated = imageRotated(:,:,i);   
%     
%         levelFixed = levelFixed(intersectionPoints);
%         levelRotated = levelRotated(intersectionPoints);
%         k = sum(sum(levelFixed)) / sum(sum(levelRotated));
%         imageRotated(:,:,i) = imageRotated(:,:,i) .* k;              
%     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % END MEDIA - Prova miglioramento blending  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % effettuo il blending    
    fprintf('blending');
    tic()
    % la maschera generata da blendColor è fissa,
    % devo capire quale img è a sinistra e a destra
    % per cambiare l'ordine dei parametri
    if XDataRotated(1) < 0 % l'img ruotata e' a sinistra
        combined_img = blendColor(imageRotated, imageFixedExtended, 20);
    else
        combined_img = blendColor(imageFixedExtended, imageRotated, 20);
    end
    toc()

end