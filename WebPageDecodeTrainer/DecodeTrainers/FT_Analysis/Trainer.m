%% Key Figures
% Analysis view
count = 1;
struct(count).Name = 'AnalysisView';
struct(count).NoOfIndices = NaN;
struct(count).Class = 'Char';
struct(count).BARC_19_Aug_2011.ExpectedValue = 'The 32 analysts offering 12 month price targets for Barclays PLC (BARC:LSE) have a median target of 303.50, with a high estimate of 440.00 and a low estimate of 178.25. The median estimate represents a 97.08% increase from the last price of 154.00.';
struct(count).RBS_19_Aug_2011.ExpectedValue = 'The 28 analysts offering 12 month price targets for Royal Bank of Scotland Group PLC (RBS:LSE) have a median target of 45.50, with a high estimate of 282.93 and a low estimate of 34.00. The median estimate represents a 107.29% increase from the last price of 21.95.';

% Short Term Text
count = count + 1;
struct(count).Name = 'EPS_ShortTermText';
struct(count).NoOfIndices = NaN;
struct(count).Class = 'Char';
struct(count).BARC_19_Aug_2011.ExpectedValue = 'On August 02, 2011, Barclays PLC reported semi annual 2011 earnings of 20.11 per share. This result exceeded the 12.24 consensus of the 7 analysts covering the company and exceeded last year''s results for the same period by 2.10%.';
struct(count).RBS_19_Aug_2011.ExpectedValue = 'On August 05, 2011, Royal Bank of Scotland Group PLC reported semi annual 2011 earnings of 0.70 per share.';

% % Short term growth
% count = count + 1;
% struct(count).Name = 'EPS_ShortTermGrowth';
% struct(count).NoOfIndices = NaN;
% struct(count).Class = 'Char';
% struct(count).BARC_19_Aug_2011.ExpectedValue = '10.74%';
% struct(count).RBS_19_Aug_2011.ExpectedValue = '+23.30%';

% Long Term Text
count = count + 1;
struct(count).Name = 'EPS_LongTermText';
struct(count).NoOfIndices = NaN;
struct(count).Class = 'Char';
struct(count).BARC_19_Aug_2011.ExpectedValue = 'Barclays PLC reported annual 2010 earnings of 23.80 per share on February 15, 2011. <br/>The next earnings announcement from Barclays PLC is expected the week of February 08, 2012.';
struct(count).RBS_19_Aug_2011.ExpectedValue = 'Royal Bank of Scotland Group PLC reported annual 2010 earnings of 1.99 per share on February 24, 2011.';

% % Long term growth
% count = count + 1;
% struct(count).Name = 'EPS_LongTermGrowth';
% struct(count).NoOfIndices = NaN;
% struct(count).Class = 'Char';
% struct(count).BARC_19_Aug_2011.ExpectedValue = '+4.57%';
% struct(count).RBS_19_Aug_2011.ExpectedValue = '+22.47%';


% Short Term Text
count = count + 1;
struct(count).Name = 'Rev_ShortTermText';
struct(count).NoOfIndices = NaN;
struct(count).Class = 'Char';
struct(count).BARC_19_Aug_2011.ExpectedValue = 'BARC.L reported semi annual 2011 revenues of 15.33bn. This bettered the 15.03bn consensus of the 10 analysts covering the company. This was 50.84% above the prior year''s period results.';
struct(count).RBS_19_Aug_2011.ExpectedValue = 'RBS.L reported semi annual 2011 revenues of 15.80bn. This bettered the 13.96bn consensus of the 4 analysts covering the company. This was -12.03% below the prior year''s period results';

% % Short term growth
% count = count + 1;
% struct(count).Name = 'Rev_ShortTermGrowth';
% struct(count).NoOfIndices = NaN;
% struct(count).Class = 'Char';
% struct(count).BARC_19_Aug_2011.ExpectedValue = '+0.42%';
% struct(count).RBS_19_Aug_2011.ExpectedValue = '-0.12%';


% Long Term Text
count = count + 1;
struct(count).Name = 'Rev_LongTermText';
struct(count).NoOfIndices = NaN;
struct(count).Class = 'Char';
struct(count).BARC_19_Aug_2011.ExpectedValue = 'BARC.L had revenues for the full year 2010 of 31.44bn. This was 1.47% above the prior year''s results.';
struct(count).RBS_19_Aug_2011.ExpectedValue = 'RBS.L had revenues for the full year 2010 of 31.87bn. This was 27.13% above the prior year''s results.';


% % Long term growth
% count = count + 1;
% struct(count).Name = 'Rev_LongTermGrowth';
% struct(count).NoOfIndices = NaN;
% struct(count).Class = 'Char';
% struct(count).BARC_19_Aug_2011.ExpectedValue = '+2.50%';
% struct(count).RBS_19_Aug_2011.ExpectedValue = '+0.28%';
