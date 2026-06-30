
function out = formatter_from_CC(in,text_block,versions)

% This takes an input data structure produced by validate_CC_input and spits out HTML
% with formatted text for v3 and CRONUSCalc. 

% Check running in Octave
isOctave = 0;
if exist('OCTAVE_VERSION','builtin') > 0
    newline = "\n";
    isOctave = 1;
end

% CC input can be either 

if strcmp(in.n.nuclide{1},'N10quartz') || strcmp(in.n.nuclide{1},'N26quartz')
    t.CC.text1026 = text_block;
    t.CC.text3 = '';
    t.CC.text14 = '';
elseif strcmp(in.n.nuclide{1},'N3pyroxene')
    t.CC.text1026 = '';
    t.CC.text3 = text_block;
    t.CC.text14 = '';
elseif strcmp(in.n.nuclide{1},'N14quartz')
    t.CC.text1026 = '';
    t.CC.text3 = '';
    t.CC.text14 = text_block;
end

tab = char(9); 

% Generate v3 input
v3_lines = {};

% Spitting out v3 text needs to be by both sample and nuclide, because numsamples doesn't
% necessarily have to equal numnuclides
for a = 1:in.numsamples
    % Spit out a sample line
    % Sample name, lat, long
    s = [in.s.sample_name{a} ' ' sprintf('%0.4f',in.s.lat(a)) ' ' sprintf('%0.4f',in.s.long(a)) ' '];
    % Elevation, elevation flag
    if in.s.lat(a) < -60    
        s = [s sprintf('%0.0f',in.s.elv(a)) ' ant '];
    else
        s = [s sprintf('%0.0f',in.s.elv(a)) ' std '];
    end
    % Thickness, density, shielding, erosion rate, date
    s = [s sprintf('%0.1f',in.s.thick(a)) ' ' sprintf('%0.2f',in.s.rho(a)) ' '];
    s = [s sprintf('%0.4f',in.s.othercorr(a)) ' ' sprintf('%0.3e',in.s.E(a)) ' '];
    s = [s sprintf('%0.0f',in.s.yr(a)) ';' newline];
    v3_lines{end+1} = s;
end

for a = 1:in.numnuclides   
    % Now spit out a nuclide concentration line
    s = in.s.sample_name{in.n.index(a)};
    if strcmp(in.n.nuclide{a},'N10quartz')
        s = [s ' Be-10 quartz ' sprintf('%0.3e',in.n.N(a)) ' ' sprintf('%0.2e',in.n.delN(a)) ' 07KNSTD;' newline];
    elseif strcmp(in.n.nuclide{a},'N26quartz')
        s = [s ' Al-26 quartz ' sprintf('%0.3e',in.n.N(a)) ' ' sprintf('%0.2e',in.n.delN(a)) ' KNSTD;' newline];
    elseif strcmp(in.n.nuclide{a},'N3pyroxene')       
        s = [s ' He-3 pyroxene ' sprintf('%0.3e',in.n.N(a)) ' ' sprintf('%0.2e',in.n.delN(a)) ' NONE 0;' newline];
    elseif strcmp(in.n.nuclide{a},'N14quartz')
        s = [s ' C-14 quartz ' sprintf('%0.3e',in.n.N(a)) ' ' sprintf('%0.2e',in.n.delN(a)) ' NONE 0;' newline];
    end  
    v3_lines{end+1} = s;
end

% Need to get rid of any duplicate sample lines
v3_lines = unique(v3_lines);

if isOctave
    t.v3.text = char(strjoin(v3_lines,''));
else
    t.v3.text = char(join(v3_lines,''));
end

% Now generate CREp input 

CREP_lines_10 = {};
CREP_lines_3 = {};
tab = char(9); 

