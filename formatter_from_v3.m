
function out = formatter_from_v3(in,text_block,versions)

% This takes an input data structure produced by validate_v3_input and spits out HTML
% with formatted text for CREp and CRONUSCalc. 


% Check running in Octave
isOctave = 0;
if exist('OCTAVE_VERSION','builtin') > 0
    isOctave = 1;
end

nl = char(10);

t.v3.text = text_block;

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
        s = [s sprintf('%0.1f',in.s.thick(in.n.index(a))) tab sprintf('%0.2e',in.s.E(in.n.index(a))) nl];
        CREP_lines_10{end+1} = s;
    elseif strcmp(in.n.nuclide{a},'N3pyroxene') || strcmp(in.n.nuclide{a},'N3olivine')
        % Spit out a He-3 line
        s = [in.s.sample_name{in.n.index(a)} tab sprintf('%0.4f',in.s.lat(in.n.index(a))) tab sprintf('%0.4f',in.s.long(in.n.index(a))) tab];
        s = [s sprintf('%0.0f',in.s.elv(in.n.index(a))) tab sprintf('%0.3e',in.n.N(a)) tab sprintf('%0.2e',in.n.delN(a)) tab];
        s = [s sprintf('%0.4f',in.s.othercorr(in.n.index(a))) tab sprintf('%0.2f',in.s.rho(in.n.index(a))) tab];
        s = [s sprintf('%0.1f',in.s.thick(in.n.index(a))) tab sprintf('%0.2e',in.s.E(in.n.index(a))) nl];
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

% Now generate CRONUSCalc input 

CC_lines_1026 = {};
CC_lines_3 = {};
CC_lines_14 = {};

for a = 1:in.numnuclides
    if strcmp(in.n.nuclide{a},'N10quartz') || strcmp(in.n.nuclide{a},'N26quartz')
        % 1. Sample Name
        % 2. Scaling -- use ST always, user can change
        % 3. Latitude
        % 4. Longitude
        s = [in.s.sample_name{in.n.index(a)} tab 'ST' tab sprintf('%0.4f',in.s.lat(in.n.index(a))) tab sprintf('%0.4f',in.s.long(in.n.index(a))) tab];
        % 5. Elevation
        % 6. Pressure
        % 7. Atmospheric Pressure or Elevation(Select One) - always uses elevation
        s = [s sprintf('%0.0f',in.s.elv(in.n.index(a))) tab '1013.25' tab 'Elevation' tab];
        % 8. Sample Thickness
        % 9. Bulk Density
        s = [s sprintf('%0.1f',in.s.thick(in.n.index(a))) tab sprintf('%0.2f',in.s.rho(in.n.index(a))) tab];
        % 10. Shielding Factor
        % 11. Erosion Rate
        % CC erosion rates are mm/kyr. v3 erosion rates are cm/yr. 
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
        s = [s '0' tab '0' tab '0' nl];
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
        s = [s sprintf('%0.0f',in.s.elv(in.n.index(a))) tab '1013.25' tab 'Elevation' tab];
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
        s = [s '0' tab '0' tab '0' nl];
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

t.v3.notes = '';
t.v3.notes36 = '';

t.CREP.notes3 = 'Note:<br><br>1. He-3 concentrations have been normalized to CRONUS-P = 5.02e9 atoms/g if possible.<br><br>';
t.CREP.notes10 = 'Note:<br><br>1. Be-10 concentrations have been normalized to 07KNSTD.<br><br>';
t.CREP.notes36 = '';

t.CC.notes1026 = 'Notes:<br><br>1. The ''scaling method'' input is set to ''ST'' for all lines.<br>2. Be-10/Al-26 concentrations have been normalized to 07KNSTD/KNSTD.<br>3. Be-10 and Al-26 measurements for the same sample are on separate lines - there''s not a universal way to combine them correctly for all possible input configurations.<br><br>';
t.CC.notes3 = 'Notes:<br><br>1. The ''scaling method'' input is set to ''ST'' for all lines.<br>2. He-3 concentrations have been normalized to CRONUS-P = 5.02e9 atoms/g if possible.<br><br>';
t.CC.notes14 = 'Note:<br><br>1. The ''scaling method'' input is set to ''ST'' for all lines.<br><br>';
t.CC.notes36 = '';

versions.validate = in.version_validate;
versions.formatter_from_v3 = '0.1-dev';
versions.converted_from = in.input_format;

% Now we have to spit that out as HTML. 

out = ftextToHTML(t,versions);




