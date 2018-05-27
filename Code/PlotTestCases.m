function PlotTestCases(varargin)
narginchk(0,2)
Dflttestcase = 1:3;
DfltroomSize = ["small","medium","large"];
if nargin == 2
    testcase = varargin{1};
    roomSize = varargin{2};
elseif nargin == 1
    if isstring(varargin{1})
        testcase = Dflttestcase;
        roomSize = varargin{1};
    else
        testcase = varargin{1};
        roomSize = DfltroomSize;
    end
else %Plot all if no input/default case
    testcase = Dflttestcase;
    roomSize = DfltroomSize;
end


for j = 1:size(roomSize,2)
    for i = testcase
        %Set up the simulation environment
        [Receivers,Sources,Room]=SetupSim(i,roomSize(j));
        
        %Plot a 3-D map for the display of source and receivers
        PlotSimSetup(Sources,Receivers,Room);
        title(sprintf('Receivers and Sources Location for Test Case %d in %s Room', i, regexprep(roomSize(j),'(\<[a-z])','${upper($1)}')),'Interpreter', 'latex')
        view(2);
        print(sprintf('TestCases\\testcase-%s-%d.png',roomSize(j),i),'-dpng')
    end
end

end