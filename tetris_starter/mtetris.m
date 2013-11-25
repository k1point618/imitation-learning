function mtetris(cmd)
%MTETRIS   Matlab Tetris (v1.1)
%
%   To play this game, type: MTETRIS
%
%   Controls (use numpad):
%    [4] Left  [5] Spin  [6] Right
%              [2] Drop
%
%    alternatively,
%    [Q] Left  [W] Spin  [E] Right
%              [S] Drop
%
%    [Ctrl+P] Pause/Unpause
%
%   During the game, use the game menu to set difficulty and to
%   enable/disable sound effects.  Only one game can run at a time.
%   mtetris was written and tested on Matlab 5.3 (R11), but may
%   work with as early as Matlab 4.0 without changes.

%   Author: Pascal Getreuer, June 2004
%   Modified by: Pieter Abbeel, November 2009 
%    -- fixed a bug that caused only 6 out of 7 blocks to be sampled
%    -- added the logging into the global variables options_map_log and chosen_map_log

global MODE TIMESTEP MAP POS GEO BOXOFF BOXY SNDFLAG SNDS SNDD SNDROW SHAPEIND;
global SCORE CLKSND HFIG HMODE HSCORE HCUR HMAP HPAUSE HSTOP HDIF HSND;

global  options_map_log chosen_map_log  map_idx

if nargin ~= 1 | cmd == 'U' | cmd == 'C',		%%% mtetris main routine %%%

BoxX = 10 + 2;								% playing field width + 2 border cells
BOXY = 18 + 1;								% playing field height + 1 border cell
BOXOFF = [BOXY,1];
MODE = 0;									% set game mode to play
RowScore = [100,250,400,600] - 5;	% points for filling rows
% shapes data
% original code from the mathworks: has a bug, one block appears twice, one
% block is missing (3rd and 1st are identical)
%Shapes = reshape([-1 0 0 0 0 1 1 0 -1 0 0 0 1 0 2 0 -1 0 0 0 0 1 1 0 -1 ...
%    -1 0 0 0 0 1 1 1 0 0 0 1 1 0 1 1 -1 0 0 0 1 0 1 1 -1 1 -1 0 0 0 1 0],2,4,7);
% fixed: [PA]
Shapes = reshape([-1 0 0 0 0 1 1 0 -1 0 0 0 1 0 2 0 -1 1 0 1 0 0 1 0 ...
    -1 0 0 0 0 1 1 1 0 0 0 1 1 0 1 1 -1 0 0 0 1 0 1 1 -1 1 -1 0 0 0 1 0],2,4,7);
%[PA] these colors are a poor choice imho
% let's replace them with std tetris colors; and let's have the color
% depend on the shape rather than be random
%ShapeColors = [1 0 0;1 1 0;0 0.8 0;0 0 1];
ShapeColors = [  255 255 102;  255 133 10; 0 245 61 ; 51  204 255; 255 10 10; 10 10 255; 153 0 204]/255;
PatX = [0;-1;-1;0];						% coordinates for drawing patches
PatY = [0;0;-1;-1];
ClkV=[0;0;86400;3600;60;1];

