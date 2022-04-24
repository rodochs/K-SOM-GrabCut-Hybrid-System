% GNU licence:
% Copyright (C) 2012  Itay Blumenthal
% 
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program; if not, write to the Free Software
%     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USAfunction finalLabel = GCAlgo( im, fixedBG,  K, G, maxIterations, Beta, diffThreshold, myHandle )

function varargout = GC_GUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GC_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @GC_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before GC_GUI is made visible.
function GC_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
global CurrRes;
CurrRes = [];
handles.output = hObject;
handles.K_max = 12;
handles.K_min = 2;

handles.Beta_max = 5;
handles.Beta_min = 0.01;

handles.K_value = 6;
handles.Beta_value = 0.3;
set(handles.K_text,'String',num2str(handles.K_value ));
set(handles.Beta_text,'String',num2str(handles.Beta_value ));

imshow([],'Parent',handles.DrawOrigIm);
imshow([],'Parent',handles.DrawPolygon);
imshow([],'Parent',handles.CurrResult);
imshow([],'Parent',handles.PrevResult);

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = GC_GUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% --- Executes on button press in OpenImage.
function OpenImage_Callback(hObject, eventdata, handles)

global FileName;
global im;
global Tmask;

FilterSpec = ['*'];
[FileName,PathName,FilterIndex] = uigetfile(FilterSpec);
fullFileName = strcat(PathName, FileName);
im = imread(fullFileName);
imshow(im,'Parent',handles.DrawOrigIm);

[m, n, p] = size(im);

if p == 1
    im(:,:,2) = im(:,:,1);
    im(:,:,3) = im(:,:,1);
end

Tmask = zeros(m, n);

%set(handles.instruction_1,'String','Escolha o método inicial: Kohonen, Marcar Polígono ou Carregar Polígono');
% hObject    handle to OpenImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MarkPolygon.
function MarkPolygon_Callback(hObject, eventdata, handles)
global fixedBG;
global im;
set(handles.Processbar,'Visible','off');
%set(handles.instruction_1,'String','Botão esquerdo para um novo ponto, direito para fechar. Duplo clique dentro para terminar');
%set(handles.instruction_1,'Visible','on');
%set(handles.instruction_2,'Visible','on');
%set(handles.instruction_3,'Visible','on');

disp('sfgasdfgasdfg');
imshow(im,'Parent',handles.DrawPolygon);

fixedBG = ~roipoly(im);
imshow(fixedBG, 'Parent', handles.DrawPolygon);

%%% show red bounds:
imBounds = im;
bounds = double(abs(edge(fixedBG)));
se = strel('square',3);
bounds = 1 - imdilate(bounds,se);
imBounds(:,:,2) = imBounds(:,:,2).*uint8(bounds);
imBounds(:,:,3) = imBounds(:,:,3).*uint8(bounds);
imshow(imBounds, 'Parent', handles.DrawPolygon);


%set(handles.instruction_1,'Visible','off');
%set(handles.instruction_2,'Visible','off');
%set(handles.instruction_3,'Visible','off');

% --- Executes on button press in RunGC.
function RunGC_Callback(hObject, eventdata, handles)

set(handles.Processbar,'Visible','on');
global fixedBG;
global im;
global CurrRes;
global PrevRes;
global FileName;
global Tmask;
global s;

PrevRes = CurrRes;
imd = double(im);
Beta = handles.Beta_value;
k = handles.K_value;
G = 50;
maxIter = 10;
diffThreshold = 0.001;
L = GCAlgo(imd, fixedBG,k,G,maxIter, Beta, diffThreshold, handles.Processbar);
L = double(1 - L);
L = L | Tmask;

if get(handles.checkbox8, 'Value') == 1
    L = imfill(L, 'holes');
end

if get(handles.checkbox9, 'Value') == 0
    CC = bwconncomp(L, 8);
    S = regionprops(CC, 'Area');
    lm = labelmatrix(CC);
    L = ismember(lm, find([S.Area] >= max(max([S.Area]))));
end

CurrRes = imd.*repmat(L , [1 1 3]);

