
function out = formatter_from_CREp(in,text_block,versions)

% This takes an input data structure produced by validate_CREp_input and spits out HTML
% with formatted text for v3 and CRONUSCalc. 

% CREP input can be either Be-10 or He-3

% Check running in Octave
isOctave = 0;
if exist('OCTAVE_VERSION','builtin') > 0
    newline = "\n";
    isOctave = 1;
end

if strcmp(in.n.nuclide{1},'N10quartz')
    t.CREP.text10 = text_block;
    t.CREP.text3 = '';
else
    t.CREP.text10 = '';
    t.CREP.text3 = text_block;
end

tab = char(9); 

% Generate v3 input
v3_lines = {};

% Note there have to be the same number of samples and nuclides in
% CREp-derived data structures
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
    s = [s '2017;' newline];
    
    % Now spit out a nuclide concentration line
    if strcmp(in.n.nuclide{1},'N10quartz')
        s = [s 'Be-10 quartz ' sprintf('%0.3e',in.n.N(a)) ' ' sprintf('%0.2e',in.n.delN(a)) ' 07KNSTD;' newline];
    else
        s = [s 'He-3 pyroxene ' sprintf('%0.3e',in.n.N(a)) ' ' sprintf('%0.2e',in.n.delN(a)) ' NONE 0;' newline];
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
% Now generate CRONUSCalc input 

CC_lines_1026 = {};
CC_lines_3 = {};
CC_lines_14 = {};

for a = 1:in.numnuclides
    if strcmp(in.n.nuclide{a},'N10quartz') | strcmp(in.n.nuclide{a},'N26quartz')
        % 1. Sample Name
        % 2. Scaling -- use ST always, user can change
        % 3. Latitude
        % 4. Longitude
        s = [in.s.sample_name{in.n.index(a)} tab 'ST' tab sprintf('%0.4f',in.s.lat(in.n.index(a))) tab sprintf('%0.4f',in.s.long(in.n.index(a))) tab];
        % 5. Elevation
        % 6. Pressure
        % 7. Atmospheric Pressure or Elevation(Select One) - always uses elevation
        s = [s sprintf('%0.0f',in.s.elv(in.n.index(a))) tab '0' tab 'Elevation' tab];
        % 8. Sample Thickness
        % 9. Bulk Density
        s = [s sprintf('%0.1f',in.s.thick(in.n.index(a))) tab sprintf('%0.2f',in.s.rho(in.n.index(a))) tab];
        % 10. Shielding Factor
        % 11. Erosion Rate
        % CC erosion rates are mm/kyr. CREp and v3 erosion rates are cm/yr. 
        s = [s sprintf('%0.4f',in.s.othercorr(in.n.index(a))) tab sprintf('%0.2e',1e4.*in.s.E(in.n.index(a))) tab];
        % 12. Conc. 10Be
        % 13. 10Be Standardization
        % 14. Conc. 26Al
        % 15. 26Al Standardization
        if strcmp(in.n.nuclide{a},'N10quartz')
            s = [s sprintf('%0.3e',in.n.N(a)) tab '07KNSTD' tab '0' tab 'KNSTD' tab];
        else
            s = [s '0' tab '07KNSTD' tab sprintf('%0.3e',in.n.N(a)) tab 'KNSTD' tab];
        end
        % 16. Attenuation length
        % 17. Depth to Top of Sample
        % 18. Year Collected
        s = [s '150' tab '0' tab sprintf('%0.0f',in.s.yr(in.n.index(a))) tab];
        % 19. Latitude Uncertainty
        % 20. Longitude Uncertainty
        % 21. Elevation Uncertainty
        % 22. Pressure Uncertainty
        % 23. Sample Thickness Uncertainty
        % 24. Bulk Density Uncertainty
        % 25. Shielding Factor Uncertainty
        % 26. Erosion-Rate Uncertainty
        s = [s '0' tab '0' tab '0' tab '0' tab '0' tab '0' tab '0' tab '0' tab];
        % 27. Conc. 10Be Uncertainty
        % 28. Conc. 26Al Uncertainty
        if strcmp(in.n.nuclide{a},'N10quartz')
            s = [s sprintf('%0.2e',in.n.delN(a)) tab '0' tab];
        else
            s = [s '0' tab sprintf('%0.2e',in.n.delN(a)) tab];
        end
        % 29. Attenuation Length Uncertainty
        % 30. Depth to Top of Sample Uncertainty
        % 31. Year Collected Uncertainty
        s = [s '0' tab '0' tab '0' newline];
        CC_lines_1026{end+1} = s;
    elseif strcmp(in.n.nuclide{a},'N3pyroxene') | strcmp(in.n.nuclide{a},'N3olivine') | strcmp(in.n.nuclide{a},'N14quartz')
        % He-3 and C-14 have the same set of inputs
        % 1. Sample Name
        % 2. Scaling -- use ST always, user can change
        % 3. Latitude
        % 4. Longitude
        s = [in.s.sample_name{in.n.index(a)} tab 'ST' tab sprintf('%0.4f',in.s.lat(in.n.index(a))) tab sprintf('%0.4f',in.s.long(in.n.index(a))) tab];
        % 5. Elevation
        % 6. Pressure
        % 7. Atmospheric Pressure or Elevation(Select One) - always uses elevation
        s = [s sprintf('%0.0f',in.s.elv(in.n.index(a))) tab '0' tab 'Elevation' tab];
        % 8. Sample Thickness
        % 9. Bulk Density
        s = [s sprintf('%0.1f',in.s.thick(in.n.index(a))) tab sprintf('%0.2f',in.s.rho(in.n.index(a))) tab];
        % 10. Shielding Factor
        % 11. Erosion Rate
        s = [s sprintf('%0.4f',in.s.othercorr(in.n.index(a))) tab sprintf('%0.2e',in.s.E(in.n.index(a))) tab];
        % 12.Conc. 3He
        s = [s sprintf('%0.3e',in.n.N(a)) tab];
        % 13. Attenuation length
        % 14. Depth to Top of Sample
        % 15. Year Collected
        s = [s '150' tab '0' tab sprintf('%0.0f',in.s.yr(in.n.index(a))) tab];
        % 16. Latitude Uncertainty
        % 17. Longitude Uncertainty
        % 18. Elevation Uncertainty
        % 19. Pressure Uncertainty
        % 20. Sample Thickness Uncertainty
        % 21. Bulk Density Uncertainty
        % 22. Shielding Factor Uncertainty
        % 23. Erosion-Rate Uncertainty
        s = [s '0' tab '0' tab '0' tab '0' tab '0' tab '0' tab '0' tab '0' tab];
        % 24. Conc. 3He Uncertainty
        s = [s sprintf('%0.2e',in.n.delN(a)) tab];
        % 25. Attenuation Length Uncertainty
        % 26. Depth to Top of Sample Uncertainty
        % 27. Year Collected Uncertainty
        s = [s '0' tab '0' tab '0' newline];
        if strcmp(in.n.nuclide{a},'N14quartz')
            CC_lines_14{end+1} = s;
        else
            CC_lines_3{end+1} = s;
        end
    end
