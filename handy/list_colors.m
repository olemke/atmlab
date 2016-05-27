function [vc,hex] = list_colors(varargin)
%
% list_colors
% Purpose:
%         From a cell of string arguments create a cell of rgb vectors for the
%         corresponding colors from the following table. Can also pass rogue rgb
%         vectors amongst color markers. e.g
%         strcolors = {'r',[.1 .1 .1],'k','b'}
%
% Indata: 1) Either requested number of colors is given: list_colors('Ncolors',n)
%
%         2) Or the colors are given in short string arguments. e.g
%               list_colors('Colors',{'r','b'}), but the colors most be in the
%               colors list. see bellow for available colors
%
%
%
% Available colors (add more?)
% LONGNAME  | shortname | vector
%           |           |
% black     | 'k'       | [0,0,0]
% green     | 'g'       | [0,1,0]
% red       | 'r'       | [1,0,0]
% blue      | 'b'       | [0,0,1]
% cyan      | 'c'       | [0,1,1]
% magenta   | 'm'       | [1,0,1]
% yellow    | 'y'       | [1,1,0]
% white     | 'w'       | [1,1,1]
% grey      | 'gr'      | [.5 .5 .5]
% purple    | 'p'       | [.8 0 1]
% orange    | 'o'       | [1 .7 0]
% caucasian | 'ca'      | [1 .5 .5]
% pink      | 'pi'      | [1 .5 1]
%
% default loop of colors: colors={'k','g','r','b','c','m','y','gr','p','o','ca','pi'};
%
% $Id$
% 18/11,2009 Salomon Eliasson

assert(ischar(varargin{1}),'First argument must be either "Ncolors" or "Colors"')
assert((strcmpi(varargin{1},'Ncolors')&isscalar(varargin{2})) |...
    (strcmpi(varargin{1},'Colors')&iscell(varargin{2})),...
    ['If "Ncolors" provide a scalar second argument. '...
    'If "Colors" provide a cell as the second argument'])


assert(nargin>0,['Salomons:' mfilename ':badInput'],'Input error')
colors={'k','g','r','b','c','m','y','gr','p','o','caucasian 1','pi'};

%% LOAD CUSTOM OPTIONS:
for iopt = 1 : 2 : nargin
    optname  = varargin{iopt};
    optvalue = varargin{iopt+1};
    switch lower(optname)
        case 'colors'
            strcolors=optvalue;
        case 'ncolors'
            k=1;
            strcolors=cell(optvalue,1);
            for ii=1:optvalue
                strcolors{ii}=colors{k};
                k=k+1;
                if k==length(colors),k=1;end
            end
    end
end