fixedBG = ~rgb2gray(CurrRes);
Tmask = ~fixedBG;

imshow(uint8(CurrRes), 'Parent', handles.DrawPolygon);
imshow(uint8(PrevRes), 'Parent', handles.PrevResult);

set(handles.Processbar,'String','Done');

se = strel('disk', 1);
aux = imerode(L, se);

ss = s/7;
ss(ss==1) = 0;

imwrite(L,strcat('resultados/mascaras/', datestr(now,'dd-mm-yyyy_HH.MM.SS'),'_MASCARA_', FileName));
imwrite(logical(L-aux>0.7),strcat('resultados/bordas/', datestr(now,'dd-mm-yyyy_HH.MM.SS'),'_BORDA_', FileName));
imwrite(uint8(CurrRes),strcat('resultados/segmentacoes/', datestr(now,'dd-mm-yyyy_HH.MM.SS'),'_SEGMENTACAO_', FileName));
imwrite(ss,strcat('resultados/kohonen/', datestr(now,'dd-mm-yyyy_HH.MM.SS'),'_KOHONEN_', FileName));


% --- Executes on button press in LoadPolygon.
function LoadPolygon_Callback(hObject, eventdata, handles)
set(handles.Processbar,'Visible','off');
FilterSpec = ['*'];
[FileName,PathName,FilterIndex] = uigetfile(FilterSpec);
fullFileName = strcat(PathName, FileName);

global fixedBG;

fixedBG = logical(imread(fullFileName) < 128);
imshow(fixedBG, 'Parent', handles.DrawPolygon);

%%% show red bounds:
global im;
imBounds = im;
bounds = double(abs(edge(fixedBG)));
se = strel('square',3);
bounds = 1 - imdilate(bounds,se);
imBounds(:,:,2) = imBounds(:,:,2).*uint8(bounds);
imBounds(:,:,3) = imBounds(:,:,3).*uint8(bounds);
imshow(imBounds, 'Parent', handles.DrawPolygon);


function K_text_Callback(hObject, eventdata, handles)
if  (str2double(get(hObject,'String')) < handles.K_min)
    handles.K_value = handles.K_min;
elseif ( str2double(get(hObject,'String')) > handles.K_max )
    handles.K_value = handles.K_max;
else
    handles.K_value = str2double(get(hObject,'String'));
end
set(handles.K_text,'String',num2str(handles.K_value ));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of K_text as text
%        str2double(get(hObject,'String')) returns contents of K_text as a double


% --- Executes during object creation, after setting all properties.
function K_text_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Beta_text_Callback(hObject, eventdata, handles)
if  (str2double(get(hObject,'String')) < handles.Beta_min)
    handles.Beta_value = handles.Beta_min;
elseif ( str2double(get(hObject,'String')) > handles.Beta_max )
    handles.Beta_value = handles.Beta_max;
else
    handles.Beta_value = str2double(get(hObject,'String'));
end
set(handles.Beta_text,'String',num2str(handles.Beta_value ));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of Beta_text as text
%        str2double(get(hObject,'String')) returns contents of Beta_text as a double


% --- Executes during object creation, after setting all properties.
function Beta_text_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function K_plus_Callback(hObject, eventdata, handles)
if ( handles.K_value < handles.K_max )
    handles.K_value = handles.K_value + 1;
    set(handles.K_text,'String',num2str(handles.K_value ));
    guidata(hObject, handles);
end

function K_minus_Callback(hObject, eventdata, handles)
if ( handles.K_value > handles.K_min )
    handles.K_value = handles.K_value - 1;
    set(handles.K_text,'String',num2str(handles.K_value ));
    guidata(hObject, handles);
end
function Beta_minus_Callback(hObject, eventdata, handles)
if ( handles.Beta_value > 0.1 + 0.000001)
    handles.Beta_value = handles.Beta_value - 0.1;
    set(handles.Beta_text,'String',num2str(handles.Beta_value ));
    guidata(hObject, handles);
