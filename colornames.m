function [nam,rgb,res] = colornames(scheme,varargin) %#ok<*SPERR>
% Convert between RGB values and colornames: CSS, dvips, HTML4, MacBeth, MATLAB, X11, xcolor, xkcd.
%
% (c) 2015 Stephen Cobeldick
%
% Quickly convert between colornames and their RGB values. This function matches
% input colors (either names or RGB) to colors from the selected colorscheme, and
% returns the RGB values, the standard colornames, and the residual RGB distances
% between the input and output colors. Some xkcd colornames may be unsuitable for work.
%
% Syntax:
%  schemes = colornames
%  names = colornames(scheme)
%  names = colornames(scheme,RGB)
%  names = colornames(scheme,RGB,deltaE)
%  names = colornames(scheme,names)
%  names = colornames(scheme,name1,name2,...)
% [names,RGB,residual] = colornames(scheme,...)
%
% Requires the file "colornames.mat". Conveniences for input color parsing:
%
% # Input Names:
% - Accepts multiple colornames (in a cell array, or as individual strings).
% - Matches both of 'gray' and 'grey'.
% - Case-insensitive colorname matches, eg 'Blue' == 'blue' == 'BLUE'.
% - Allows optional space characters between the colorname words.
% - Allows CamelCase to define the Crayola, MacBeth and xkcd colornames.
%
% # Input RGB:
% - Accepts multiple RGB values in a standard MATLAB Nx3 colormap.
% - Matches color to the HTML standard name, eg 'Fuchsia', not 'Magenta' (CSS/SVG/W3C).
% - Matches color to the nearest named color in a least-squares sense.
% - Choice of color distance calculation (deltaE), which can be selected by
%   one of these tokens: 'RGB', 'CMC2:1', 'CIE76', or 'CIE94' (default).
%
% See also PLOT PATCH SURF RGBPLOT COLORMAP BREWERMAP CUBEHELIX LBMAP CPRINTF NATSORT
%
% ### Space Characters in Input Names ###
%
% Most of the colorschemes use CamelCase in the colornames: this function
% matches colornames with any character case or spaces between the words, eg:
% 'Sky Blue' == 'SKY BLUE' == 'sky blue' == 'SkyBlue' == 'SKYBLUE' == 'skyblue'.
%
% Crayola and xkcd names include spaces, and some clashes occur if the names
% are converted to one case (eg lower) and the spaces removed. To make these
% names more convenient to use, CamelCase is equivalent to words separated
% by spaces, eg: 'EggShell' == 'Egg Shell' == 'egg shell' == 'EGG SHELL'.
% Note this is a different color to 'Eggshell' == 'eggshell' == 'EGGSHELL'.
%
% Note in xkcd the forward slash ('/') also distinguishes between different
% colors: 'Blue/Green' is not the same as 'Blue Green' (== 'BlueGreen').
%
% MacBeth and Kelly colornames include spaces: CamelCase is equivalent to words
% separated by spaces, eg: '5BlueFlower' == '5 Blue Flower' == '5 blue flower'
% The index number or words alone can also be used to select a color, eg:
% '5' == 'Blue Flower' == 'BLUE FLOWER' == 'BlueFlower' == '5 Blue Flower'
%
% ### Examples ###
%
% colornames
%  ans = {'Alphabet';'Crayola';'CSS';'dvips';'HTML';'Kelly';'MacBeth';'MATLAB';'Wolfram';'X11';'xcolor';'xkcd'}
%
% colornames('html')
%  ans = {'Aqua';'Black';'Blue';'Fuchsia';'Gray';'Green';'Lime';'Maroon';...
%         'Navy';'Olive';'Purple';'Red';'Silver';'Teal';'White';'Yellow'}
%
% [nam,rgb,res] = colornames('html','PURPLE','yellow')
%  nam = {'Purple';'Yellow'}
%  rgb = [0.5,0,0.5;1,1,0]
%  res = [0;0]
%
% [nam,rgb,res] = colornames('html',[0.4,0.1,0.6;0.8,0.9,0.3])
%  nam = {'Purple';'Yellow'}
%  rgb = [0.5,0,0.5;1,1,0]
%  res = [0.17321;0.37417]
%
% [nam,rgb] = colornames('matlab');
% [char(strcat(nam,{'  '})),num2str(rgb)]
% ans =
%  Black    0  0  0
%  Blue     0  0  1
%  Cyan     0  1  1
%  Green    0  1  0
%  Magenta  1  0  1
%  Red      1  0  0
%  White    1  1  1
%  Yellow   1  1  0
%
% ### Input and Output Arguments ###
%
% Inputs (*=default):
%  scheme = String, the name of a supported colorscheme, eg 'CSS'.
% The optional input/s can be names or RGB values. Names can be either:
%  names  = CellOfStrings, any number of supported colornames.
%  name1,name2,... = Strings, any number of supported colornames.
% RGB values in a matrix, with optional choice of color-distance deltaE:
%  RGB    = NumericMatrix, size Nx3, each row is an RGB triple (0<=rgb<=1).
%  deltaE = String token, *'CIE94', 'CIE76', 'CMC2:1', or 'RGB'.
%
% Outputs:
%  nam = CellOfStrings, size Nx1, the colornames of the requested colors.
%  rgb = NumericMatrix, size Nx3, RGB values corresponding to <nam>.
%  res = Numeric, size Nx1, the residual, i.e. the shortest distance from
%        the requested color (names/RGB) and the matched color <rgb>.
%
%[nam,rgb,res] = colornames(scheme,names OR name1,name2,..)
% OR
%[nam,rgb,res] = colornames(scheme,RGB,*deltaE)

