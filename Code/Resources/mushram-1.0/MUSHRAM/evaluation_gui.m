function fig=evaluation_gui(nbfile,expe,nbexpe)

% EVALUATION_GUI Creates the GUI for the evaluation phase
%
% fig=evaluation_gui(nbfile,expe,nbexpe) creates the GUI given the number
% of tested files nbfile (including the reference), the experiment number
% expe and the total number of experiments nbexpe
%
% returns a handle to the figure if succeeds (nbfile small enough),
% returns false otherwise

%%%getting the screen size and computing the figure width
%screen size
set(0,'Units','characters');
siz=get(0,'Screensize');
maxwidth=siz(3);
%width of each item
iwidth=min(14,(maxwidth-26.5)/nbfile);
if iwidth < 9.5,
    fig=false;
    return;
end
%figure width
width=26.5+iwidth*nbfile;

%%%opening the figure
fig=figure('Name','MUSHRAM - Evaluation phase','NumberTitle','off','MenuBar','none','Resize','off','Units','characters','Position',[0 0 width 32]);

%%%displaying fixed items
%title
uicontrol(fig,'Style','Text','Units','characters','Position',[0 29 width 1.5],'FontSize',12,'String',['Experiment 1/' int2str(nbexpe)],'Tag','experiment');
%verbal performance assessments
uicontrol(fig,'Style','Text','Units','characters','Position',[3.5 21.87 19 1],'FontSize',10,'String','Excellent','Tag','scale90');
uicontrol(fig,'Style','Text','Units','characters','Position',[3.5 19.51 19 1],'FontSize',10,'String','Good','Tag','scale70');
uicontrol(fig,'Style','Text','Units','characters','Position',[3.5 17.15 19 1],'FontSize',10,'String','Fair','Tag','scale50');
uicontrol(fig,'Style','Text','Units','characters','Position',[3.5 14.79 19 1],'FontSize',10,'String','Poor','Tag','scale30');
uicontrol(fig,'Style','Text','Units','characters','Position',[3.5 12.43 19 1],'FontSize',10,'String','Bad','Tag','scale10');
%save and proceed button
results=uicontrol(fig,'Style','Pushbutton','Units','characters','FontSize',10,'Tag','results','Callback','evaluation_callbacks(''results'',guidata(gcbo))');
if expe==nbexpe,
    set(results,'Position',[width/2-9.5 1.5 19 1.8],'String','Save and exit');
else,
    set(results,'Position',[width/2-12 1.5 24 1.8],'String','Save and proceed');
end
%play reference button
uicontrol(fig,'Style','Pushbutton','Units','characters','Position',[3.5 5.7 19 1.8],'FontSize',10,'String','Play reference','Callback','evaluation_callbacks(''play'',guidata(gcbo),0)','Tag','play0');
%horizontal dashed lines
ax=axes('Units','characters','Position',[-.5 -.5 width+.5 32.5],'Tag','axes');
plot(ax,[3.5 width-3.5],[12.15 12.15],'--k',[3.5 width-3.5],[14.51 14.51],'--k',[3.5 width-3.5],[16.87 16.87],'--k',[3.5 width-3.5],[19.23 19.23],'--k',[3.5 width-3.5],[21.59 21.59],'--k',[3.5 width-3.5],[23.95 23.95],'--k');
set(ax,'Color',[0.701961 0.701961 0.701961],'XTick',[],'YTick',[],'XLim',[-.5 width+.5],'YLim',[-.5 32.5]);

%%%displaying items depending on the number of test signals
for f=1:nbfile,
    %sound number
    uicontrol(fig,'Style','Text','Units','characters','Position',[14+f*iwidth 26 9 1],'FontSize',10,'String',['Sound ' char(64+f)],'Tag',['title' int2str(f)]);
    %slider
    uicontrol(fig,'Style','Slider','Units','characters','Position',[17.1+f*iwidth 10.5 2.8 14.6],'Min',0,'Max',100,'Callback',['evaluation_callbacks(''slider'',guidata(gcbo),' int2str(f) ')'],'Tag',['slider' int2str(f)]);
    %performance figures
    uicontrol(fig,'Style','Edit','Enable','inactive','Units','characters','Position',[14+f*iwidth 8.2 9 1.6],'FontSize',10,'String',0,'Tag',['rating' int2str(f)]);
    %play buttons
    uicontrol(fig,'Style','Pushbutton','Units','characters','Position',[14+f*iwidth 5.7 9 1.8],'FontSize',10,'String','Play','Callback',['evaluation_callbacks(''play'',guidata(gcbo),' int2str(f) ')'],'Tag',['play' int2str(f)]);    
end

%%%moving onscreen
movegui(fig,'onscreen');