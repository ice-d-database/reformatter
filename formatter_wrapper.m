function out = formatter_wrapper(in)


% This is the wrapper script for the format reformatter.
% Copyright: Greg Balco
% June, 2026
% Not licensed for use or distribution. 
% 
% form inputs should be in.text_block and in.inputFormat
% returns HTML



% Need path to v3 stuff

isOctave = 0;
if exist('OCTAVE_VERSION','builtin') > 0
    newline = "\n";
    isOctave = 1;
    path(path,'/var/www/html/math/v3');
    path(path,'/var/www/html/math/Cl36/v3');
else
    path(path,'~/sw/calcs_v3/v3/core');
    path(path,'~/sw/calcs_v3/Cl36/webcore');
end


versions.formatter_wrapper = '0.1-dev';

% Validate input type selection

possible_types = {'v3','CREP10','CREP3','CC1026','CC3','CC14','v3Cl36','CREP36','CC36'};
if any(strcmp(in.inputFormat,possible_types))
    % ok, passes
else
    out = dump_error_HTML('Not a valid input format descriptor');
    return
end

% Now proceed based on what type it is

if strcmp(in.inputFormat,'v3')
    vin = validate_v3_input(in.text_block);
    if vin.error == 1
        out = dump_error_HTML(vin.message);
        return
    end
    out = formatter_from_v3(vin,in.text_block,versions);
    
elseif strcmp(in.inputFormat,'CREP10') || strcmp(in.inputFormat,'CREP3')
    if strcmp(in.inputFormat,'CREP10')
        vin = validate_CREp_input(in.text_block,'N10quartz');
    elseif strcmp(in.inputFormat,'CREP3')
        vin = validate_CREp_input(in.text_block,'N3pyroxene');
    end
    out = formatter_from_CREp(vin,in.text_block,versions);
    
elseif strcmp(in.inputFormat,'CC1026')
    %vin = validate_CC_input(in.text_block,'N10N26');
    %out = formatter_from_CC(vin,in.text_block,versions);
    out = dump_error_HTML('Reformatting from CRONUSCalc not supported yet');
    
elseif strcmp(in.inputFormat,'CC3') || strcmp(in.inputFormat,'CC14')
    if strcmp(in.inputFormat,'CC3')
        %vin = validate_CC_input(in.text_block,'N3pyroxene');
    elseif strcmp(in.inputFormat,'CC14')
        %vin = validate_CC_input(in.text_block,'N14quartz');
    end
    % out = formatter_from_CC(vin,text_block,versions);
    out = dump_error_HTML('Reformatting from CRONUSCalc not supported yet');
    
elseif strcmp(in.inputFormat,'v3Cl36')
    vin = validate_v3_Cl36(in.text_block);
    if vin.error == 1
        out = dump_error_HTML(vin.message);
        return
    end
    out = dump_error_HTML('Cl-36 not supported yet');
    
elseif strcmp(in.inputFormat,'CREP36')
    out = dump_error_HTML('Cl-36 not supported yet');
    
elseif strcmp(in.inputFormat,'CC36')
    out = dump_error_HTML('Cl-36 not supported yet');
    
end
    

