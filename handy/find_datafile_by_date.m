function datafile = find_datafile_by_date(datevec, satname, sensor)

% find_datafile_by_date Return full path of datafile by date/time
%
% Returns the full path of the datafile corresponding to the input
% arguments.
%
% Needs paths to datafiles set in colloc_config and assumes datafiles are
% stored in directories per day.
%
% TODO: maybe those paths should be set somewhere else? it 'atmlab'?
%
% FORMAT
%
%   datafile = find_datafile_by_date(datevec, sat, sensor)
%
% IN
%
%   datevec     vector  Date/time to find datafile for
%   satname     string  Name of satellite
%   sensor      string  Name of sensor
%
% OUT
%
%   datafile    string     Path to the looked-for datafile.
%
%
% $Id$

errid = 'atmlab:find_datafile_by_date';

basedir = colloc_config([sensor '_basedir']);
yeardir = colloc_config([sensor '_yeardir']);
yeardir = strrep(yeardir, '$YEAR', num2str(datevec(1)));
yeardir = strrep(yeardir, '$SAT', satname);

datadir = fullfile(basedir, yeardir, num2str(datevec(2), '%02d'), num2str(datevec(3), '%02d'));
granules = find_granules_by_date(datevec(1), datevec(2), datevec(3), satname, sensor);
found = granules(:, 4)==datevec(4) & granules(:, 5)==datevec(5);

% find_granules_by_date returns granules in the order that their files are
% returned by dir, so this is consistent

files = dir(datadir);
file_is_granule = arrayfun(@(x) any(regexp(x.name, colloc_config([sensor '_regexp']))), files);
granule_files = files(file_is_granule);
nfound = length(find(found));
if nfound==0
    error(errid, 'No datafile found for %s %s [%s]', satname, sensor, num2str(datevec));
elseif nfound > 1
    error(errid, 'Multiple datefiles found for %s %s', satname, sensor);
else
    datafile = fullfile(datadir, granule_files(found).name);
end

% % special case: POES has two satnames
% if iscellstr(satname)
%     satnames = satname;
%     satname = satnames{1};
% end
% 
% switch satname
%     case 'cloudsat'
%         % file naming convention: CloudSat Standard Data Products Handbook,
%         % page 15
%         yeardir = fullfile(satname, num2str(year));
%         DOY = dayofyear(year, month, day);
%         substr = sprintf('%04d%03d%02d%02d', ...
%             year, DOY, hour, minute);
%         base = common_base;
%     case cscol('POES')
%         % special case: amsub=mhs
%         if any(strcmp(sensor, {'amsub', 'mhs'}))
%             sensor = amsub_or_mhs(satname);
%         end
%         switch sensor
%             case {'amsua', 'amsub'}
%                 yeardir = fullfile('amsu', ...
%                     [satname '_' sensor '_' num2str(year)]); 
%                 substr = sprintf('.S%02d%02d.', hour, minute);
%                 base = common_base;
%             case {'hirs', 'mhs'}
%                 yeardir = fullfile(sensor, ...
%                     [satname '_' sensor '_' num2str(year)]);
%                 substr = sprintf('.S%02d%02d.', hour, minute);
%                 base = common_base;
%             case 'mspps'
%                 yeardir = fullfile(sensor, ...
%                     [satname '_orbital_' num2str(year)]);
%                 % mspps might start a minute later than the corresponding
%                 % amsub/mhs-file. Therefore, first find that one, then extract the
%                 % unique code.
%                 amsubdir = find_datafile_by_date(year, month, day, hour, minute, ...
%                     satname, amsub_or_mhs(satname));
%                 startpoint = findstr(amsubdir, '.B');
%                 endpoint = startpoint+9;
%                 substr = amsubdir(startpoint:endpoint);
%                 base = common_base;
%             case 'avhrr' % TODO FIXME update when data really available
%                 yeardir = fullfile('avhrr', 'l1b', satname, num2str(year));
%                 substr = sprintf('.S%02d%02d.', hour, minute);
%                 base = local_base;
%             case {'collocation_cloudsat', 'cscolmhs'}
%                 yeardir = num2str(year);
%                 base = cscol('collocation_base');
%                 substr = sprintf(cscol('collocation_filename'), satname);
%             case 'collocation_cloudsat_data'
%                 yeardir = num2str(year);
%                 base = cscol('collocation_base');
%                 substr = sprintf(cscol('collocation_data_filename'), satname);
%             case 'collocation_cloudsat_meandata'
%                 yeardir = num2str(year);
%                 base = cscol('collocation_base');
%                 substr = sprintf(cscol('collocation_meandata_filename'), satname);
%             case {'collocation_poes', 'collocation_poes_data'} % in this case, need /two/ satellite names
%                 primary = satnames{1};
%                 secondary = satnames{2};
%                 yeardir = num2str(year);
%                 base = cscol('collocation_poes_base');
%                 substr = sprintf(cscol([sensor '_filename']), primary, secondary);
%             case 'cscolavhrr'
%                 datafile = filename_cscolmhs_avhrr(2009, 1, 23, 'noaa18', 'noaa18');
%                 return
%             otherwise
%                 error(errid, 'Unknown sensor: %s', sensor);
%         end % switch
%     otherwise
%         error(errid, 'Unknown satellite: %s', satname);
% end % switch
% 
% datadir = sprintf('%s/%s/%02d/%02d', base, yeardir, month, day);
% files = dir(datadir);
% found = arrayfun(@(v) any(strfind(v.name, substr)), files);
% nfound = length(find(found));
% if nfound==0
%     error(errid, 'No datafile found');
% elseif nfound > 1
%     error(errid, 'Multiple datefiles found for %s %s', satname, sensor);
% else
%     datafile = fullfile(datadir, files(found).name);
% end
