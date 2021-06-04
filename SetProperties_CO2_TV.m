function [p, v, T, u, h, s, x] = SetProperties_CO2_TV(T, v)

    data = readmatrix('CO2.xlsx','Sheet','satCO2_Tsat');
    data2 = readmatrix('CO2.xlsx','Sheet','satCO2_Psat');
   
    % Error handling

    if (T>300 || T<220)
        p=0;
        u=0;
        h=0;
        s=0;
        x=0;
        disp("Input parameters exceed range");
        return
    end
    row = ((T - 220)/5) + 1;        % Finding the closest row using temperature unsing Saturated Temperature Table
    
    if (T==300)

        rowL = floor(row)-1;              % rowL and rowU represent the rows between which the given T lies
        rowU = rowL + 1;        
        
    else
        rowL = floor(row);              % rowL and rowU represent the rows between which the given T lies
        rowU = rowL + 1;
    end    

    % Reading the temperatures of the closest two rows
    
    
    T1 = data(rowL, 1);         
    T2 = data(rowU, 1);
    
    % Reading the v_f and v_g corresponding to the closest two temperatures
    
    v_f1 = data(rowL,3);
    v_fg1 = data(rowL,4);
  
    v_f2 = data(rowU,3);        
    v_fg2 = data(rowU,4);

    % Performing linear interpolation between these two temperatures to
    % evaluate the v_f and v_g for the given temperature
    
    v_f  = v_f1  + (v_f2  -  v_f1)*(T - T1)/(T2 - T1);
    v_fg = v_fg1 + (v_fg2 - v_fg1)*(T - T1)/(T2 - T1);
    
    % Finding the quality of the vapour, regardless of the phase. Different
    % phases are accounted for afterwards
    
    x = (v - v_f)/v_fg;         % Vapour fraction (quality) of the given substance
    
    
    % Evaluating properties depending on the phase of the substance
    if(x<0)                     % Sub-cooled liquid phase
    
        % Data for subcooled liquid has not been provided so we assign all the
        % properties to 0 by default.
    
        p=0;
        u=0;
        h=0;
        s=0;
        x=0;
        disp("Data unavailable for substance in subcooled state");
    
    
    elseif (x>=0 && x<1)        % Saturated liquid vapour mixture
    
    % Using the two closest rows based on Temperature that were evaluated
    % earlier, we determine all the properties of the substance
    
   
        % Evaluating s_f and s_fg using the closest rows that were
        % determined
        
        s_f1 = data(rowL,12);
        s_fg1 = data(rowL,13);
        
        s_f2 = data(rowU,12);
        s_fg2 = data(rowU,13);
    
        % Interpolating with respect to temperature to get s_f and s_fg
        
        s_f  = s_f1  + (s_f2  -  s_f1)*(T - T1)/(T2 - T1);
        s_fg = s_fg1 + (s_fg2 - s_fg1)*(T - T1)/(T2 - T1);
        % Evaluating u_f and u_fg using the closest rows that were
        % determined
        
        u_f1 = data(rowL,6);
        u_fg1 = data(rowL,7);
        
        u_f2 = data(rowU,6);
        u_fg2 = data(rowU,7);
 
        % Interpolating with respect to temperature to get u_f and u_fg
        u_f  = u_f1  + (u_f2  -  u_f1)*(T - T1)/(T2 - T1);
        u_fg = u_fg1 + (u_fg2 - u_fg1)*(T - T1)/(T2 - T1);            
    
        % Evaluating s_f and s_fg using the closest rows that were
        % determined
        
        h_f1 = data(rowL,9);
        h_fg1 = data(rowL,10);

        h_f2 = data(rowU,9);
        h_fg2 = data(rowU,10);
        
        % Interpolating with respect to temperature to get h_f and h_fg
        
        h_f  = h_f1  + (h_f2  -  h_f1)*(T - T1)/(T2 - T1);
        h_fg = h_fg1 + (h_fg2 - h_fg1)*(T - T1)/(T2 - T1);            
    
        % Evaluating pressure by interpolation
        
        p1 = data(rowL,2);
        p2 = data(rowU,2);
        p  = p1  + (p2  -  p1)*(T - T1)/(T2 - T1);
    
      
        % Evaulating the final value of properties using the quality that
        % was determined earlier

        s = s_f + x*s_fg;
        h = h_f + x*h_fg;
        u = u_f + x*u_fg;
        
        
         % Displaying all the properties that were computed
         
         disp(['Pressure = ', num2str(p),' Pa']);
         disp(['Specific volume = ', num2str(v),' m3/kg']);
         disp(['Temperature = ', num2str(T),' K']);
         disp(['Specific Internal Energy = ', num2str(u),' J/kg']);
         disp(['Specific Enthalpy = ', num2str(h),' J/kg']);
         disp(['Specific Entropy = ', num2str(s),' J/kg-K']);
         disp(['Vapour fraction (quality) = ', num2str(x)]);        
    
    elseif (x>1)                                % Superheated vapour region
        
        x=1;
        
        psat = interp1(data(:,1),data(:,2),T);  % Evaluating saturation pressure
        
        % Reading the superheated data sheet
        data3 = readmatrix('CO2.xlsx','Sheet','supHeatCO2');
        
        % Creating new empty vectors   
        v_at_T = zeros(27,1);
        u_at_T = zeros(27,1);
        h_at_T = zeros(27,1);
        s_at_T = zeros(27,1);
        
        % Calculating the new v, u, h, and s values at input temperature
        % using linear interpolation
        for j = 1:27
            i = (j-1)*10 + 1;
            
            % Breaking the loop when p>psat
            if (data3(i,1)>psat)
                break
            end
           
            v_at_T(j) = interp1( data3(i:i+9,2), data3(i:i+9,3), T);
            u_at_T(j) = interp1( data3(i:i+9,2), data3(i:i+9,4), T);
            h_at_T(j) = interp1( data3(i:i+9,2), data3(i:i+9,5), T);
            s_at_T(j) = interp1( data3(i:i+9,2), data3(i:i+9,6), T);
            
        end
        
       
        
        % rowL and rowU represent the rows between which the given v lies
        if (T==220)
            rowL=1;
            rowU=2;
        else
            for j = 1:27
                if (v_at_T(j) < v)
                    rowL=j-1;
                    rowU=j;
                    break
                end
            end
        end
        
        % Evaluating all properties using the closest rows that were
        % determined
        
        p1 = data2(rowL, 1);
        p2 = data2(rowU, 1);        
        
        u1 = data3((rowL-1)*10 + 1, 4);
        u2 = data3((rowU-1)*10 + 1, 4); 
       
        h1 = data3((rowL-1)*10 + 1, 5);
        h2 = data3((rowU-1)*10 + 1, 5); 
        
        s1 = data3((rowL-1)*10 + 1, 6);
        s2 = data3((rowU-1)*10 + 1, 6); 
        
        vL = v_at_T(rowL);
        vU = v_at_T(rowU);
        
        % Calculating the final values of the required properties using
        % interpolation
        p  = p1  + (p2  -  p1)*(v - vL)/(vU - vL);
        u  = u1  + (u2  -  u1)*(v - vL)/(vU - vL);
        h  = h1  + (h2  -  h1)*(v - vL)/(vU - vL);
        s  = s1  + (s2  -  s1)*(v - vL)/(vU - vL);
            
        
        
        % Displaying all the properties that were computed
         
        disp(['Pressure = ', num2str(p),' Pa']);
        disp(['Specific volume = ', num2str(v),' m3/kg']);
        disp(['Temperature = ', num2str(T),' K']);
        disp(['Specific Internal Energy = ', num2str(u),' J/kg']);
        disp(['Specific Enthalpy = ', num2str(h),' J/kg']);
        disp(['Specific Entropy = ', num2str(s),' J/kg-K']);
        disp(['Vapour fraction (quality) = ', num2str(x)]);

        
    end
    

 
end