end

if isOctave
    t.CC.text1026 = char(strjoin(CC_lines_1026,''));
    t.CC.text3 = char(strjoin(CC_lines_3,''));
    t.CC.text14 = char(strjoin(CC_lines_14,''));
else
    t.CC.text1026 = char(join(CC_lines_1026,''));
    t.CC.text3 = char(join(CC_lines_3,''));
    t.CC.text14 = char(join(CC_lines_14,''));
end

% Also add notes about what happened: 

t.v3.notes = 'Notes: <br><br>1. Atmosphere is set to either ''std'' or ''ant'' based on latitude.<br>2. Collection date is not in CREp input so is arbitrarily set to the beginning of the first Trump administration.<br>3. Be-10 standardization is assumed to be 07KNSTD.<br>4. CREp input has no standardization info for He-3.<br>5. For He-3, the mineral is arbitrarily set to ''pyroxene''.<br>6. Long sample names may be truncated.<br><br>';
t.v3.notes36 = '';

t.CREP.notes10 = '';
t.CREP.notes3 = '';

t.CC.notes1026 = 'Notes:<br><br>1. The ''scaling method'' input is set to ''ST'' for all lines.<br>2. Be-10 concentrations have been assumed on 07KNSTD.<br>3. Long sample names may be truncated.<br>4. Erosion rate units have been converted from cm/yr to mm/kyr.<br><br>';
t.CC.notes3 = 'Notes:<br><br>1. The ''scaling method'' input is set to ''ST'' for all lines.<br>2. Long sample names may be truncated.<br>3. Erosion rate units have been converted from cm/yr to mm/kyr<br><br>';
t.CC.notes14 = '';
t.CC.notes36 = '';

versions.validate = in.version_validate;
versions.formatter_from_CREp = '0.1-dev';
versions.converted_from = in.input_format;

% Now we have to spit that out as HTML. 

out = ftextToHTML(t,versions);




