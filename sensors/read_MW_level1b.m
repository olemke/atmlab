
% function to read MW level 1b data. It automatically decides whether to
% use the l1b-record reader for AMSUB, MHS or SSMT2.


function [hdrinfo_out, data_out] = read_MW_level1b(file)
startline=1;

if ~isempty(strfind(file,'mhs'))
    [hdrinfo,data,err] = read_MHS_allvar(file,startline);
        if err==1 
            disp('Error while reading L1b file.') 
            hdrinfo_out= [];
            data_out=[];
            return
        end
        
        data_out=data;
        hdrinfo_out=hdrinfo;
        data_out.time=data.scan_line_UTC_time;
        
%         data_out.time=data.scan_line_UTC_time;
%         data_out.STX_1_status=logical(data.STX_1_status);
%         data_out.STX_2_status=logical(data.STX_2_status);
%         data_out.STX_3_status=logical(data.STX_3_status);
%         data_out.STX_4_status=logical(data.STX_4_status);
%         data_out.SARR_A_power=data.SARR_A_power;
%         data_out.SARR_B_power=data.SARR_B_power;
        
elseif ~isempty(strfind(file,'amsub'))
    [hdrinfo,data,err] = read_AMSUB_allvar(file,startline);
        if err==1 
            disp('Error while reading L1b file.') 
            hdrinfo_out= [];
            data_out=[];
            return
        end
        
        data_out=data;
        hdrinfo_out=hdrinfo;
        data_out.time=data.scan_line_UTC_time;
        
%         data_out.time=data.scan_line_UTC_time;
%         data_out.STX_1_status=logical(data.STX_1_status);
%         data_out.STX_2_status=logical(data.STX_2_status);
%         data_out.STX_3_status=logical(data.STX_3_status);
%         data_out.STX_4_status=logical(data.STX_4_status);
%         data_out.SARR_A_power=data.SARR_A_power;
%         data_out.SARR_B_power=data.SARR_B_power;
        
elseif ~isempty(strfind(file,'ssmt2'))
    [hdrinfo,data,err] = read_SSMT2_allvar(file); 
        if err==1 
            disp('Error while reading L1b file.')  
            hdrinfo_out= [];
            data_out=[];
            return
        end
        data_out=data;
        hdrinfo_out=hdrinfo;
        data_out.time=data.scan_line_UTC_time;
else
    disp('read_MW_level1b: I cannot identify the instrument!')

end
