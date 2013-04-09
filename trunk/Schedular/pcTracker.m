classdef pcTracker < handle
    properties (SetObservable = true)
        pcName
        NoRunning = 0;
        NoPending = 0;
        tracker_DATASET = dataset([])
    end
    methods (Hidden = true)
        function obj = pcTracker()
        end
    end
end