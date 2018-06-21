function runListeningTest
global topics
global questions
global currQuestion

questions = {...
    'rate the global quality compared to the reference for each test signal';...
    'rate the closeness of the sound'};

topics = {...
    'the global quality compared to the reference for each test signal';...
    'the closeness of the sound'};

currQuestion = 1;

mushram;