elseif ( handles.Beta_value > handles.Beta_min + 0.000001)
    handles.Beta_value = handles.Beta_value - 0.01;
    set(handles.Beta_text,'String',num2str(handles.Beta_value ));
    guidata(hObject, handles);
end

function Beta_plus_Callback(hObject, eventdata, handles)
if ( handles.Beta_value < handles.Beta_max)
    if ( handles.Beta_value >= 0.1 - 1e-5)
        handles.Beta_value = handles.Beta_value + 0.1;
        set(handles.Beta_text,'String',num2str(handles.Beta_value ));
        guidata(hObject, handles);
    elseif ( handles.Beta_value >= handles.Beta_min-0.0001)
        handles.Beta_value = handles.Beta_value + 0.01;
        set(handles.Beta_text,'String',num2str(handles.Beta_value ));
        guidata(hObject, handles);
    end
end



function instruction_1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of instruction_1 as text
%        str2double(get(hObject,'String')) returns contents of instruction_1 as a double


% --- Executes during object creation, after setting all properties.
function instruction_1_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function instruction_3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function instruction_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function instruction_2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function instruction_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Processbar_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function Processbar_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Agrupar.
function Agrupar_Callback(hObject, eventdata, handles)
    global fixedBG;
    global s;
    global im;
    global area;
    
    area = roipoly(im);
    
    imwrite(area*255, 'mascara.bmp');
    
    s = KSOM([1 7], 100, 7, 'hextop', 'dist', im, area);
    
    if min(s(:)) == 0
        s = s+1;
    end

    fixedBG = logical(area == 1);
    fixedBG = bwareaopen(fixedBG, 256);
    fixedBG = imfill(fixedBG, 'holes');
    
    %%% show red bounds:
    imBounds = im;
    bounds = double(abs(fixedBG));
    se = strel('square',3);
    bounds = 1 - imdilate(bounds,se);
    fixedBG = imdilate(fixedBG, se);
    
    imBounds(:,:,2) = imBounds(:,:,2).*uint8(bounds);
    imBounds(:,:,3) = imBounds(:,:,3).*uint8(bounds);
    imshow(imBounds, 'Parent', handles.DrawPolygon);

    fixedBG = logical(1-fixedBG);

% hObject    handle to Agrupar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function DrawPolygon_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to DrawPolygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function checkboxs(hObject, eventdata, handles)   
    global s;
    global im;
    global fixedBG;
    global area;
    global Tmask;
    
    [m, n] = size(s);
    Tmask = zeros(m, n);
    
    s1 = zeros([m n]);
    s2 = s1; s3 = s1; s4 = s1; s5 = s1; s6 = s1; s7 = s1; 
    
    if get(handles.checkbox1, 'Value') == 1
        s1 = logical(s == 1);
    end
    if get(handles.checkbox2, 'Value') == 1
        s2 = logical(s == 2);
    end
    if get(handles.checkbox3, 'Value') == 1
        s3 = logical(s == 3);
    end
    if get(handles.checkbox4, 'Value') == 1
        s4 = logical(s == 4);
    end
    if get(handles.checkbox5, 'Value') == 1
        s5 = logical(s == 5);
    end
    if get(handles.checkbox6, 'Value') == 1
        s6 = logical(s == 6);
    end
    if get(handles.checkbox7, 'Value') == 1
        s7 = logical(s == 7);
    end
    
    fixedBG = logical(s1+s2+s3+s4+s5+s6+s7 ~= 0 & area == 1);
    %fixedBG = bwareaopen(fixedBG, 256);
    %fixedBG = imfill(fixedBG, 'holes');

    %%% show red bounds:
    imBounds = im;
    bounds = double(abs(fixedBG));
    se = strel('square',3);
    bounds = 1 - imdilate(bounds,se);
    fixedBG = imdilate(fixedBG, se);
    
    imBounds(:,:,2) = imBounds(:,:,2).*uint8(bounds);
    imBounds(:,:,3) = imBounds(:,:,3).*uint8(bounds);
    imshow(imBounds, 'Parent', handles.DrawPolygon);

    fixedBG = logical(1-fixedBG);
  figure, imshow(fixedBG);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)   
    checkboxs(hObject, eventdata, handles);
    
    
    
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    checkboxs(hObject, eventdata, handles);
    
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
    checkboxs(hObject, eventdata, handles);
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
    checkboxs(hObject, eventdata, handles);
    
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
    checkboxs(hObject, eventdata, handles);
    
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
    checkboxs(hObject, eventdata, handles);
    
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
    checkboxs(hObject, eventdata, handles);
    
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in pushbutton10. ADD
function pushbutton10_Callback(hObject, eventdata, handles)

    global fixedBG;
    global im;
    global Tmask;
    imBounds = im;
    bounds = double(abs(fixedBG));
    imBounds(:,:,2) = imBounds(:,:,2).*uint8(bounds);
    imBounds(:,:,3) = imBounds(:,:,3).*uint8(bounds);
    imshow(imBounds, 'Parent', handles.DrawPolygon);
    
       
