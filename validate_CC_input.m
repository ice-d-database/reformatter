function out = validate_CC_input(text_block,dtype)

% Validates data supplied in CRONUSCalc format. 
% out = validate_CC_input(text_block,type)
% Text block is the text block
% Type signals what type of input it is...can be 'CC1026','CC3', or
% 'CC14'. These all have different numbers of elements. 

% Version
out.version_validate = 'validate_CC_input.m - 0.1-dev';
out.error = 0;
out.message = '';

out.input_format = dtype;

load consts_v3;

% Deal with missing data
tab = char(9);

text_block = strrep(text_block,[tab tab],[tab '0' tab]);

% Parse into non-white-space elements

parsed_text = textscan(text_block,'%s');
parsed_text = parsed_text{1}; % Peculiarity of textscan

% Now a text array called parsed_text contains all the 
% separate items from the text block as array elements.
numitems = length(parsed_text);

% Here define the correct number of items per row -- 
if strcmp(dtype,'CC1026')
    numcols = 31;
    isAlBe = 1;
elseif strcmp(dtype,'CC3')
    numcols = 27;
    isAlBe = 0;
elseif strcmp(dtype,'CC14')
    numcols = 27;
    isAlBe = 0;
else
    out.error = 1;
    out.message = 'validate_CC_input.m: Unrecognized nuclide input';
    return
end

if mod(numitems,numcols) ~= 0
    out.error = 1;
    out.message = ['Expected ' int2str(numcols) ' items per line for ' dtype ' input and got something different'];
    return;
end

% if it passed that, break into lines
numlines = numitems./numcols;

out.numsamples = numlines; 

% And preallocate sample data structure

out.s.sample_name = cell(out.numsamples,1);
out.s.lat = zeros(out.numsamples,1);
out.s.long = out.s.lat;
out.s.elv = out.s.lat; 
out.s.thick = out.s.lat;
out.s.rho = out.s.lat;
out.s.othercorr = out.s.lat;
out.s.E = out.s.lat;
out.s.yr = out.s.lat; % Year of sample collection; will have default


% Initialize nuclide data structure. 
out.n.index = []; % Field indexing nuclide measurement to sample number
out.n.nuclide = {}; % Nuclide/target identifier
out.n.N = []; % Properly standardized nuclide concentration
out.n.delN = []; % Same, uncertainty in

% Now do assignments
% Notes:
% The actual sample data is in positions 1:11. After that are just nuclide
% concentrations and all the uncertainties. The only relevant uncertainties
% are for the nuclide concentrations, so all others can be ignored. 
% Year collected is item 18 in Al/Be data and item 15 in others. 
% In Al/Be data, N10 is item 12, delN10 is item 27, std10 is item 13.
% N26 is item 14, delN26 is item 28, and std26 is item 15. 
% In other data, N is item 12 and delN is item 24. 
% Sample depth and attenuation length are ignored - put this in the notes.

