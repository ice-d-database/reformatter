function out = validate_CREp_input(text_block,nuclide)

% Validates data supplied in CREp format. 

% Version
out.version_validate = 'validate_CREp_input.m - 0.1-dev';
out.error = 0;
out.message = '';

% CREp input format has 10 elements, so this must be a multiple of 10. 

% Parse into non-white-space elements

parsed_text = textscan(text_block,'%s');
parsed_text = parsed_text{1}; % Peculiarity of textscan

% Now a text array called parsed_text contains all the 
% separate items from the text block as array elements.
numitems = length(parsed_text);

% Here define the correct number of items per row -- 
numcols = 10;

if mod(numitems,numcols) ~= 0
    out.error = 1;
    out.message = 'Expected 10 items per line for CREp input and got something different';
    return;
end

% if it passed that, break into lines
numlines = numitems./numcols;

out.numsamples = numlines; out.numnuclides = numlines;

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


% Initialize nuclide data structure. For CREP input this will always have
% the same number of items as the s structure. 
out.n.index = out.s.lat; % Field indexing nuclide measurement to sample number
out.n.nuclide = out.s.sample_name; % Nuclide/target identifier
out.n.N = out.s.lat; % Properly standardized nuclide concentration
out.n.delN = out.s.lat; % Same, uncertainty in

