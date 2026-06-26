function out = ftextToHTML(t,versions)

% This ingests the age results structure from the various formatter scripts
% and spits out an
% HTML string that is the results web page.  
% Input arg t looks like:
% t.input_text v3 input text string
% t.CREP10 CREp Be-10 input format (also a string)
% t.CREP3 etc...
% t.CC1026
% t.CC3
% t.CC14
% They all have to exist but they can be empty strings. 
%
% This will need to be modified to fork for Cl-36 or not Cl-36. 
%
% Written by Greg Balco - June, 2024
% Development, not licensed for use or distribution. 
%
% TODO: pass originating format so notes can be appropriate

nl = char(10);

% Write header

out = ['<!DOCTYPE html>' nl '<html>' nl '<head>' nl '<title>Exposure age calculator v3 results</title>' nl ...       
    '<style>' nl '<!--table {}' nl '.title2{font-family:Arial;font-size:12.0pt;}' nl ...
    '.title{font-family:Arial;font-size:10.0pt;}' nl '.standard{font-family:Arial;font-size:8.0pt;}' nl ... 
    '-->' nl  '</style>' nl '</head>'];

out = [out nl nl '<body>'];

% Title table
out = [out nl '<table>' nl '<tr>' nl '<td class="title2" colspan="3">' nl ...
    '<hr><i><b><p>Online exposure age calculator input text format conversion</p></b></i><hr>' nl '</td>' nl '</tr>'];

% Version table

out = [out '<tr>' nl '<td class=title width=200 valign=top>' ];
out = [out nl 'Version info:' nl '</td>' nl '<td class=standard width=300>'];
fns = fieldnames(versions);
for a = 1:length(fns)
    thisstr = [nl fns{a} ': ' eval(['versions.' fns{a}]) nl '<br>' nl];
    out = [out thisstr];
end
out = [out nl '</td>' nl '</tr>'];
out = [out nl '<tr><td colspan=3><hr></td></tr>' nl ];

% Texts

out = [out '<tr><td colspan=3 class=standard>'];

out = [out nl nl '<b>v3 format:</b><br><br>' nl nl];
out = [out t.v3.notes nl];

out = [out '<pre>' nl t.v3.text nl '</pre><br><br>' nl nl];

out = [out '</td></tr><tr><td colspan=3><hr></td></tr><tr><td colspan=3 class=standard>'];

out = [out nl nl '<b>CREp Be-10:</b><br><br>' nl nl];
out = [out t.CREP.notes10 nl];


if ~isempty(t.CREP.text10)
    out = [out '<pre>' nl t.CREP.text10 nl '</pre><br><br>' nl nl];
else
    out = [out '<pre>' nl '(none)' nl '</pre><br><br>' nl nl];
end

out = [out nl nl '<b>CREp He-3:</b><br><br>' nl nl];

% The below should only appear if the origin is v3 format. If other origin,
% it should say something else. 
out = [out t.CREP.notes3 nl];


if ~isempty(t.CREP.text3)
    out = [out '<pre>' nl t.CREP.text3 nl '</pre><br><br>' nl nl];
else
    out = [out '<pre>' nl '(none)' nl '</pre><br><br>' nl nl];
end

out = [out '</td></tr><tr><td colspan=3><hr></td></tr><tr><td colspan=3 class=standard>'];

out = [out nl nl '<b>CRONUSCalc Be-10/Al-26:</b><br><br>' nl nl];
out = [out t.CC.notes1026 nl];

if ~isempty(t.CC.text1026)
    out = [out '<pre>' nl t.CC.text1026 nl '</pre><br><br>' nl nl];
else
    out = [out '<pre>' nl '(none)' nl '</pre><br><br>' nl nl];
end

out = [out nl nl '<b>CRONUSCalc He-3:</b><br><br>' nl nl];
out = [out t.CC.notes3 nl];

if ~isempty(t.CC.text3)
    out = [out '<pre>' nl t.CC.text3 nl '</pre><br><br>' nl nl];
else
    out = [out '<pre>' nl '(none)' nl '</pre><br><br>' nl nl];
end

out = [out nl nl '<b>CRONUSCalc C-14:</b><br><br>' nl nl];
out = [out t.CC.notes14 nl];


if ~isempty(t.CC.text14)
    out = [out '<pre>' nl t.CC.text14 nl '</pre><br><br>' nl nl];
else
    out = [out '<pre>' nl '(none)' nl '</pre><br><br>' nl nl];
end

out = [out '</td></tr><tr><td colspan=3><hr></td></tr></table>'];


% End HTML
out = [out nl '</center></body>' nl '</html>'];






