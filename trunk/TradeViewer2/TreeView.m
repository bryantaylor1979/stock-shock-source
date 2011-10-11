classdef TreeView
    properties
        InstallDir = 'C:\HmSourceSafe\Stocks & Shares\Programs\TradeViewer2\';
        RootImage = 'dsRoot.gif';
    end
    methods
        function [obj] = TreeView()
            obj = obj.CreateFigure;
        end
        function obj = CreateFigure(obj)
            Struct.Indices.Bank.TSB = [];
            Struct.Indices.Bank.RBS = [];
            
            % Main Figure
            h.figure = figure(  'ToolBar','none', ...
                                'Name','Instrument Explorer', ...
                                'NumberTitle','off', ...
                                'Resize','off', ...
                                'MenuBar','none');
                            
            Position = get(h.figure,'Position');
            Position(3) = 204;
            Position(4) = 420;
            set(h.figure,   'Position', Position);
                   
            % Toolbar
            h.toolbar = uitoolbar(h.figure);
            image = imread([obj.InstallDir,'Icons\Graph.png']);
            image = imresize(image,[16, 16]);
            htt = uipushtool(h.toolbar, 'CData', image, ...
                                        'TooltipString','Plot Data', ...
                                        'ClickedCallback',{@obj.PlotGraph,h} ...
                                        );

            % Tree Nodes
            CurDir = obj.InstallDir;
            cd([obj.InstallDir,'Icons\'])
            root = uitreenode(1,'Instruments', obj.RootImage, false);
            h.treeview = uitree('Root', root, ...
                                'ExpandFcn', {@obj.Expfcn,Struct,h}, ...
                                'SelectionChangeFcn', {@obj.SelectionCh,h}, ...
                                'Position',[2 2 202 419]);
            cd(CurDir);
        end
        function nodes = Expfcn(obj, tree, value, struct,h)
            %%
            CurDir = obj.InstallDir;
            [map] = obj.ReadMap();

            groupnames = map.groupnames;
            [x,y] = size(groupnames);
            set(h.figure,'UserData',value);

            cd([obj.InstallDir,'Icons\'])
            if value == 1
                for i = 1:y
                nodes(i) = uitreenode(i/10+2,[groupnames{i}], 'dsParent.gif', false);
                end
            end
            % 
            if floor(value) == 2
                value = int8((value-2)*10);
                groupname = groupnames{value};
                table = map.table;
                n = find(strcmpi(table(:,1),groupname));
                grouptable = table(n,:);
                [x] = size(grouptable,1);
                for i = 1:x
                    nodes(i) = uitreenode('', [grouptable{i,2},' (',grouptable{i,3},')'], 'dsChild.gif', true);
                end
            end
            cd(CurDir)
        end
        function [] = SelectionCh(obj,dummy,node,h)
            % During a selection change, note the selected node into the
            % figure. 
            disp('Selection Change')
            CurrentNode = get(node,'CurrentNode');
            Name = get(CurrentNode,'name');
            n = findstr(Name,'(');
            Name = strrep(Name(1:n-1),' ','');

            struct.Symbol = Name;

            [map] = obj.ReadMap();
            table = map.table;
            n = find(strcmpi(struct.Symbol,table(:,2)));
            if isempty(n)

            else
            struct.Name = table{n,3};
            end
            set(h.figure,'UserData',struct);
        end
        function [] = PlotGraph(varargin)
            obj = varargin{1};
            h = varargin{4};
            struct = get(h.figure,  'UserData');

            [date, close, open, low, high, volume, closeadj] = sqq(struct.Symbol,365);
            MaxVal = max(open);
            MinVal = min(open);
            PotentialMarker = MaxVal/MinVal;

            h1 = figure;
            plot(date,open,'r');
            set(h1,'Visible','off');
            datetick;
            xlabel({'Date';['Potential Marker: ',num2str(PotentialMarker)]});
            ylabel('Price');
            title([struct.Symbol,' ',struct.Name]);

            set(h1, 'Name',[struct.Symbol,' ',struct.Name], ...
                    'MenuBar','none', ...
                    'NumberTitle','off');

            set(h1,'Visible','on');
        end
        function [map] = ReadMap(obj)
            map.table = { ...
                'SuperSectorIndices',   '^FTUB8300',        'Banks'; ...
                'SuperSectorIndices',   '^FTUB1300',        'Chemicals'; ...
                'SuperSectorIndices',   '^FTUB2300',        'Construction & Materials'; ...
                'SuperSectorIndices',   '^FTUB8700',        'Financial Services'; ...
                'SuperSectorIndices',   '^FTUB3500',        'Food & Beverage'; ...
                'SuperSectorIndices',   '^FTUB4500',        'Health Care'; ...  
                'SuperSectorIndices',   '^FTUB2700',        'Industrial Goods & Services'; ...
                'SuperSectorIndices',   '^FTUB8500',        'Insurance'; ... 
                'SuperSectorIndices',   '^FTUB5500',        'Media'; ...
                'SuperSectorIndices',   '^FTUB3700',        'Personal & Household Goods'; ...
                'SuperSectorIndices',   '^FTUB5300',        'Retail'; ...
                'SuperSectorIndices',   '^FTUB9500',        'Technology'; ...
                'SuperSectorIndices',   '^FTUB6500',        'Telecommunications'; ...
                'SuperSectorIndices',   '^FTUB5700',        'Travel & Leisure'; ...
                'SuperSectorIndices',   '^FTUB7500',        'Utilities'; ...
                'SuperSectorIndices',   '^FTAD'    ,        'Aerospace and Defence'; ...
                'SuperSectorIndices',   '^FTAM'    ,        'Automobiles'; ...
                'SuperSectorIndices',   '^FTBK'    ,        'Banks'; ...
                'SuperSectorIndices',   '^FTDN'    ,        'Beverages'; ...
                'SuperSectorIndices',   '^FTCH'    ,        'Chemicals'; ...
                'SuperSectorIndices',   '^FTBM'    ,        'Construction'; ...
                'SuperSectorIndices',   '^LCFR'    ,        'Distributors'; ...
                'SuperSectorIndices',   '^FTEY'    ,        'Electricity'; ...
                'SuperSectorIndices',   '^FTEN'    ,        'Engineering'; ...
                'SuperSectorIndices',   '^FTFM'    ,        'Food Processing'; ...
                'SuperSectorIndices',   '^FTFR'    ,        'Food and Drink'; ...
                'FTUB8300',             'GB0001452795.L',   'Nothern Rock'; ...
                'FTUB8300',             'ALFF.L',           'Allinance & Leicster'; ...
                'FTUB8300',             'RBS.L',            'Royal Bank Of Scotland'; ...
                'FTUB8300',             'BB.L',             'Bradford & Bingley'; ...
                'FTUB8300',             'LLOY.L',           'LLoyds TSB'; ...
                'FTUB8300',             'STAN.L',           'Standard Chartered'; ...
                'FTUB8300',             'HBOS.L',           'HBOS'; ...
                'FTUB8300',             'BARC.L',           'Barclays'; ...
                'FTUB8300',             'HSBA.L',           'HSBC HLDG'; ...
                'MERV',                 'ACIN.BA',          'ACINDAR-ESCRITURALES'; ... 
                'MERV',                 'ALPA.BA',          'ALPARGATAS'; ...
                'MERV',                 'ALUA.BA',          'ALUAR ALUMINIO ARGENTINO'; ...
                'MERV',                 'APBR.BA',          'PETROBRAS ORDINARIAS' ; ...
                'MERV',                 'BHIP.BA',          'BANCO HIPOTECARIO' ; ...
                'MERV',                 'BMA.BA',           'BMACRO-ACCS.ORDS.' ; ...
                'MERV',                 'BPAT.BA',          'BANCO PATAGONIA'; ...
                'MERV',                 'CELU.BA',          'CELULOSA-ESCRITURALES'; ...
                'MERV',                 'COME.BA',          'COMERCIAL DEL PLATA'; ...
                'MERV',                 'CRES.BA',          'CRESUD'; ...
                'MERV',                 'ERAR.BA',          'SIDERAR'; ...
                'MERV',                 'FRAN.BA',          'BCO.FRANCES S.A.-ESCRITUR'; ...
                'MERV',                 'GCLA.BA',          'GRUPO CLARIN SA ARS1 CLS'; ...
                'MERV',                 'GGAL.BA',          'GRUPO FINANCIERO GALICIA'; ...
                'MERV',                 'INDU.BA',          'SOLVAY INDUPA-ESCRITURALE'; ...
                'MERV',                 'IRSA.BA',          'IRSA-ESC.ORDS.'; ...
                'MERV',                 'LEDE.BA',          'LEDESMA '; ...
                'MERV',                 'MIRG.BA',          'MIRGOR -ORD.ESC.'; ...
                'MERV',                 'MOLI.BA',          'MOLINOS RIO DE LA PLATA'; ...
                'MERV',                 'PAMP.BA',          'FRIGORIFICO LA PAMPA'; ...
                'MERV',                 'PATY.BA',          'QUICKFOOD'; ...
                'MERV',                 'PBE.BA',           'PETROBRAS ENERGIA PARTI'; ...
                'MERV',                 'STHE.BA',          'SOCOTHERM AMERICAS'; ...
                'MERV',                 'TECO2.BA',         'TELECOM ARGENTINA'; ...
                'MERV',                 'TGSU2.BA',         'TRANSPORTADORA DE GAS'; ...
                'MERV',                 'TRAN.BA',          'CIA.TRANSP.EN.ELEC.EN ALT'; ...
                'MERV',                 'TS.BA',            'TENARIS-ESCRITURALES' ; ...
                'MERV',                 'YPFD.BA',          'YPF'; ...
                'MarketIndices',        '^FTMC' ,           'FTSE ACT 250'; ...
                'MarketIndices',        '^FTSE' ,           'FTSE 100'; ...
                'MarketIndices',        '^FTAS' ,           'FTSE ALL-SHARE'; ...
                'MarketIndices',        '^FTAI' ,           'FTSE AIM INDEX'; ...
                'MarketIndices',        '^DJI'  ,           'Dow Jones Industrial Average'; ...
                'MarketIndices',        '^IXIC' ,           'NASDAQ Composite'; ...
                'MarketIndices',        '^GDAXI',           'DAX'; ...
                'MarketIndices',        '^STOXX50E',        'DJ EURO STOXX 50'; ...
                'MarketIndices',        '^DJA',             'Dow Jones Composite Average'; ...
                'MarketIndices',        '^DJI',             'Dow Jones Industrial Average'; ...
                'MarketIndices',        '^DJT',             'Dow Jones Transportation Average'; ...
                'MarketIndices',        '^DJU',             'Dow Jones Utility Average'; ...
                'MarketIndices',        '^MERV',            'Merval Buenos Aires'; ...
                'MarketIndices',        '^BVSP',            'Bovespa'; ...
                'MarketIndices',        '^GSPTSE',          'S&P TSX Composite'; ...
                'MarketIndices',        '^MXX',             'IPC'; ...
                'MarketIndices',        '^GSPC',            '500 Index'; ...
                '^GSPTSE',              'ABX.TO',           ''; ...
                '^GSPTSE',              'ACE-B.TO',         ''; ...
                '^GSPTSE',              'ACM-A.TO',         ''; ...
                '^GSPTSE',              'ACO-X.TO',         ''; ...
                '^GSPTSE',              'AEM.TO',           ''; ...
                '^GSPTSE',              'AER.TO',           ''; ...
                '^GSPTSE',              'AET-UN.TO',        ''; ...
                '^GSPTSE',              'AGF-B.TO',         ''; ...
                '^GSPTSE',              'AGI.TO',           ''; ...
                '^GSPTSE',              'AGU.TO',           ''; ...
                '^GSPTSE',              'ALA-UN.TO',        ''; ...
                '^GSPTSE',              'APF-UN.TO',        ''; ...
                '^GSPTSE',              'ARE.TO',           ''; ...
                '^GSPTSE',              'ATD-B.TO',         ''; ...
                '^GSPTSE',              'AVM.TO',           ''; ...
                '^GSPTSE',              'AVN-UN.TO',        ''; ...
                '^GSPTSE',              'AXC.TO',           ''; ...
                '^GSPTSE',              'BA-UN.TO',         ''; ...
                '^GSPTSE',              'BAM-A.TO',         ''; ...
                '^GSPTSE',              'BBD-B.TO',         ''; ...
                '^GSPTSE',              'BCE.TO',           ''; ...
                '^GSPTSE',              'BEI-UN.TO',        ''; ...
                '^GSPTSE',              'BFC.TO',           ''; ...
                '^GSPTSE',              'BIR.TO',           ''; ...
                '^GSPTSE',              'BMO.TO',           ''; ...
                '^GSPTSE',              'BNK.TO',           ''; ...
                '^GSPTSE',              'BNP-UN.TO',        ''; ...
                '^GSPTSE',              'BNS.TO',           ''; ...
                '^GSPTSE',              'BPO.TO',           ''; ...
                '^GSPTSE',              'BTE-UN.TO',        ''; ...
                '^GSPTSE',              'BVF.TO',           ''; ...
                '^GSPTSE',              'CAE.TO',           ''; ...
                '^GSPTSE',              'CAR-UN.TO',        ''; ...
                '^GSPTSE',              'CAS.TO',           ''; ...
                '^GSPTSE',              'CCA.TO',           ''; ...
                '^GSPTSE',              'CCL-B.TO',         ''; ...
                '^GSPTSE',              'CCO.TO',           ''; ...
                '^GSPTSE',              'CFP.TO',           ''; ...
                '^GSPTSE',              'CFW.TO',           ''; ...
                '^GSPTSE',              'CGX-UN.TO',        ''; ...
                '^GSPTSE',              'CIX-UN.TO',        ''; ...
                '^GSPTSE',              'CJR-B.TO',         ''; ...
                '^GSPTSE',              'CLC-UN.TO',        ''; ...
                '^GSPTSE',              'CLL.TO',           ''; ...
                '^GSPTSE',              'CLS.TO',           ''; ...
                '^GSPTSE',              'CM.TO',            ''; ...
                '^GSPTSE',              'CMT.TO',           ''; ...
                '^GSPTSE',              'CNQ.TO',           ''; ...
                '^GSPTSE',              'CNR.TO',           ''; ...
                '^GSPTSE',              'COM.TO',           ''; ...
                '^GSPTSE',              'COS-UN.TO',        ''; ...
                '^GSPTSE',              'ABX.TO',           ''; ...
                '^GSPTSE',              'COS-UN.TO',        ''; ...
                '^GSPTSE',              'CP.TO',            ''; ...
                '^GSPTSE',              'CPG-UN.TO',         ''; ...
                '^GSPTSE',              'CR.TO',           ''; ...
                '^GSPTSE',              'CSH-UN.TO',           ''; ...
                '^GSPTSE',              'CTC-A.TO',           ''; ...
                '^GSPTSE',              'CU.TO',           ''; ...
                '^GSPTSE',              'CUF-UN.TO',           ''; ...
                '^GSPTSE',              'CWB.TO',           ''; ...
                '^GSPTSE',              'CWI-UN.TO',           ''; ...
                '^GSPTSE',              'CWT-UN.TO',           ''; ...
                '^GSPTSE',              'D-UN.TO',           ''; ...
                '^GSPTSE',              'DAY-UN.TO',           ''; ...
                '^GSPTSE',              'DC-A.TO',           ''; ...
                '^GSPTSE',              'DHF-UN.TO',           ''; ...
                '^GSPTSE',              'DII-B.TO',           ''; ...
                '^GSPTSE',              'DML.TO',           ''; ...
                '^GSPTSE',              'DW.TO',           ''; ...
                '^GSPTSE',              'ECA.TO',           ''; ...
                '^GSPTSE',              'EFX-UN.TO',           ''; ...
                '^GSPTSE',              'EGU.TO',           ''; ...
                '^GSPTSE',              'ELD.TO',           ''; ...
                '^GSPTSE',              'ELR.TO',           ''; ...
                '^GSPTSE',              'EMA.TO',           ''; ...
                '^GSPTSE',              'EMP-A.TO',           ''; ...
                '^GSPTSE',              'ENB.TO',           ''; ...
                '^GSPTSE',              'EP-UN.TO',           ''; ...
                '^GSPTSE',              'EQN.TO',           ''; ...
                '^GSPTSE',              'ERF-UN.TO',           ''; ...
                '^GSPTSE',              'ESI.TO',           ''; ...
                '^GSPTSE',              'EXE-UN.TO',           ''; ...
                '^GSPTSE',              'FCE-UN.TO',           ''; ...
                '^GSPTSE',              'FEL.TO',           ''; ...
                '^GSPTSE',              'FES.TO',           ''; ...
                '^GSPTSE',              'FFH.TO',           ''; ...
                '^GSPTSE',              'FGL.TO',           ''; ...
                '^GSPTSE',              'FM.TO',           ''; ...
                '^GSPTSE',              'FNX.TO',           ''; ...
                '^GSPTSE',              'FRU-UN.TO',           ''; ...
                '^GSPTSE',              'FSV.TO',           ''; ...
                '^GSPTSE',              'FTS.TO',           ''; ...
                '^GSPTSE',              'FTT.TO',           ''; ...
                '^GSPTSE',              'G.TO',           ''; ...
                '^GSPTSE',              'GAM.TO',           ''; ...
                '^GSPTSE',              'GC.TO',           ''; ...
                '^GSPTSE',              'GIB-A.TO',           ''; ...
                '^GSPTSE',              'GIL.TO',           ''; ...
                '^GSPTSE',              'GMP-UN.TO',           ''; ...
                '^GSPTSE',              'GNA.TO',           ''; ...
                '^GSPTSE',              'GO-A.TO',           ''; ...
                '^GSPTSE',              'ABX.TO',           ''; ...
                '^GSPTSE',              'GSC.TO',           ''; ...
                '^GSPTSE',              'GWO.TO',           ''; ...
                '^GSPTSE',              'HBM.TO',           ''; ...
                '^GSPTSE',              'HCG.TO',           ''; ...
                '^GSPTSE',              'HPX.TO',           ''; ...
                '^GSPTSE',              'HR-UN.TO',           ''; ...
                '^GSPTSE',              'HSE.TO',           ''; ...
                '^GSPTSE',              'HTE-UN.TO',           ''; ...
                '^GSPTSE',              'HW.TO',           ''; ...
                '^GSPTSE',              'IAG.TO',           ''; ...
                '^GSPTSE',              'IGM.TO',           ''; ...
                '^GSPTSE',              'IIC.TO',           ''; ...
                '^GSPTSE',              'IMG.TO',           ''; ...
                '^GSPTSE',              'IMN.TO',           ''; ...
                '^GSPTSE',              'IMO.TO',           ''; ...
                '^GSPTSE',              'INN-UN.TO',           ''; ...
                '^GSPTSE',              'IOL.TO',           ''; ...
                '^GSPTSE',              'IPL-UN.TO',           ''; ...
                '^GSPTSE',              'ITX.TO',           ''; ...
                '^GSPTSE',              'IVN.TO',           ''; ...
                '^GSPTSE',              'JAG.TO',           ''; ...
                '^GSPTSE',              'JAZ-UN.TO',           ''; ...
                '^GSPTSE',              'K.TO',           ''; ...
                '^GSPTSE',              'KEY-UN.TO',           ''; ...
                '^GSPTSE',              'KFS.TO',           ''; ...
                '^GSPTSE',              'KHD.TO',           ''; ...
                '^GSPTSE',              'L.TO',           ''; ...
                '^GSPTSE',              'LB.TO',           ''; ...
                '^GSPTSE',              'LIF-UN.TO',           ''; ...
                '^GSPTSE',              'LNR.TO',           ''; ...
                '^GSPTSE',              'LUN.TO',           ''; ...
                '^GSPTSE',              'MBT.TO',           ''; ...
                '^GSPTSE',              'MDA.TO',           ''; ...
                '^GSPTSE',              'MDI.TO',           ''; ...
                '^GSPTSE',              'MDS.TO',           ''; ...
                '^GSPTSE',              'MFC.TO',           ''; ...
                '^GSPTSE',              'MFI.TO',           ''; ...
                '^GSPTSE',              'MG-A.TO',           ''; ...
                '^GSPTSE',              'ML.TO',           ''; ...
                '^GSPTSE',              'MRE.TO',           ''; ...
                '^GSPTSE',              'MRU-A.TO',           ''; ...
                '^GSPTSE',              'MTL-UN.TO',           ''; ...
                '^GSPTSE',              'MX.TO',           ''; ...
                '^GSPTSE',              'NA.TO',           ''; ...
                '^GSPTSE',              'NAE-UN.TO',           ''; ...
                '^GSPTSE',              'NAL-UN.TO',           ''; ...
                '^GSPTSE',              'NB.TO',           ''; ...
                '^GSPTSE',              'NBD.TO',           ''; ...
                '^GSPTSE',              'NCX.TO',           ''; ...
                '^GSPTSE',              'NG.TO',           ''; ...
                '^GSPTSE',              'NGD.TO',           ''; ...
                '^GSPTSE',              'NGX.TO',           ''; ...
                '^GSPTSE',              'NKO.TO',           ''; ...
                '^GSPTSE',              'NPI-UN.TO',           ''; ...
                '^GSPTSE',              'NT.TO',           ''; ...
                '^GSPTSE',              'NVA.TO',           ''; ...
                '^GSPTSE',              'NWF-UN.TO',           ''; ...
                '^GSPTSE',              'NXY.TO',           ''; ...
                '^GSPTSE',              'OCX.TO',           ''; ...
                '^GSPTSE',              'OIL.TO',           ''; ...
                '^GSPTSE',              'OPC.TO',           ''; ...
                '^GSPTSE',              'OTC.TO',           ''; ...
                '^GSPTSE',              'PAA.TO',           ''; ...
                '^GSPTSE',              'PBG.TO',           ''; ...
                '^GSPTSE',              'PCA.TO',           ''; ...
                '^GSPTSE',              'PD-UN.TO',           ''; ...
                '^GSPTSE',              'PEY-UN.TO',           ''; ...
                '^GSPTSE',              'PGF-UN.TO',           ''; ...
                '^GSPTSE',              'PGX-UN.TO',           ''; ...
                '^GSPTSE',              'PIF-UN.TO',           ''; ...
                '^GSPTSE',              'PJC-A.TO',           ''; ...
                '^GSPTSE',              'PMT-UN.TO',           ''; ...
                '^GSPTSE',              'PMZ-UN.TO',           ''; ...
                '^GSPTSE',              'POT.TO',           ''; ...
                '^GSPTSE',              'POU.TO',           ''; ...
                '^GSPTSE',              'POW.TO',           ''; ...
                '^GSPTSE',              'PSI.TO',           ''; ...
                '^GSPTSE',              'PVE-UN.TO',           ''; ...
                '^GSPTSE',              'PWF.TO',           ''; ...
                '^GSPTSE',              'PWT-UN.TO',           ''; ...
                '^GSPTSE',              'PXE.TO',           ''; ...
                '^GSPTSE',              'QBR-B.TO',           ''; ...
                '^GSPTSE',              'QUA.TO',           ''; ...
                '^GSPTSE',              'RBI.TO',           ''; ...
                '^GSPTSE',              'RCI-B.TO',           ''; ...
                '^GSPTSE',              'REF-UN.TO',           ''; ...
                '^GSPTSE',              'REI-UN.TO',           ''; ...
                '^GSPTSE',              'RET-A.TO',           ''; ...
                '^GSPTSE',              'RIM.TO',           ''; ...
                '^GSPTSE',              'RON.TO',           ''; ...
                '^GSPTSE',              'RUS.TO',           ''; ...
                '^GSPTSE',              'RY.TO',           ''; ...
                '^GSPTSE',              'S.TO',           ''; ...
                '^GSPTSE',              'SAP.TO',           ''; ...
                '^GSPTSE',              'SC.TO',           ''; ...
                '^GSPTSE',              'SCC.TO',           ''; ...
                '^GSPTSE',              'SCL-A.TO',           ''; ...
                '^GSPTSE',              'SIF-UN.TO',           ''; ...
                '^GSPTSE',              'SJR-B.TO',           ''; ...
                '^GSPTSE',              'SLF.TO',           ''; ...
                '^GSPTSE',              'SLW.TO',           ''; ...
                '^GSPTSE',              'SNC.TO',           ''; ...
                '^GSPTSE',              'SPF-UN.TO',           ''; ...
                '^GSPTSE',              'SSO.TO',           ''; ...
                '^GSPTSE',              'STN.TO',           ''; ...
                '^GSPTSE',              'SU.TO',           ''; ...
                '^GSPTSE',              'SVM.TO',           ''; ...
                '^GSPTSE',              'SVY.TO',           ''; ...
                '^GSPTSE',              'T.TO',           ''; ...
                '^GSPTSE',              'TA.TO',           ''; ...
                '^GSPTSE',              'TCK-B.TO',           ''; ...
                '^GSPTSE',              'TCL-A.TO',           ''; ...
                '^GSPTSE',              'TCM.TO',           ''; ...
                '^GSPTSE',              'TCW.TO',           ''; ...
                '^GSPTSE',              'TD.TO',           ''; ...
                '^GSPTSE',              'TDG.TO',           ''; ...
                '^GSPTSE',              'TFI.TO',           ''; ...
                '^GSPTSE',              'THI.TO',           ''; ...
                '^GSPTSE',              'TIH.TO',           ''; ...
                '^GSPTSE',              'TIM.TO',           ''; ...
                '^GSPTSE',              'TLM.TO',           ''; ...
                '^GSPTSE',              'TNX.TO',           ''; ...
                '^GSPTSE',              'TOG.TO',           ''; ...
                '^GSPTSE',              'TRE.TO',           ''; ...
                '^GSPTSE',              'TRI.TO',           ''; ...
                '^GSPTSE',              'TRP.TO',           ''; ...
                '^GSPTSE',              'TRZ-B.TO',           ''; ...
                '^GSPTSE',              'TS-B.TO',           ''; ...
                '^GSPTSE',              'TWF-UN.TO',           ''; ...
                '^GSPTSE',              'UEX.TO',           ''; ...
                '^GSPTSE',              'UTS.TO',           ''; ...
                '^GSPTSE',              'UUU.TO',           ''; ...
                '^GSPTSE',              'VET-UN.TO',           ''; ...
                '^GSPTSE',              'VT.TO',           ''; ...
                '^GSPTSE',              'WFT.TO',           ''; ...
                '^GSPTSE',              'WJA.TO',           ''; ...
                '^GSPTSE',              'WN.TO',           ''; ...
                '^GSPTSE',              'WTE-UN.TO',           ''; ...
                '^GSPTSE',              'X.TO',           ''; ...
                '^GSPTSE',              'YLO-UN.TO',           ''; ...
                '^GSPTSE',              'YRI.TO',           ''; ...
            };

            GroupNames = {''};
            count = 1;
            [x,y] = size(map.table);
            for i = 1:x
                group = map.table{i,1};
                n = find(strcmpi(group,GroupNames));
                if isempty(n)
                    GroupNames{count} = group;
                    count = count + 1;
                end
            end
            map.groupnames = GroupNames;
        end
    end
end