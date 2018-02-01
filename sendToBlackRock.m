function result = sendToBlackRock(dio,val,valType)

switch valType
    case 'angle'
        if sign(val) == -1
            val = 360 + val;
        end
        if val >360
            error('Incorrect val value');
        end
        if val > 255
            out1 = 255;
            out2 = val - 255;
        else
            out1 = val;
            out2 = 0;
        end
    case 'time'
        if val > 10
            error('val must be less tan 10');
        end
        out1 = floor(val*10);
        out2 = floor(val*1000) - out1*100;
    
    case 'vel'
        val = floor(val);
        val = val/1000;
        out1 = floor(val*10);
        out2 = floor(val*1000) - out1*100;
    case 'response'
        if val == -1
            out1 = 2;
        else
            out1 = 1;
        end
        out2 = 0;
    otherwise
        error('Incorrect valType')
end

if dio == '1'
    out1
    out2
else
putvalue(dio,out1);
putvalue(dio,0);
putvalue(dio,out2);
putvalue(dio,0);
end