for a = 1:numlines
    si = (a-1)*numcols;
    ino = 1;
    % sample name
    this_sample_name = parsed_text{si+ino};
    if length(this_sample_name) > 24; this_sample_name = this_sample_name(1:24); end
    bad_chars = regexp(this_sample_name,'[^\w-]');
    for b = 1:length(bad_chars); this_sample_name(bad_chars(b)) = '-'; end
    % Should be OK now
    out.s.sample_name{a} = this_sample_name;
    
    ino = 2;
	
	% illegal character test -- 
	% all numerical inputs may contain digits, ., e,E +, -. 
	if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
		% pass
        % Convert to number
        temp = str2double(parsed_text{si+ino});
        % Check that worked
		if isnan(temp)
            out.error = 1;
			out.message = ['validate_CREp_input.m: Sample data block - un-numericalizable latitude value - line ' int2str(a)];
            return;
        end
		% test for bounds
		if (temp > 90) || (temp < -90);
            out.error = 1;
    		out.message = 'validate_CREp_input.m: Sample data block - latitude out of bounds';
            return;
        end
		% Assign
		out.s.lat(a) = temp; clear temp;
    else
		% fail
        out.error = 1;
		out.message = ['validate_CREp_input.m: Sample data block - illegal characters in latitude - line ' int2str(a)];
        return;
    end
    
    % 3. Longitude
	
	ino = 3;
	
	if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
		% pass
        % Convert to number
        temp = str2double(parsed_text{si+ino});
        % Check that worked
        if isnan(temp)
            out.error = 1;
			out.message = ['validate_CREp_input.m: Sample data block - un-numericalizable longitude value - line ' int2str(a)];
            return;
        end
		% test for bounds
		if (temp > 180) || (temp < -180);
            out.error = 1;
    		out.message = ['validate_CREp_input.m: Sample data block - longitude out of bounds - line ' int2str(a)];
            return;
        end 
		% Assign
		out.s.long(a) = temp; clear temp;
    else
		% fail
        out.error = 1;
		out.message = ['validate_CREp_input.m: Sample data block - illegal characters in longitude - line ' int2str(a)];
        return;
    end

    % 4. Elv/pressure
	
	ino = 4;
	
	if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
		% pass
        % Convert to number
        temp = str2double(parsed_text{si+ino});
        % Check that worked
        if isnan(temp)
            out.error = 1;
			out.message = ['validate_CREp_input.m: Sample data block - un-numericalizable elevation/pressure value - line ' int2str(a)];
            return;
        end
		% test for bounds
        if (temp < -500)
            out.error = 1;
            out.message = ['validate_CREp_input.m: Sample data block - elevation too low -- line ' int2str(a)];
            return;
        end 
        out.s.elv(a) = temp;
        clear temp;
    else
		% fail
        out.error = 1;
		out.message = ['validate_CREp_input.m: Sample data block - illegal characters in elevation/pressure - line ' int2str(a)];
        return;
    end
        
    % 9. Thickness
	
	ino = 9;
	
	if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
		% Convert to number
        temp = str2double(parsed_text{si+ino});
        % Check that worked
        if isnan(temp)
            out.error = 1;
			out.message = ['validate_CREp_input.m: Sample data block - un-numericalizable thickness value - line ' int2str(a)];
            return;
        end
		% test for bounds
		if (temp < 0)
            out.error = 1;
    		out.message = ['validate_CREp_input.m: Sample data block - thickness less than zero - line ' int2str(a)];
            return;
        end 
		% Assign
		out.s.thick(a) = temp; clear temp;
    else
		% fail
        out.error = 1;
		out.message = ['validate_CREp_input.m: Sample data block - illegal characters in thickness - line ' int2str(a)];
        return;
    end
	
	% 8. Density
	
	ino = 8;
	
	if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
		% pass
        % Convert to number
        temp = str2double(parsed_text{si+ino});
        % Check that worked
        if isnan(temp)
            out.error = 1;
			out.message = ['validate_CREp_input.m: Sample data block - un-numericalizable density value - line ' int2str(a)];
            return;
        end
		% test for bounds
		if (temp < 0)
            out.error = 1;
            out.message = ['validate_CREp_input.m: Sample data block - density less than zero - line ' int2str(a)];
            return;
        end 
		% Assign
		out.s.rho(a) = temp; clear temp;
    else
		% fail
        out.error = 1;
        out.message = ['validate_CREp_input.m: Sample data block - illegal characters in density - line ' int2str(a)];
        return;
    end
	
	% 7. Shielding
	
	ino = 7;
	
	if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
		% pass
        % Convert to number
        temp = str2double(parsed_text{si+ino});
        % Check that worked
        if isnan(temp)
            out.error = 1;
			out.message = ['validate_CREp_input.m: Sample data block - un-numericalizable shielding value - line ' int2str(a)];
            return;
        end
		% test for bounds
		if (temp < 0) || (temp > 1)
            out.error = 1;
            out.message = ['validate_CREp_input.m: Sample data block - shielding correction out of range - line ' int2str(a)];
            return;
        end 
		% Assign
		out.s.othercorr(a) = temp; clear temp;
    else
		% fail
        out.error = 1;
        out.message = ['validate_CREp_input.m: Sample data block - illegal characters in shielding correction - line ' int2str(a)];
        return;
    end
	
	
	% 10. Erosion rate
	
    ino = 10;

    if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
        % pass
        % Convert to number
        temp = str2double(parsed_text{si+ino});
        % Check that worked
        if isnan(temp)
            out.error = 1;
            out.message = ['validate_CREp_input.m: Sample data block - un-numericalizable erosion rate value - line ' int2str(a)];
            return;
        end
        % test for bounds
        if (temp < 0)
            out.error = 1;
            out.message = ['validate_CREp_input.m: Sample data block - erosion rate less than zero - line ' int2str(a)];
            return;
        end 
        % Assign
        out.s.E(a) = temp; clear temp;
    else
        % fail
        out.error = 1;
        out.message = ['validate_CREp_input.m: Sample data block - illegal characters in erosion rate - line ' int2str(a)];
        return;
    end

	
    % Also put default sample collection date in structure
    
    out.s.yr(a) = 2020;
    
    % Now nuclide concentrations
    
    % 5. N
	
	ino = 5;
	
	if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
		% pass
        % Convert to number
        temp = str2double(parsed_text{si+ino});
        % Check that worked
        if isnan(temp)
            out.error = 1;
			out.message = ['validate_CREp_input.m: Sample data block - un-numericalizable nuclide concentration - line ' int2str(a)];
            return;
        end
		% test for bounds
		if (temp < 0)
            out.error = 1;
    		out.message = ['validate_CREp_input.m: Sample data block - nuclide concentration less than zero - line ' int2str(a)];
            return;
        end 
        
        out.n.index(a) = a;
        out.n.nuclide{a} = nuclide;
        out.n.N(a) = temp; 
        clear temp;
    else
		% fail
        out.error = 1;
		out.message = ['validate_CREp_input.m: Sample data block - illegal characters in nuclide concentration - line ' int2str(a)];
        return;
    end
    
    % 6. delN
	
	ino = 5;
	
	if isempty(regexp(parsed_text{si+ino},'[^\d.eE+-]','once'))
		% pass
        % Convert to number
        temp = str2double(parsed_text{si+ino});
        % Check that worked
        if isnan(temp)
            out.error = 1;
			out.message = ['validate_CREp_input.m: Sample data block - un-numericalizable nuclide concentration uncertainty - line ' int2str(a)];
            return;
        end
		% test for bounds
		if (temp < 0)
            out.error = 1;
    		out.message = ['validate_CREp_input.m: Sample data block - nuclide concentration uncertainty less than zero - line ' int2str(a)];
            return;
        end 
        
        out.n.delN(a) = temp; 
        clear temp;
    else
		% fail
        out.error = 1;
		out.message = ['validate_CREp_input.m: Sample data block - illegal characters in nuclide concentration uncertainty - line ' int2str(a)];
        return;
    end
   
end
    
