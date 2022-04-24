function g = eqLoghiperbolica(f, mi, ma)
    F = (imhist(f)/sum(imhist(f)));
    for i = 2:numel(F), F(i,1) = F(i,1)+F((i-1),1); end;
    
    F = floor(mi*(ma/mi)*F);
    
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
    title('Logaritmo-hiperbólica');
    subplot(2,2,3), imhist(f);
    subplot(2,2,4), imhist(g);
    title(['min = ', num2str(mi), '   max = ', num2str(ma)]);