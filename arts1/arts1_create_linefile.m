%------------------------------------------------------------------------------
% NAME:     arts1_create_linefile
%
%           Selects transitions to include in a linefile by pure numerical
%           force, using ARTS1 and data from ARTS1_DATA.
%
%           This function performs rather detailed calculations, and can then
%           be relatively slow for molecules with large number of transitions,
%           such as HNO3.
%
%           Everything is specified by a Qarts1 and a configure structure C.
%           These fields are needed:
%
%           Q : Q.Z_PLAT, Q.Z_GROUND, Q.L_STEP, Q.REFR_ON and Q.ZA_PENCIL 
%             The ground is set to have zero emissivity, but it should be 
%             avoided to include ZA_PENCIL's resulting in ground reflections.
%
%           C.MOLECULES : Cell array of strings with names of molecules.
%              Molecules names given in ARTSCAT format (e.g. O3-666).
%           C.BANDDATA : A matrix with three columns. Column 1 gives lower
%              limit for each frequency band to consider. Column2 gives upper
%              frequency limit. Column 3 gives the highest sideband filter 
%              factor inside the band. For a SSB reciever the factor should be
%              1 for primary band, and a low value (such as 0.01) for image
%              bands.
%           C.TB_LIMIT : Brightness temperature threshold. Transitions giving
%              a contribution below this limit are rejected.
%           C.DF_SEARCH : Frequency search range. See further below. Length
%              must match C.MOLECULES, or be 1 when this value is used for all
%              molecules.
%           C.N_TESTATMS : Number of test atmospheres to consider. The 5
%              Fascod atmospheres are used, in order
%                 midlatitude-summer
%                 subarctic-winter
%                 tropical
%                 midlatitude-winter
%                 subarctic-summer
%              Including more test atmospheres gives a more safe search, but
%              longer calculations.
%
%
%           The calculations are done as:
%           1. All transitions of the molecule above min(BANDDATA(:,1:2)-
%              DF_SEARCH and below max(BANDDATA(:,1:2)+DF_SEARCH are loaded.
%           2. For each transition the following is done:
%              a. For each band the frequency closest to the transition is
%                 selected. This is accordingly either and edge, or the
%                 the transition frequency (if inside the band).
%              b. Spectra are calculted for the frequencies from a, for all
%                 combinations of Q.ZA_PENCIL and a first test atmosphere.
%              c. It is checked if any value is >= TB_LIMIT. The spectral
%                 value for each band is multiplied with the sideband filter
%                 factor before the comparison.
%              d. If no value is above TB_LIMIT, b-c is repeated for next test
%                 atmosphere. Otherwise, go to e. 
%              e. If TB_OUT is an output argument, b-c is performed for all
%                 test atmospheres and the maximum value is stored in TB_MAX.
%                 Otherwise, take next transition.
%           3. Points 1-3 are performed for all molecules.
%           
%
% FORMAT:   [L,tb_max] = arts1_create_linefile(Q,C)
%
% OUT:      L        Structure array with line data in ARTSCAT format
%                    (see ARTS_WRITE_LINEFILE).
%           tb_max   Max contribution (in Tb) found, for all 
%                    considered set-up atmospheres.
% IN:       Q        Qarts1 structure. See above.
%           C        Configure structure. See above.
%------------------------------------------------------------------------------

% HISTORY: 2005-03-16  Created by Patrick Eriksson


function [L,tb_max] = arts1_create_linefile(Q,C)


atmlab( 'require', {'ARTS1_DATA_PATH'} );
data_path = atmlab('ARTS1_DATA_PATH');

testatms = { ...
fullfile( data_path, 'atmosphere', 'fascod', 'midlatitude-summer' ), ...
fullfile( data_path, 'atmosphere', 'fascod', 'subarctic-winter' ), ...
fullfile( data_path, 'atmosphere', 'fascod', 'tropical' ), ...
fullfile( data_path, 'atmosphere', 'fascod', 'midlatitude-winter' ), ...
fullfile( data_path, 'atmosphere', 'fascod', 'subarctic-summer' ), ...
};


%=== Check C fields
%
rqre_field( C, 'MOLECULES', 1 );
rqre_datatype( {'cellstr'}, C.MOLECULES );
%
rqre_field( C, 'BANDDATA', 1 );
rqre_datatype( {'matrix'}, C.BANDDATA );
if size(C.BANDDATA,2) ~= 3
  error( 'C.BANDDATA must have 3 columns.' );
end
%
rqre_field( C, 'TB_LIMIT', 1 );
rqre_datatype( {'scalar'}, C.TB_LIMIT );
%
rqre_field( C, 'DF_SEARCH', 1 );
rqre_datatype( {'scalar','vector'}, C.DF_SEARCH );
%
if length(C.DF_SEARCH) == 1
  %
  C.DF_SEARCH = repmat( C.DF_SEARCH, length(C.MOLECULES), 1 );
  %
elseif length(C.DF_SEARCH) ~= length(C.MOLECULES)
  error('Length C.DF_SEARCH must be 1, or match C.MOLECULES.' );
end
%
rqre_field( C, 'N_TESTATMS', 1 );
rqre_datatype( {'scalar'}, C.N_TESTATMS );


%=== Some variables
%
CBGR     = constants( 'CBGR' );
nbands   = size( C.BANDDATA, 1 );
f_mono   = zeros( nbands, 1 );
%
Q.Y_UNIT             = 'RJ';
Q.TGS                = [];
Q.USE_RAW_ATMOSPHERE = 1;
Q.T_GROUND           = 1;
Q.HSE_ON             = 0;


%=== Loop isotopomers
%
L      = cell( 1000, 1 );
nout   = 0;
tb_max = zeros( 1000, 1 );
%
for iso = 1 : length( C.MOLECULES )

  if out(1)
    fprintf('%s\n', C.MOLECULES{iso} );
  end

  %=== Read all transitions inside search range
  %
  lfile = fullfile( atmlab('ARTS1_DATA_PATH'), 'spectroscopy', 'artscat', ...
                                                 [ C.MOLECULES{iso}, '.ac' ] );
  f_search = [ min(C.BANDDATA(:,1))-C.DF_SEARCH(iso);
               max(C.BANDDATA(:,2))+C.DF_SEARCH(iso) ];
  %
  Ltest = arts_read_linefile( lfile, f_search );

  %= Wait bar
  %
  if out(2)
    hbar = waitbar(0,['Doing transitions for ',C.MOLECULES{iso}]); 
  end


  %= Loop transitions
  %
  nlines = length(Ltest);
  %
  for i = 1 : nlines

    Q.LINEFORMAT = 'Arts';
    Q.LINEDATA   = { Ltest{i} };
    Q.TGS{1}{1}  = Ltest{i}.name ;

    f0 = Ltest{i}.f;

    for ib = 1 : nbands
      if f0 <= C.BANDDATA(ib,1)
        f_mono(ib) = C.BANDDATA(ib,1);
      elseif f0 >= C.BANDDATA(ib,2)
        f_mono(ib) = C.BANDDATA(ib,2);
      else
        f_mono(ib) = f0;
      end
    end
    %
    Q.F_MONO   = f_mono;
    Q.E_GROUND = zeros( size(f_mono) );

    %= Loop set-up atmospheres
    %
    saved = 0;
    %
    for ii = 1 : min( [ C.N_TESTATMS, length(testatms) ] );

      Q.APRIORI_VMR = testatms{ii};
      Q.APRIORI_PTZ = [ Q.APRIORI_VMR, '.tz.aa' ];

      %= Run ARTS1 and load spectra
      %
      y = arts1_y( Q );
      %
      Y = reshape( y, length( f_mono ), length( Q.ZA_PENCIL ) );


      %= Remove cosmic backround radiation level
      %
      Y = Y - repmat( i2rayjeanTb( planck(f_mono,CBGR), f_mono ), ...
                                                    1, length( Q.ZA_PENCIL ) );

      tb = max(max(Y')'.*C.BANDDATA(:,3));
      if tb > C.TB_LIMIT
        if ~saved
          nout      = nout + 1;
          if nout > length(L)
            [L,tb_max] = reallocate(L,tb_max);
          end
          L{nout}   = Ltest{i};      
          saved     = 1;
          if nargout == 1
            break;
          end
        end
        if tb > tb_max(nout)
          tb_max(nout) = tb; 
        end
      end
    end

    if out(2)
      waitbar( i/nlines, hbar ); 
    end

  end

  if out(2)  
    delete(hbar);
    drawnow
  end
end


%=== Remove excess part of TB_MAX
%
if nout < length(L)
  L      = L(1:nout);
  tb_max = tb_max(1:nout);
end

return


%------------------------------------------------------------------------------

function [L2,tb_max2] = reallocate(L,tb_max);
  %
  n       = length(L);
  L2      = cell( n+1000, 1 );
  tb_max2 = zeros( n+1000, 1 );
  %
  for i=1:n
    L2{i}      = L{i};
  end
  tb_max2(1:n) = tb_max;
return