if nargin ~= 1 | cmd == 'C'
   if nargin ~= 1		% initialize GUI
      CLKSND = clock;      
      
      % initialize figure window
		HFIG = figure('Name','MTetris','Numbertitle','off','Menubar','none',...
   		'Color',[0.831373 0.815686 0.784314],'Resize','off','DoubleBuffer','on',...
         'Position',[150,150,220,400],'CloseRequestFcn',[mfilename,'(''X'')'],...
         'KeyPressFcn',[mfilename,'(''K'')']);
		axes('Units','normalized','Position', [.05 .06 .9 .93],'Visible','off',...
   		'DrawMode','fast','NextPlot','replace','XLim',[1,BoxX-1],'YLim',[1,BOXY]);
      set(line([1,BoxX-1,BoxX-1,1,1],[1,1,BOXY,BOXY,1]),'Color',[0,0,0]);
        
   	% make button and handles
		HSCORE  = uicontrol('Units','normalized','Position',[0.05,0.01,.5,.05],...
   		'Style','text','HorizontalAlignment','Left','FontWeight','bold');
		HMODE = uicontrol('Units','normalized','Position',[0.1,0.7,.8,.1],...
         'Style','text','FontSize',14);
      
		% make menu
      tmp = uimenu('Label','&Game');
		HPAUSE = uimenu(tmp,'Label','&Pause','Callback',[mfilename,'(''P'')']);
		HSTOP = uimenu(tmp,'Label','&Stop','Callback',[mfilename,'(''N'')']);
	   HDIF(1) = uimenu(tmp,'Label','&Beginner','Callback',[mfilename,'(''1'')'], ...
   	   'Separator','on','Checked','on');
		HDIF(2) = uimenu(tmp,'Label','&Intermediate','Callback',[mfilename,'(''2'')']);
   	HDIF(3) = uimenu(tmp,'Label','&Expert','Callback',[mfilename,'(''3'')']);
	   HDIF(4) = uimenu(tmp,'Label','&Custom...','Callback',[mfilename,'(''4'')']);
   	HSND = uimenu(tmp,'Label','S&ound','Callback',[mfilename,'(''O'')'],'Separator','on');
      uimenu(tmp,'Label','E&xit','Callback',[mfilename,'(''X'')'],'Separator','on');
      tmp = uimenu('Label','&Help');
      uimenu(tmp,'Label','Help &Notes','Callback',['global MODE;if ~MODE,',...
         mfilename,'(''P'');end;msgbox({''Controls (use numpad):'',',...
         '''   [4] Left   [5] Spin   [6] Right'',''                 [2] Drop'','''',',...
         '''   alternatively,'',''   [Q] Left  [W] Spin  [E] Right'','...
         '''                 [S] Drop'','''',',...
         '''   [Ctrl+P] Pause/Unpause  ''},''Help Notes'')']);
      uimenu(tmp,'Label','&M-File Info','Callback','help MTetris');
      uimenu(tmp,'Label','&About MTetris','Separator','on','Callback',['global MODE;',...
            'if ~MODE,',mfilename,'(''P'');end;msgbox({'''',''MTetris   1.1'',' ...
            '''by Pascal Getreuer 2004-2005''},''About MTetris'')']);
      set(HFIG,'Position',[150,150,220,400]);
      
   	TIMESTEP = 0.8;		% beginner difficulty mode
		SNDFLAG = 1;			% sound effects initially enabled (0 for disabled)
      GameSounds;
   else
      figure(HFIG);
   end
   
   set(HPAUSE,'Label','&Pause','Accelerator','P');
  	set(HMODE,'String','PAUSED','Visible','off');
   set(HSCORE,'String','Score: 0');

	MAP = ones(BOXY,BoxX);
	MAP(2:BOXY,2:BoxX-1) = 0;
	HMAP = zeros(BOXY,BoxX);
	SCORE = 0;
	   
   % place first shape
   SHAPEIND = ceil(rand(1)*size(Shapes,3));
	GEO = Shapes(:,:,SHAPEIND);
	POS = [ceil(BoxX/2);BOXY-2];
	Color = ShapeColors(SHAPEIND,:);

    % fill in potential next states/maps
    map_idx = 1;
    ii=1;
    for translation = 1:10
        for rotation = 0:3
            map1 = tetris_place_block(MAP, SHAPEIND, translation, rotation);
            options_map_log{map_idx}{ii} = map1;
            ii=ii+1;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
	for i = 1:4
	   HCUR(i) = patch(PatX + POS(1) + GEO(1,i),...
   	   PatY + POS(2) + GEO(2,i),Color);
   end
else
   figure(HFIG);
end

LastSound = clock;