%Desenha a nova mascara
    %mascara = ~roipoly(imBounds);
    handles = imfreehand(gca,'closed',0);
    lastroi = handles;
    while ~isempty(lastroi)
        lastroi = imfreehand(gca,'closed',0);
        handles = cat(1, handles, lastroi);
    end
    handles = handles(isvalid(handles));
    
    p = handles(1).getPosition;
    m = size(handles);
    for i = 2:m(1)
        p = cat(1, p, handles(i).getPosition);
    end
    
    p = ceil(p);
    m = size(im);
    mascara = zeros(m(1), m(2));
    
    mm = size(p);
    for i = 1:mm(1)
        if (p(mm(1)+i) >= 1 & p(mm(1)+i) <= m(1) & p(i) >= 1 & p(i) <= m(2)) 
            mascara(p(mm(1)+i),    p(i)) = 1;
        end
    end
    
    se = strel('disk', 4);
    mascara = imdilate(mascara, se);

%Constroi a mascara
    fixedBG = ~(~fixedBG | mascara);
    
    imBounds = im;
    bounds = double(abs(fixedBG));
    imBounds(:,:,2) = imBounds(:,:,2).*uint8(bounds);
    imBounds(:,:,3) = imBounds(:,:,3).*uint8(bounds);
    imshow(imBounds);
    Tmask = Tmask | mascara;
      
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12. REMOVER
function pushbutton12_Callback(hObject, eventdata, handles)

    global fixedBG;
    global im;
    global Tmask;

    imBounds = im;
    bounds = double(abs(fixedBG));
    imBounds(:,:,2) = imBounds(:,:,2).*uint8(bounds);
    imBounds(:,:,3) = imBounds(:,:,3).*uint8(bounds);
    imshow(imBounds, 'Parent', handles.DrawPolygon);
    
    
%Desenha a nova mascara
    %mascara = ~roipoly(imBounds);
    handles = imfreehand(gca,'closed',0);
    lastroi = handles;
    while ~isempty(lastroi)
        lastroi = imfreehand(gca,'closed',0);
        handles = cat(1, handles, lastroi);
    end
    handles = handles(isvalid(handles));
    
    p = handles(1).getPosition;
    m = size(handles);
    for i = 2:m(1)
        p = cat(1, p, handles(i).getPosition);
    end
    
    p = ceil(p);
    
    m = size(im);
    mascara = zeros(m(1), m(2));
    
    mm = size(p);
    for i = 1:mm(1)
        if (p(mm(1)+i) >= 1 & p(mm(1)+i) <= m(1) & p(i) >= 1 & p(i) <= m(2)) 
            mascara(p(mm(1)+i),    p(i)) = 1;
        end
    end
    
    se = strel('disk', 4);
    mascara = imdilate(mascara, se);
    
    fixedBG = fixedBG | mascara;
    Tmask = ~fixedBG;
    imBounds = im;
    bounds = double(abs(fixedBG));
    imBounds(:,:,2) = imBounds(:,:,2).*uint8(bounds);
    imBounds(:,:,3) = imBounds(:,:,3).*uint8(bounds);
    imshow(imBounds);
    
    
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
