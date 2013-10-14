%%
setpref('Internet','E_mail','bryant@broadcom.com');
% setpref('Internet','SMTP_Server', 'outlook.sj.broadcom.com');
setpref('Internet','SMTP_Username','bryant@broadcom.com');
setpref('Internet','SMTP_Password','Tango224');
setpref('Internet','SMTP_Server','mail');

%%
sendmail('bryant@broadcom.com', 'Hello From MATLAB!');