while ~MODE		% main game loop   
   FrameStart = clock*ClkV;
   
   if any(MAP(BOXOFF*POS + BOXOFF*GEO - BOXY - 1))		% check if shape is blocked
   	% add current shape into arrays
      MAP(BOXOFF*POS + BOXOFF*GEO - BOXY) = 1;
      HMAP(BOXOFF*POS + BOXOFF*GEO - BOXY) = HCUR;
      % spawn a new shape
      SHAPEIND = ceil(rand(1)*size(Shapes,3));
      GEO = Shapes(:,:,SHAPEIND);
      POS = [ceil(BoxX/2);BOXY-2];
      Color = ShapeColors(SHAPEIND,:);
     
 
      
      % check for filled rows
      %      tmp = flipud(find(sum(MAP(2:BOXY,:),2) == BoxX)) + 1;
      
      tmp = (find(sum(MAP(2:BOXY,:),2) == BoxX)) + 1;
      
      if ~isempty(tmp)
         SCORE = SCORE + RowScore(length(tmp));		% add points for row (or rows)
         
         % clear rows and drop above rows
         for i = length(tmp):-1:1 %1:length(tmp)
            delete(HMAP(tmp(i),2:BoxX-1));
            HMAP = [HMAP([1:tmp(i)-1,tmp(i)+1:BOXY],:);zeros(1,BoxX)];
            MAP = [MAP([1:tmp(i)-1,tmp(i)+1:BOXY],:);1,zeros(1,BoxX-2),1];
         end
         
         for k1 = 2:BOXY
            for k2 = 2:BoxX-1
               if HMAP(k1,k2) ~= 0
                  set(HMAP(k1,k2),'YData',k1 + PatY);
               end
            end
         end
         
         tmp = clock;
		   while etime(clock,tmp) < 0.2 & ~MODE, drawnow; end
         sound(SNDROW,22050);
         CLKSND = clock;
      end
      
      %store currently chosen map:
      map_idx = length(chosen_map_log);
      chosen_map_log{map_idx+1} = MAP;

      
      SCORE = SCORE + 5;
      set(HSCORE,'String',['Score: ',num2str(SCORE)]);	% show updated score
      
      for i = 1:4
         HCUR(i) = patch(PatX + POS(1) + GEO(1,i),PatY + POS(2) + GEO(2,i),Color);
      end
         
      if any(MAP(BOXOFF*POS + BOXOFF*GEO - BOXY))	 % game over
         feval(mfilename,'N');
         break;
      end
      
      % fill in potential next states/maps
      ii=1;
      for translation = 1:10
          for rotation = 0:3
              map1 = tetris_place_block(MAP, SHAPEIND, translation, rotation);
              options_map_log{map_idx+2}{ii} = map1;
              ii=ii+1;
          end
      end
      
      

   end
   
   if ~MODE		% drop shape one cell
      if ~any(MAP(BOXOFF*POS + BOXOFF*GEO - BOXY - 1))
         POS = POS + [0;-1];
         
         for i = 1:4
            set(HCUR(i),'XData',PatX+POS(1) + GEO(1,i),'YData',PatY+POS(2) + GEO(2,i));
         end
      end
   end
      
   % wait one timestep   
   while (clock)*ClkV-FrameStart < TIMESTEP & ~MODE   
      drawnow;
   end
   
   drawnow;   
end