% CREP Be-10 and He-3 format
% Column 1: Sample name
% Column 2: Latitude (Decimal degrees). Range from -90 to 90°. Negative value for Southern Hemisphere.
% Column 3: Longitude (Decimal degrees). Range from -180 to 180°. Negative value for Western Hemisphere.
% Column 4: Altitude (masl)
% Column 5: Cosmogenic nuclide concentration (at.g-1). IMPORTANT: For 10Be, use the 07KNSTD standardization (Nishiizumi et al., 2007). If the 10Be concentrations are computed using another standardization, convert them to 07KNSTD before loading your data in CREp (see this link for more details).
% Column 6: Analytical 1-sigma uncertainty (at.g-1)
% Column 7: Shielding correction (dimensionless). Range from 0 to 1.
% Column 8: Sample density (g.cm-3).
% Column 9: Sample thickness (cm).
% Column 10: Erosion (cm.yr-1).

for a = 1:in.numnuclides
    if strcmp(in.n.nuclide{a},'N10quartz')
        % Spit out a Be-10 line
        s = [in.s.sample_name{in.n.index(a)} tab sprintf('%0.4f',in.s.lat(in.n.index(a))) tab sprintf('%0.4f',in.s.long(in.n.index(a))) tab];
        s = [s sprintf('%0.0f',in.s.elv(in.n.index(a))) tab sprintf('%0.3e',in.n.N(a)) tab sprintf('%0.2e',in.n.delN(a)) tab];
        s = [s sprintf('%0.4f',in.s.othercorr(in.n.index(a))) tab sprintf('%0.2f',in.s.rho(in.n.index(a))) tab];
        s = [s sprintf('%0.1f',in.s.thick(in.n.index(a))) tab sprintf('%0.2e',in.s.E(in.n.index(a))) newline];
        CREP_lines_10{end+1} = s;
    elseif strcmp(in.n.nuclide{a},'N3pyroxene') || strcmp(in.n.nuclide{a},'N3olivine')
        % Spit out a He-3 line
        s = [in.s.sample_name{in.n.index(a)} tab sprintf('%0.4f',in.s.lat(in.n.index(a))) tab sprintf('%0.4f',in.s.long(in.n.index(a))) tab];
        s = [s sprintf('%0.0f',in.s.elv(in.n.index(a))) tab sprintf('%0.3e',in.n.N(a)) tab sprintf('%0.2e',in.n.delN(a)) tab];
        s = [s sprintf('%0.4f',in.s.othercorr(in.n.index(a))) tab sprintf('%0.2f',in.s.rho(in.n.index(a))) tab];
        s = [s sprintf('%0.1f',in.s.thick(in.n.index(a))) tab sprintf('%0.2e',in.s.E(in.n.index(a))) newline];
        CREP_lines_3{end+1} = s;
    end
end

if isOctave
    t.CREP.text10 = char(strjoin(CREP_lines_10,''));
    t.CREP.text3 = char(strjoin(CREP_lines_3,''));
else
    t.CREP.text10 = char(join(CREP_lines_10,''));
    t.CREP.text3 = char(join(CREP_lines_3,''));
end
% Also add notes about what happened: 

t.v3.notes = 'Notes: <br><br>1. Atmosphere is set to either ''std'' or ''ant'' based on latitude.<br>2. Latitudes > 180 have been unwrapped.<br>3. Standardizations have been converted to 07KNSTD/KNSTD.<br>4. For He-3, the mineral is arbitrarily set to ''pyroxene'', and there is no standard normalization because that''s not supported by CRONUSCalc input.<br>6. Long sample names may be truncated.<br>7. Erosion rate units have been converted from mm/kyr to cm/yr.<br><br>';
t.v3.notes36 = '';

t.CREP.notes3 = 'Notes:<br><br>1. Latitudes > 180 have been unwrapped.<br>2. Erosion rate units have been converted.<br><br>';
t.CREP.notes10 = 'Notes:<br><br>1. Latitudes > 180 have been unwrapped.<br>2. Erosion rate units have been converted.<br><br>';
t.CREP.notes36 = '';

t.CC.notes1026 = '';
t.CC.notes3 = '';
t.CC.notes14 = '';
t.CC.notes36 = '';

versions.validate = in.version_validate;
versions.formatter_from_CC = '0.1-dev';
versions.converted_from = in.input_format;

% Now we have to spit that out as HTML. 

out = ftextToHTML(t,versions);