for a = 1:numlines
    si = (a-1)*numcols;
    ino = 1;
    % sample name - truncate to 24 and replace offending chars
    this_sample_name = parsed_text{si+ino};
    if length(this_sample_name) > 24; this_sample_name = this_sample_name(1:24); end
    bad_chars = regexp(this_sample_name,'[^\w-]');
    for b = 1:length(bad_chars); this_sample_name(bad_chars(b)) = '-'; end
    % Should be OK now
    
    % Now we check to see if the sample is a duplicate. 
    if isempty(strcmp(this_sample_name,out.sample_name))
        % OK to write an out.s record    
    
        out.s.sample_name{a} = this_sample_name;

        % Scaling fx in position 2 is ignored
        % 3. Latitude
        ino = 3;
        % illegal character test -- 
        % all numerical inputs may contain digits, ., e,E +, -. 
        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable latitude value - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp > 90) || (temp < -90)
                out.error = 1;
                out.message = 'validate_CC_input.m: Sample data block - latitude out of bounds';
                return;
            end
            % Assign
            out.s.lat(a) = temp; clear temp;
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in latitude - line ' int2str(a)];
            return;
        end

        % 4. Longitude

        ino = 4;

        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable longitude value - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp > 360) || (temp < -180)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - longitude out of bounds - line ' int2str(a)];
                return;
            end 
            % Assign
            if temp > 180; temp = temp-360; end
            out.s.long(a) = temp; clear temp;
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in longitude - line ' int2str(a)];
            return; 
        end

        % Elevation/pressure handling
        % Can only use elevation because that's what's supported in CREp
        % First look in element 7 to determine if OK
        % Elevation is item 5 and pressure is item 6

        if strcmp(parsed_text{si+7},'Elevation')
            % Process elevation value
            ino = 5;
            if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
                % Convert to number
                temp = str2double(parsed_text{si+ino});
                % Check that worked
                if isnan(temp)
                    out.error = 1;
                    out.message = ['validate_CC_input.m: Sample data block - un-numericalizable elevation value - line ' int2str(a)];
                    return;
                end
                % test for bounds
                if (temp < 0)
                    out.error = 1;
                    out.message = ['validate_CC_input.m: Sample data block - elevation less than zero - line ' int2str(a)];
                    return;
                end 
                % Assign
                out.s.elv(a) = temp; clear temp;
            else
                % fail
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - illegal characters in elevation - line ' int2str(a)];
                return;
            end
        elseif strcmp(parsed_text{si+7},'Pressure')
            out.error = 1;
            out.message = 'validate_CC_input.m: Can''t accept atmospheric pressure input because it''s unsupported by CREp';
            return;
        else
            out.error = 1;
            out.message = 'validate_CC_input.m: Can only accept ''Elevation'' in position 7 because pressure is unsupported by CREp';
            return;
        end

        % Thickness - item 8

        ino = 8;

        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable thickness value - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - thickness less than zero - line ' int2str(a)];
                return;
            end 
            % Assign
            out.s.thick(a) = temp; clear temp;
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in thickness - line ' int2str(a)];
            return;
        end

        % Shielding - item 10

        ino = 10;

        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable shielding value - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp < 0) || (temp > 1)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - shielding correction out of range - line ' int2str(a)];
                return;
            end 
            % Assign
            out.s.othercorr(a) = temp; clear temp;
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in shielding correction - line ' int2str(a)];
            return;
        end

        % Density - item 9

        ino = 9;

        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable density value - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - density less than zero - line ' int2str(a)];
                return;
            end 
            % Assign
            out.s.rho(a) = temp; clear temp;
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in density - line ' int2str(a)];
            return;
        end

        % Erosion rate - item 11

        ino = 11;

        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable erosion rate value - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - erosion rate less than zero - line ' int2str(a)];
                return;
            end 
            % Assign
            % CC erosion rates are mm/kyr. V3 erosion rates are cm/yr. 
            % mm/kyr * 1e-3 = mm/yr * 1e-1 = cm/yr, so mm/kyr * 1e-4 = cm/yr. 
            out.s.E(a) = temp.*1e-4; clear temp;
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in erosion rate - line ' int2str(a)];
            return;
        end

        % Sample collection year

        if isAlBe
            ino = 18;
        else
            ino = 15;
        end

        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable collection year value - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - collection year less than zero - line ' int2str(a)];
                return;
            end 
            % Assign
            out.s.yr(a) = temp; clear temp;
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in collection year - line ' int2str(a)];
            return;
        end
    end
    
    % End block if executes if sample name is not repeated
    % Always write a nuclide concentration line

    
    if isAlBe
        % Be-10 concentration
        ino = 12;
        
        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable Be-10 concentration - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - Be-10 concentration less than zero - line ' int2str(a)];
                return;
            end 
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in Be-10 concentration - line ' int2str(a)];
            return;
        end
        
        % Be-10 uncertainty
        ino = 27;
        
        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp1 = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp1)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable Be-10 uncertainty - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp1 < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - Be-10 uncertainty less than zero - line ' int2str(a)];
                return;
            end 
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in Be-10 uncertainty - line ' int2str(a)];
            return;
        end
        
        if temp > 0
            out.n.index(end+1) = a;
            out.n.nuclide{end+1} = 'N10quartz';
            this_CF = consts.be_stds_cfs(find(strcmp(parsed_text{13},consts.be_stds_names)));
            if isempty(this_CF)
                out.error = 1;
                out.message = 'validate_CC_input.m: can''t match Be standardization name';
                return;
            end
            out.n.N(end+1) = temp.*this_CF; 
            out.n.delN(end+1) = temp1.*this_CF;
        end
        clear temp temp1
        
        % Now the same for Al-26
        % Al-26 concentration
        ino = 14;
        
        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable Al-26 concentration - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - Al-26 concentration less than zero - line ' int2str(a)];
                return;
            end 
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in Al-26 concentration - line ' int2str(a)];
            return;
        end
        
        % Al-26 uncertainty
        ino = 28;
        
        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp1 = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp1)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable Al-36 uncertainty - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp1 < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - Al-26 uncertainty less than zero - line ' int2str(a)];
                return;
            end 
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in Al-26 uncertainty - line ' int2str(a)];
            return;
        end
        
        if temp > 0
            out.n.index(end+1) = a;
            out.n.nuclide{end+1} = 'N26quartz';
            this_CF = consts.al_stds_cfs(find(strcmp(parsed_text{15},consts.al_stds_names)));
            if isempty(this_CF)
                out.error = 1;
                out.message = 'validate_CC_input.m: can''t match Al standardization name';
                return;
            end
            out.n.N(end+1) = temp.*this_CF; 
            out.n.delN(end+1) = temp1.*this_CF;
        end
        clear temp temp1       
    else
        if strcmp(dtype,'CC3')
            this_nuclide = 'N3pyroxene';
        else
            this_nuclide = 'N14quartz';
        end
        
        % Other nuclide concentration
        ino = 12;
        
        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable nuclide concentration - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - nuclide concentration less than zero - line ' int2str(a)];
                return;
            end 
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in nuclide concentration - line ' int2str(a)];
            return;
        end
        
        % Other nuclide uncertainty
        ino = 24;
        
        if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
            % pass
            % Convert to number
            temp1 = str2double(parsed_text{si+ino});
            % Check that worked
            if isnan(temp1)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - un-numericalizable nuclide uncertainty - line ' int2str(a)];
                return;
            end
            % test for bounds
            if (temp1 < 0)
                out.error = 1;
                out.message = ['validate_CC_input.m: Sample data block - nuclide uncertainty less than zero - line ' int2str(a)];
                return;
            end 
        else
            % fail
            out.error = 1;
            out.message = ['validate_CC_input.m: Sample data block - illegal characters in nuclide uncertainty - line ' int2str(a)];
            return;
        end
        
        if temp > 0
            out.n.index(end+1) = a;
            out.n.nuclide{end+1} = this_nuclide;
            out.n.N(end+1) = temp; 
            out.n.delN(end+1) = temp1;
        end
        clear temp temp1  
    end

    
    
end

out.numnuclides = length(out.n.N);