else	%%% GUI callback routines %%%
   if cmd == 'K' & ~MODE
      switch get(HFIG,'CurrentCharacter')
      case {'4','q','Q'}		% move shape left
         if ~any(MAP(BOXOFF*POS + BOXOFF*GEO - BOXY*2))
            POS = POS + [-1;0];
         end
      case {'6','e','E'}		% move shape right
         if ~any(MAP(BOXOFF*POS + BOXOFF*GEO))
            POS = POS + [1;0];
         end
      case {'5','w','W'}		% spin shape
         if ~any(MAP(BOXOFF*POS + [-1,BOXY]*GEO - BOXY))
            if etime(clock,CLKSND) > 0.2
               sound(SNDS,22050);
               CLKSND = clock;
            end
            
            if SHAPEIND ~= 5
               GEO = [0,1;-1,0]*GEO;
            end            
         end
      case {'2','s','S'}		% drop shape
         NewInd = BOXOFF*POS + BOXOFF*GEO - BOXY - 1;
         if ~any(MAP(NewInd))
            if etime(clock,CLKSND) > 0.2
               sound(SNDD,22050);
               CLKSND = clock;
            end
            
            while ~any(MAP(NewInd))
               NewInd = NewInd - 1;
               POS = POS + [0;-1];
            end
         end
      end
      
      if all(ishandle(HCUR))
	      for i = 1:4
   	      set(HCUR(i),'XData',[0;-1;-1;0] + POS(1) + GEO(1,i),...            
      	      'YData',[0;0;-1;-1] + POS(2) + GEO(2,i));
	      end
      end
      
      return;
   end   
      
   switch(cmd)
   case 'P'
      switch MODE
      case 0		% pause the game
	   	MODE = 1;
	   	set(HPAUSE,'Label','&Unpause');
   		set(HMODE,'Visible','on');
         set(HCUR,'Visible','off');
         set(HMAP,'Visible','off');
      case 1		% unpause the game
         MODE = 0;
	      set(HPAUSE,'Label','&Pause');
   	   set(HMODE,'Visible','off'); 
      	set(HCUR,'Visible','on');
         set(HMAP,'Visible','on');
         feval(mfilename,'U');	% unpause current game
      case 2		% new game
         feval(mfilename,'C');	% start a new game, but do not reinitialize the GUI
	   end
   case 'N'
      if MODE ~= 2 			% stop game
         MODE = 2;                  
         drawnow;                           
         set(HPAUSE,'Label','&New','Accelerator','N');
         set(HMODE,'String','GAME OVER','Visible','on');
         
         if all(ishandle(HCUR))
            delete(HCUR(:));
         end
         
         for i = 1:prod(size(HMAP))
            if HMAP(i), delete(HMAP(i)); end            
         end
      end
   case '1'			% beginner difficulty
      TIMESTEP = 0.8;		% shapes fall one cell every 800 ms 
      set(HDIF(1),'Checked','on');
      set(HDIF(2:4),'Checked','off');
   case '2'			% intermediate difficulty
      TIMESTEP = 0.48;
      set(HDIF(2),'Checked','on');
      set(HDIF([1,3,4]),'Checked','off');
   case '3'			% expert difficulty
      TIMESTEP = 0.3;
      set(HDIF(3),'Checked','on');
      set(HDIF([1,2,4]),'Checked','off');
   case '4'			% custom difficulty
      tmp = inputdlg('Time Step (decrease for faster game)',...
         'Custom Difficulty',1,{num2str(TIMESTEP*1000)});      
      if ~isempty(tmp)          
         tmp = str2double(tmp)/1000;         
         if ~isnan(tmp) & isreal(tmp) & tmp >= 0
	        	TIMESTEP = tmp;
         	set(HDIF(4),'Checked','on');
            set(HDIF(1:3),'Checked','off');
         end
      end
   case 'O'			% enable/disable sound effects
      SNDFLAG = ~SNDFLAG;
      GameSounds;
	case 'X'			% exit
      MODE = 2;
      drawnow;
      closereq;
	end
end
return;


function GameSounds		%%% game sound effects %%%
global SNDFLAG SNDLR SNDS SNDD SNDROW HSND;

if SNDFLAG
   set(HSND,'Checked','on');
	SNDS = sin(([0:1500,1500:-1:0]).^1.2*2*pi*70/22050)*0.6;						% spin
	SNDD = sin((3500:-1:1).^1.2*pi*200/22050).*linspace(0.6,0.1,3500);		% drop
	SNDROW = conv(ones(1,15)/15,sin((1:5000)*pi.*interp1(...						% row filled
      [500,600,400,600,300,200],linspace(1,6,5000),'nearest')/22050));   
else
   set(HSND,'Checked','off');
   SNDS = 0; SNDD = 0; SNDROW = 0;	      
end
return;