data = load('colornames.mat');
mcs = fieldnames(data);
%
% ### Return All Colorscheme Names ###
%
if nargin==0
    nam = mcs;
    return
end
%
% ### Retrieve the Scheme's Colornames and RGB ###
%
assert(ischar(scheme)&&isrow(scheme),'First input <scheme> must be a string.')
idx = strcmpi(scheme,mcs);
assert(any(idx),'Scheme ''%s'' is not supported. Please see the M-file help.',scheme)
%
nam = data.(mcs{idx}).names;
rgb = double(data.(mcs{idx}).rgb) / data.(mcs{idx}).scale;
%
% ### Return the Whole Scheme, or Parse the Input RGB ###
%
if nargin==1 % whole scheme
    res = zeros(numel(nam),1);
    return
elseif isnumeric(varargin{1}) % RGB values
    [res,idx] = cnClosest(rgb,varargin{1},varargin(2:end));
    nam = nam(idx,:);
    rgb = rgb(idx,:);
    res = sqrt(res);
    return
elseif iscellstr(varargin{1}) % colornames in a cell array
    assert(nargin==2,'Too many inputs: only one CellOfStrings (colornames) is allowed.')
    arg = varargin{1}(:);
elseif iscellstr(varargin) % individual colornames
    arg = varargin(:);
else
    error('Input colors must be either an RGB matrix, or colorname strings (individual or in cell).')
end
%
% ### Input Colorname CamelCase and Space Character Handling ###
%
gra = regexprep(arg,'Grey','Gray','ignorecase');
idx = true(size(arg));
switch lower(scheme)
    case 'xkcd' %
        gra = regexprep(gra,'([a-z])([A-Z][a-z])','$1 $2');
    case 'crayola' %
        gra = regexprep(gra,'([a-z]''?)(\(?[A-Z][a-z])','$1 $2');
    case {'macbeth','kelly'} % Match whole name, index number, or words only.
        gra = regexprep(gra,'([a-z]|\d)([A-Z][a-z])','$1 $2');
        tmp = regexp(nam,' ','split','once');
        tmp = strcat('^',vertcat(tmp{:}),'$');
        gra = regexprep(gra,tmp(:),[nam;nam],'ignorecase');
    otherwise % CamelCase: ensure that all space characters are only between words.
        tmp = regexprep(gra,' ','');
        idx = strcmpi(tmp,gra);
        cnIsMember(scheme,gra(~idx),arg(~idx),regexprep(nam,'([a-z])([A-Z][a-z])','$1 $2'))
        gra = tmp;
end
cnIsMember(scheme,gra(idx),arg(idx),nam)
%
% ### Parse Input Colornames ###
%
idx = cellfun(@(s)find(strcmpi(s,nam)),gra);
nam = nam(idx,:);
rgb = rgb(idx,:);
res = zeros(numel(gra),1);
%
end
%----------------------------------------------------------------------END:colornames
function cnIsMember(scheme,gra,arg,nam) % scheme,adjustedInput,rawInput,colornames
% Assert that every string in <gra> is a member of <nam>.
%
idx = ~cellfun(@(s)any(strcmpi(s,nam)),gra);
if any(idx)
    tmp = sprintf(' ''%s'',',arg{idx});
    error('The scheme ''%s'' does not support these colors:%s\b',scheme,tmp)
end
%
end
%----------------------------------------------------------------------END:cnIsMember
function [res,idx] = cnClosest(rgb,arg,typ)
% Use color difference (deltaE) to identify the closest colors to input RGB values.
%
% ### Input Wrangling ###
%
switch numel(typ)
    case 0
        typ = 'CIE94';
    case 1
        typ = typ{1};
        assert(ischar(typ)&&isrow(typ),...
            'Third input argument must be a string to select the color difference method.')
    otherwise
        error('Too many input arguments. See help for information on input options.')
