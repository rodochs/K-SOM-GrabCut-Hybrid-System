function g = eqRayleigh(f, a)
    F = (imhist(f)/sum(imhist(f)));
    for i = 2:numel(F), F(i,1) = F(i,1)+F((i-1),1); end;
    
    F(256) = F(255); %comando para evitar F(256)==1.
    
    for i=1:256, F(i) = sqrt(2*a^2*log(1/(1-F(i)))); end;
    
    F = ceil(F*255);
    
    g = f;
    for i = 1:256
        t = find(f==(i-1));
        vazio = isempty(t);
        if ~vazio
            g(t) = F(i);
        end
    end
    
    subplot(2,2,1), imshow(f);
    title('Original');
    subplot(2,2,2), imshow(g);
    title('Rayleigh');
    subplot(2,2,3), imhist(f);
    subplot(2,2,4), imhist(g);
    title(['Alfa = ', num2str(a)]);
    
    