vc=cell(length(strcolors),1);hex=cell(length(strcolors),1);
for i=1:length(strcolors)                                                       % Create vectors of colors
    if isnumeric(strcolors{i})
        vc{i}=strcolors{i};
    elseif ischar(strcolors{i})
        switch lower(strcolors{i})


                % from http://www.tayloredmktg.com/rgb/
                %
                % white pastels
            case 'snow', vc{i}=[255,250,250]; hex{i} = 'fffafa';
            case 'snow 2', vc{i}=[238,233,233]; hex{i} = 'eee9e9';
            case 'snow 3', vc{i}=[205,201,201]; hex{i} = 'cdc9c9';
            case 'snow 4', vc{i}=[139,137,137]; hex{i} = '8b8989';
            case 'ghost white', vc{i}=[248,248,255]; hex{i} = 'f8f8ff';
            case 'white smoke', vc{i}=[245,245,245]; hex{i} = 'f5f5f5';
            case 'gainsboro', vc{i}=[220,220,220]; hex{i} = 'dccdc';
            case 'floral white', vc{i}=[255,250,240]; hex{i} = 'fffaf0';
            case 'old lace', vc{i}=[253,245,230]; hex{i} = 'fdf5e6';
            case 'linen', vc{i}=[240,240,230]; hex{i} = 'faf0e6';
            case 'antique white', vc{i}=[250,235,215]; hex{i} = 'faebd7';
            case 'antique white 2', vc{i}=[238,223,204]; hex{i} = 'eedfcc';
            case 'antique white 3', vc{i}=[205,192,176]; hex{i} = 'cdc0b0';
            case 'antique white 4', vc{i}=[139,131,120]; hex{i} = '8b8378';
            case 'papaya whip', vc{i}=[255,239,213]; hex{i} = 'ffefd5';
            case 'blanched almond', vc{i}=[255,235,205]; hex{i} = 'ffebcd';
            case 'bisque', vc{i}=[255,228,196]; hex{i} = 'ffe4c4';
            case 'bisque 2', vc{i}=[238,213,183]; hex{i} = 'eed5b7';
            case 'bisque 3', vc{i}=[205,183,158]; hex{i} = 'cdb79e';
            case 'bisque 4', vc{i}=[139,125,107]; hex{i} = '8b7d6b';
            case 'peach puff', vc{i}=[255,218,185]; hex{i} = 'ffdab9';
            case 'peach puff 2', vc{i}=[238,203,173]; hex{i} = 'eecbad';
            case 'peach puff 3', vc{i}=[205,175,149]; hex{i} = 'cdaf95';
            case 'peach puff 4', vc{i}=[139,119,101]; hex{i} = '8b7765';
            case 'navajo white', vc{i}=[255,222,173]; hex{i} = 'ffdead';
            case 'moccasin', vc{i}=[255,228,181]; hex{i} = 'ffe4b5';
            case 'cornsilk', vc{i}=[255,248,220]; hex{i} = 'fff8dc';
            case 'cornsilk 2', vc{i}=[238,232,205]; hex{i} = 'eee8dc';
            case 'cornsilk 3', vc{i}=[205,200,177]; hex{i} = 'cdc8b1';
            case 'cornsilk 4', vc{i}=[139,136,120]; hex{i} = '8b8878';
            case 'ivory', vc{i}=[255,255,240]; hex{i} = 'fffff0';
            case 'ivory 2', vc{i}=[238,238,224]; hex{i} = 'eeeee0';
            case 'ivory 3', vc{i}=[205,205,193]; hex{i} = 'cdcdc1';
            case 'ivory 4', vc{i}=[139,139,131]; hex{i} = '8b8b83';
            case 'lemon chiffon', vc{i}=[255,250,205]; hex{i} = 'fffacd';
            case 'seashell', vc{i}=[255,245,238]; hex{i} = 'fff5ee';
            case 'seashell 2', vc{i}=[238,229,222]; hex{i} = 'eee5de';
            case 'seashell 3', vc{i}=[205,197,191]; hex{i} = 'cdc5bf';
            case 'seashell 4', vc{i}=[139,134,130]; hex{i} = '8b8682';
            case 'honeydew', vc{i}=[240,255,240]; hex{i} = 'f0fff0';
            case 'honeydew 2', vc{i}=[244,238,224]; hex{i} = 'e0eee0';
            case 'honeydew 3', vc{i}=[193,205,193]; hex{i} = 'c1cdc1';
            case 'honeydew 4', vc{i}=[131,139,131]; hex{i} = '838b83';
            case 'mint cream', vc{i}=[245,255,250]; hex{i} = 'f5fffa';
            case 'azure', vc{i}=[240,255,255]; hex{i} = 'f0ffff';
            case 'alice blue', vc{i}=[240,248,255]; hex{i} = 'f0f8ff';
            case 'lavender', vc{i}=[230,230,250]; hex{i} = 'e6e6fa';
            case 'lavender blush', vc{i}=[255,240,245]; hex{i} = 'fff0f5';
            case 'misty rose', vc{i}=[255,228,225]; hex{i} = 'ffe4e1';
            case {'w','white'}, vc{i}=[255,255,255]; hex{i} = 'ffffff';

                
                %%%%%%%%%%%%%%
                % 'grays
                
            case {'k','black'}, vc{i}=[0,0,0]; hex{i} = '000000';
            case 'dark slate gray', vc{i}=[49,79,79]; hex{i} = '2f4f4f';
            case 'dim gray', vc{i}=[105,105,105]; hex{i} = '696969';
            case 'slate gray', vc{i}=[112,138,144]; hex{i} = '708090';
            case 'light slate gray', vc{i}=[119,136,153]; hex{i} = '778899';
            case {'gr','gray','grey'}, vc{i}=[190,190,190]; hex{i} = 'bebebe';
            case 'light gray', vc{i}=[211,211,211]; hex{i} = 'd3d3d3';
                
                %%%%%%%%%%
                % blues
                
            case 'midnight blue', vc{i}=[25,25,112]; hex{i} = '191970';
            case 'navy', vc{i}=[0,0,128]; hex{i} = '000080';
            case 'cornflower blue', vc{i}=[100,149,237]; hex{i} = '6495ed';
            case 'dark slate blue', vc{i}=[72,61,139]; hex{i} = '483d8b';
            case 'slate blue', vc{i}=[106,90,205]; hex{i} = '6a5acd';
            case 'medium slate blue', vc{i}=[123,104,238]; hex{i} = '7b68ee';
            case 'light slate blue', vc{i}=[132,112,255]; hex{i} = '8470ff';
            case 'medium blue', vc{i}=[0,0,205]; hex{i} = '0000cd';
            case 'royal blue', vc{i}=[65,105,225]; hex{i} = '4169e1';
            case {'blue','b'}, vc{i}=[0,0,255]; hex{i} = '0000ff';
            case 'dodger blue', vc{i}=[30,144,255]; hex{i} = '1e90ff';
            case 'deep sky blue', vc{i}=[0,191,255]; hex{i} = '00bfff';
            case 'sky blue', vc{i}=[135,206,250]; hex{i} = '87ceeb';
            case 'light sky blue', vc{i}=[135,206,250]; hex{i} = '87cefa';
            case 'steel blue', vc{i}=[70,130,180]; hex{i} = '4682b4';
            case 'light steel blue', vc{i}=[176,196,222]; hex{i} = 'b0c4de';
            case 'light blue', vc{i}=[173,216,230]; hex{i} = 'add8e6';
            case 'powder blue', vc{i}=[176,224,230]; hex{i} = 'b0e0e6';
            case 'pale turquoise', vc{i}=[175,238,238]; hex{i} = 'afeeee';
            case 'dark turquoise', vc{i}=[0,206,209]; hex{i} = '00ced1';
            case 'medium turquoise', vc{i}=[72,209,204]; hex{i} = '48d1cc';
            case 'turquoise', vc{i}=[64,224,208]; hex{i} = '40e0d0';
            case {'c','cyan'}, vc{i}=[0,255,255]; hex{i} = '00ffff';
            case 'light cyan', vc{i}=[224,255,255]; hex{i} = 'e0ffff';
            case 'cadet blue', vc{i}=[95,158,160]; hex{i} = '5f9ea0';
                
                %%%%%%%%
                % greens
            case {'g','green'}, vc{i}=[0 255 0];hex{i}='00ff00';
            case 'medium aquamarine', vc{i}=[102,205,170]; hex{i} = '66cdaa';
            case 'aquamarine', vc{i}=[127,255,212]; hex{i} = '7fffd4';
            case 'dark green', vc{i}=[0,100,0]; hex{i} = '006400';
            case 'dark olive green', vc{i}=[85,107,47]; hex{i} = '556b2f';
            case 'dark sea green', vc{i}=[143,188,143]; hex{i} = '8fbc8f';
            case 'sea green', vc{i}=[46,139,87]; hex{i} = '2e8b57';
            case 'medium sea green', vc{i}=[60,179,113]; hex{i} = '3cb371';
            case 'light sea green', vc{i}=[32,178,170]; hex{i} = '20b2aa';
            case 'pale green', vc{i}=[152,251,152]; hex{i} = '98fb98';
            case 'spring green', vc{i}=[0,255,127]; hex{i} = '00ff7f';
            case 'lawn green', vc{i}=[124,252,0]; hex{i} = '7cfc00';
            case 'chartreuse', vc{i}=[127,255,0]; hex{i} = '7fff00';
            case 'medium spring green', vc{i}=[0,250,154]; hex{i} = '00fa9a';
            case 'green yellow', vc{i}=[173,255,47]; hex{i} = 'adff2f';
            case 'lime green', vc{i}=[50,205,50]; hex{i} = '32cd32';
            case 'yellow green', vc{i}=[154,205,50]; hex{i} = '9acd32';
            case 'forest green', vc{i}=[34,139,34]; hex{i} = '228b22';
            case 'olive drab', vc{i}=[107,142,35]; hex{i} = '6b8e23';
            case 'dark khaki', vc{i}=[189,183,107]; hex{i} = 'bdb76b';
            case 'khaki', vc{i}=[240,230,140]; hex{i} = 'f0e68c';
                
                %%%%%%%%%%%
                % yellow
                
                
            case 'pale goldenrod', vc{i}=[238,232,170]; hex{i} = 'eee8aa';
            case 'light goldenrod yellow', vc{i}=[250,250,210]; hex{i} = 'fafad2';
            case 'light yellow', vc{i}=[255,255,224]; hex{i} = 'ffffe0';
            case {'y','yellow'}, vc{i}=[255,255,0]; hex{i} = 'ffff00';
            case 'gold', vc{i}=[255,215,0]; hex{i} = 'ffd700';
            case 'light goldenrod', vc{i}=[238,221,130]; hex{i} = 'eedd82';
            case 'goldenrod', vc{i}=[218,165,32]; hex{i} = 'daa520';
            case 'dark goldenrod', vc{i}=[184,134,11]; hex{i} = 'b8860b';
                
                %%%%%%%%%%%%
                % browns
                
            case 'rosy brown', vc{i}=[188,143,143]; hex{i} = 'bc8f8f';
            case 'indian red', vc{i}=[205,92,92]; hex{i} = 'cd5c5c';
            case 'saddle brown', vc{i}=[139,69,19]; hex{i} = '8b4513';
            case 'sienna', vc{i}=[160,82,45]; hex{i} = 'a0522d';
            case 'peru', vc{i}=[205,133,63]; hex{i} = 'cd853f';
            case 'burlywood', vc{i}=[222,184,135]; hex{i} = 'deb887';
            case 'beige', vc{i}=[245,245,220]; hex{i} = 'f5f5dc';
            case 'wheat', vc{i}=[245,222,179]; hex{i} = 'f5deb3';
            case 'sandy brown', vc{i}=[244,164,96]; hex{i} = 'f4a460';
            case 'tan', vc{i}=[210,180,140]; hex{i} = 'd2b48c';
            case 'chocolate', vc{i}=[210,105,30]; hex{i} = 'd2691e';
            case 'firebrick', vc{i}=[178,34,34]; hex{i} = 'b22222';
            case 'brown', vc{i}=[165,42,42]; hex{i} = 'a52a2a';
                
                %%%%%%%%%%%
                % oranges
                
                
            case 'dark salmon', vc{i}=[233,150,122]; hex{i} = 'e9967a';
            case 'salmon', vc{i}=[250,128,114]; hex{i} = 'fa8072';
            case 'light salmon', vc{i}=[255,160,122]; hex{i} = 'ffa07a';
            case {'o','orange'}, vc{i}=[255,165,0]; hex{i} = 'ffa500';
            case 'dark orange', vc{i}=[255,140,0]; hex{i} = 'ff8c00';
            case 'coral', vc{i}=[255,127,80]; hex{i} = 'ff7f50';
            case 'light coral', vc{i}=[240,128,128]; hex{i} = 'f08080';
            case 'tomato', vc{i}=[255,99,71]; hex{i} = 'ff6347';
            case 'orange red', vc{i}=[255,69,0]; hex{i} = 'ff4500';
            case {'red','r'}, vc{i}=[255,0,0]; hex{i} = 'ff0000';
                
                %%%%%%%%%%%%%%%%%%
                % pinks/violets
                
  
            case 'caucasian 1',vc{i}=[255,224,189]; hex{i}='ffe0bd';
            case 'caucasian 2',vc{i}=[255,205,148]; hex{i}='ffcd95';
            case 'caucasian 3',vc{i}=[234,192,134]; hex{i}='eac086';
            case 'caucasian 4',vc{i}=[255,173,96]; hex{i}='ffad60';
            case 'caucasian 5',vc{i}=[255,227,159]; hex{i}='ffe39f';
            case 'hot pink', vc{i}=[255,105,180]; hex{i} = 'ff69b4';
            case 'deep pink', vc{i}=[255,20,147]; hex{i} = 'ff1493';
            case {'pi','pink'}, vc{i}=[255,192,203]; hex{i} = 'ffc0cb';
            case 'light pink', vc{i}=[255,182,193]; hex{i} = 'ffb6c1';
            case 'pale violet red', vc{i}=[219,112,147]; hex{i} = 'db7093';
            case 'maroon', vc{i}=[176,48,96]; hex{i} = 'b03060';
            case 'medium violet red', vc{i}=[199,21,133]; hex{i} = 'c71585';
            case 'violet red', vc{i}=[208,32,144]; hex{i} = 'd02090';
            case 'violet', vc{i}=[238,130,238]; hex{i} = 'ee82ee';
            case 'plum', vc{i}=[221,160,221]; hex{i} = 'dda0dd';
            case 'orchid', vc{i}=[218,112,214]; hex{i} = 'da70d6';
            case 'medium orchid', vc{i}=[186,85,211]; hex{i} = 'ba55d3';
            case 'dark orchid', vc{i}=[153,50,204]; hex{i} = '9932cc';
            case 'dark violet', vc{i}=[148,0,211]; hex{i} = '9400d3';
            case 'blue violet', vc{i}=[138,43,226]; hex{i} = '8a2be2';
            case {'p','purple'}, vc{i}=[160,32,240]; hex{i} = 'a020f0';
            case 'medium purple', vc{i}=[147,112,219]; hex{i} = '9370db';
            case {'m','magenta'}, vc{i}=[255 0 255]; hex{i} = 'ff00ff';
            case 'thistle', vc{i}=[216,191,216]; hex{i} = 'd8bfd8';
                
                
            otherwise
                error(['salomons:',mfilename,':badinput'],'color: %s not in list. add color to mfile?',strcolors{i})
        end
    elseif iscell(strcolors{i})
        error(['salomons' mfilename, ':badinput'],'color is in a double cell')
    else
        disp(strcolors{i})
        error(['salomons' mfilename, ':badinput'],'wrong color:')
    end
end

% normalise colors to matlab default (0-1)
vc = cellfun(@(x)(x/255),vc,'uniformoutput',0);

end