end
assert(ismatrix(arg)&&size(arg,2)==3&&isreal(arg)&&all(0<=arg(:)&arg(:)<=1),...
    'Second input argument can be a colormap of RGB values (size Nx3).')
%
% ### Calculate the Color Difference (deltaE) ###
%
if strcmpi(typ,'RGB')
    [res,idx] = cellfun(@(c)min(sum(bsxfun(@minus,rgb,c).^2,2)),num2cell(arg,2));
    return
end
%
mat = cnRGB2Lab(rgb);
gra = cnRGB2Lab(arg);
switch upper(typ)
    case 'CIE76'
        [~,idx] = cellfun(@(c)min(sum(bsxfun(@minus,mat,c).^2,2)),num2cell(gra,2));
    case 'CIE94'
        [~,idx] = cellfun(@(c)min(sum(cnCIE94(mat,c).^2,2)),num2cell(gra,2));
    case 'CMC2:1'
        [~,idx] = cellfun(@(c)min(sum(cnCMC21(mat,c).^2,2)),num2cell(gra,2));
    otherwise
        error('The color distance ''%s'' is not supported. Please read the help.',typ)
end
% Distance in RGB color-space:
res = sum((rgb(idx,:)-arg).^2,2);
%
end
%----------------------------------------------------------------------END:cnClosest
function lab = cnRGB2Lab(rgb) % Nx3 <- Nx3
% Convert a matrix of RGB values to CIELab.
%
% Inverse Gamma
idx = rgb <= 0.040448;
rgb(idx) = rgb(idx)/12.92;
rgb(~idx) = real(((rgb(~idx) + 0.055)/1.055).^2.4);
% RGB -> XYZ
mat = [0.41245,0.35758,0.18049;0.21259,0.71516,0.07217;0.019297,0.11918,0.9505];
xyz = bsxfun(@rdivide,rgb*mat.',[0.950456,1,1.088754]);
%
% XYZ -> Lab
idx = xyz>(6/29)^3;
F = idx.*xyz.^(1/3) + ~idx.*(xyz*(29/6)^2/3+4/29);
lab(:,2:3) = bsxfun(@times,[500,200],F(:,1:2)-F(:,2:3));
lab(:,1) = 116*F(:,2) - 16;
%
end
%----------------------------------------------------------------------END:cnRGB2Lab
function dLCH = cnCIE94(mat,val) % Nx3 <- Nx3,1x3
% Return a matrix of d[L,C,H] values used in the CIE94 deltaE calculation.
%
Cm = sqrt(sum(mat(:,[2,3]).^2,2));
Cv = sqrt(sum(val(:,[2,3]).^2,2));
%
dLCH = [(mat(:,1)-val(:,1)), (Cm-Cv),...
    sqrt((mat(:,2)-val(:,2)).^2 + (mat(:,3)-val(:,3)).^2 - (Cm-Cv).^2)]...
    ./ bsxfun(@times,[2,1,1],(1 + bsxfun(@times, Cm, [0,0.048,0.014])));
%
end
%----------------------------------------------------------------------END:cnCIE94
function dLCH = cnCMC21(mat,val) % Nx3 <- Nx3,1x3
% Return a matrix of d[L,C,H] values used in the CMC 2:1 deltaE calculation.
%
Cm = sqrt(sum(mat(:,[2,3]).^2,2));
Cv = sqrt(sum(val(:,[2,3]).^2,2));
%
SL = 0.040975*mat(:,1)./(1+0.01765*mat(:,1));
SL(mat(:,1)<16) = 0.511;
%
SC = 0.638 + 0.0638*Cm./(1+0.0131*Cm);
%
Hm = mod(360*atan2(mat(:,3),mat(:,2))/2*pi,360);
F = sqrt(Cm.^4./(1900+Cm.^4));
A = [0.36;0.56]; B = [0.4;0.2]; D = [35;168];
X = 1+(164<=Hm & Hm<=345);
T = A(X) + abs(B(X).*cos(D(X)+(2*pi)*Hm/360));
SH = SC.*(F.*T + 1 - F);
%
dLCH = [(mat(:,1)-val(:,1))./SL, (Cm-Cv)./SC,...
    sqrt((mat(:,2)-val(:,2)).^2 + (mat(:,3)-val(:,3)).^2 - (Cm-Cv).^2)./SH];
%
end
%----------------------------------------------------------------------END:cnCMC21