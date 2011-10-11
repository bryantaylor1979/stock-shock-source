function [string,status] = urlread2(urlChar,method,params,timeout);
% =========================================================================
% timeout: the reqest will be stop at a time you specified.
%
% An enhancement of urlread and all the modifications are labeled with (*)
% Fu-Sung Wang, 13-Sep-2005
% =========================================================================

%URLREAD Returns the contents of a URL as a string.
%   S = URLREAD('URL') reads the content at a URL into a string, S.  If the
%   server returns binary data, the string will contain garbage.
%
%   S = URLREAD('URL','method',PARAMS) passes information to the server as
%   part of the request.  The 'method' can be 'get', or 'post' and PARAMS is a 
%   cell array of param/value pairs.
%
%   [S,STATUS] = URLREAD(...) catches any errors and returns 1 if the file
%   downloaded successfully and 0 otherwise.
%
%   Examples:
%   s = urlread('http://www.mathworks.com');
%   s = urlread('ftp://ftp.mathworks.com/pub/pentium/Moler_1.txt')
%   s = urlread('file:///C:\winnt\matlab.ini')
% 
%   From behind a firewall, use the Preferences to set your proxy server.
%
%   See also URLWRITE.

%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $ $Date: 2004/12/27 23:33:06 $

% This function requires Java.
if ~usejava('jvm')
   error('MATLAB:urlread:NoJvm','URLREAD requires Java.');
end

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Check number of inputs and outputs.
%% (*) 
error(nargchk(1,4,nargin))                    % error(nargchk(1,3,nargin))
error(nargoutchk(0,2,nargout))

%% (*) 
% if (nargin > 1) && ~strcmpi(method,'get') && ~strcmpi(method,'post')
%     error('MATLAB:urlread:InvalidInput','Second argument must be either "get" or "post".');
% end

% Do we want to throw errors or catch them?
if nargout == 2
    catchErrors = true;
else
    catchErrors = false;
end

% Set default outputs.
string = '';
status = 0;

% GET method.  Tack param/value to end of URL.
if (nargin > 1) && strcmpi(method,'get')
    if mod(length(params),2) == 1
        error('MATLAB:urlread:InvalidInput','Invalid parameter/value pair arguments.');
    end
    for i=1:2:length(params)
        if (i == 1), separator = '?'; else, separator = '&'; end
        param = char(java.net.URLEncoder.encode(params{i}));
        value = char(java.net.URLEncoder.encode(params{i+1}));
        urlChar = [urlChar separator param '=' value];
    end
end

% Try to use the native handler, not the ice.* classes.
if strncmpi('http:',urlChar,5)
    try
        handler = sun.net.www.protocol.http.Handler;
    catch
        handler = [];
    end
else
    handler = [];
end

% Create the URL object.
try
    if isempty(handler)
        url = java.net.URL(urlChar);
    else
        url = java.net.URL([],urlChar,handler);
    end
catch
    if catchErrors, return
    else error('MATLAB:urlread:InvalidUrl','Either this URL could not be parsed or the protocol is not supported.',catchErrors);
    end
end



% Open a connection to the URL.
urlConnection = url.openConnection;

%% (*) 
urlConnection.setReadTimeout(timeout);

% POST method.  Write param/values to server.
if (nargin > 1) && strcmpi(method,'post')
    try
        urlConnection.setDoOutput(true);
        urlConnection.setRequestProperty( ...
            'Content-Type','application/x-www-form-urlencoded');
        printStream = java.io.PrintStream(urlConnection.getOutputStream);
        for i=1:2:length(params)
            if (i > 1), printStream.print('&'); end
            param = char(java.net.URLEncoder.encode(params{i}));
            value = char(java.net.URLEncoder.encode(params{i+1}));
            printStream.print([param '=' value]);
        end
        printStream.close;
    catch
        if catchErrors, return
        else error('MATLAB:urlread:ConnectionFailed','Could not POST to URL.');
        end
    end
end

% Read the data from the connection.
try
    inputStream = urlConnection.getInputStream; 
    byteArrayOutputStream = java.io.ByteArrayOutputStream;
    % This StreamCopier is unsupported and may change at any time.
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    isc.copyStream(inputStream,byteArrayOutputStream);
    inputStream.close;
    byteArrayOutputStream.close;
    string = char(byteArrayOutputStream.toByteArray');
catch
    if catchErrors, return
    else error('MATLAB:urlread:ConnectionFailed','Error downloading URL.');
    end
end

status = 1;
