function TimeStr = CalculateTime(Seconds) %Add this in to the batcher. (Once the batcher is adopted)
    secs = round(Seconds);
    minutes = floor(secs/60);
    hours = floor(minutes/60);
    min = minutes - hours*60;
    secs = secs - minutes*60;
    TimeStr = [num2str(hours),'h ',num2str(min),'m ',num2str(secs),'s'];
end  