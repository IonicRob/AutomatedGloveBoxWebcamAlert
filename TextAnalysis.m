%% Text Analysis

% close all
clear
clc

RecordingTable = table('Size',[0,2], 'VariableTypes', {'string', 'double'}, 'VariableNames', {'Time', 'Reading'});


%%
[file, path] = uigetfile('*.jpg');

fullFile = fullfile(path, file);

I = imread(fullFile);

I = im2gray(I);

imshow(I);


PressROI = drawrectangle;
% keyboard;
Positions = PressROI.Position;
delete(PressROI);
y_range = round(Positions(1):(Positions(1)+Positions(3)));
x_range = round(Positions(2):(Positions(2)+Positions(4)));

I = I(x_range, y_range);

%%

% https://uk.mathworks.com/help/images/ref/imbinarize.html
J = imbinarize(I,'global');

% % Detect MSER regions.
% [mserRegions, mserConnComp] = detectMSERFeatures(J, ... 
%     'RegionAreaRange',[200 8000],'ThresholdDelta',4);

figure
imshow(J)
% hold on
% plot(mserRegions, 'showPixelList', true,'showEllipses',false)
% title('MSER regions')
% hold off

% Perform OCR.
results = ocr(J, 'TextLayout', 'Line');

time = string(datestr(now, 'HH:MM:SS dd-mm-yy'));
reading = double(string(results.Words{1,1}));

table2add = table('Size',[1,2], 'VariableTypes', {'string', 'double'}, 'VariableNames', {'Time', 'Reading'});
table2add(1,1) = table(time);
table2add(1,2) = table(reading);
RecordingTable = [RecordingTable; table2add];

if reading > 1.0
    warning(' O2 above threshold! @ %g %s', reading, time);
    % https://uk.mathworks.com/matlabcentral/answers/346491-use-of-sendmail-function-to-send-an-email-from-a-gmail-account#answer_272161
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','E_mail','AJWABAQUS@gmail.com');
    setpref('Internet','SMTP_Username','AJWABAQUS');
    setpref('Internet','SMTP_Password','20Th!nFo!ls@20');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    emailheader = 'GLOVEBOX O2 LEVEL TOO HIGH';
    mainbodytext = sprintf('The glovebox has an O2 level of %g at a time of %s', reading, time);
    sendmail('robert.scales@materials.ox.ac.uk', emailheader, mainbodytext);
end

%%

camlist = webcamlist;
cam = webcam('USB Camera');
img = snapshot(cam);
imshow(img);
