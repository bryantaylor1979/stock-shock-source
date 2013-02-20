            %%
            get(job,'State')
            
            %% find jobs
            findJob(sched)
            
            %%
            obj.DispSchedularTasks
            
            %%
            obj.RemoveAllCompletedTasks()
            
            %%
            fetchOutputs(job)
            
function DispSchedularTasks(obj)
            sched = findResource();
            jobs = findJob(sched)
        end
        function [pending queued running completed] = GetScheduledTasks(obj)
            sched = findResource();
            [pending queued running completed] = findJob(sched)
        end
        function DestroyAllPendingTasks(obj)
            %%
            [pending queued running completed] = obj.GetScheduledTasks();
            x = size(pending,1);
            for i = 1:x
                destroy(pending(i));
            end
        end
        function RemoveAllCompletedTasks(obj)
            [pending queued running completed] = obj.GetScheduledTasks();
            x = size(completed,1);
            for i = 1:x
                destroy(completed(i));
            end            
        end