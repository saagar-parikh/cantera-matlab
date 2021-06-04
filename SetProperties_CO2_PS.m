function [p, v, T, u, h, s, x] = SetProperties_CO2_PS(p, s)
    
    data = readmatrix('CO2.xlsx','Sheet','satCO2_Psat');

    if (p>7100000 || p<600000)
        T=0;
        u=0;
        h=0;
        v=0;
        x=0;
        disp("Input parameters exceed range");
        return
    end   
    
    if (p==600000)
        rowL = 1;
        rowU = 2;
    elseif (p==7100000)
        rowL = 26;
        rowU = 27;
    else
        % rowL and rowU represent the rows between which the given P lies
        for i=1:27              
            if (data(i,1) > p)
                rowL=i-1;
                rowU=i;
                break
            end
        end
    end  
    
    % Evaluating all properties using the closest rows that were
    % determined 
    p1 = data(rowL, 1);
    p2 = data(rowU, 1);    
    
    s_f1 = data(rowL,12);
    s_fg1 = data(rowL,13);

    s_f2 = data(rowU,12);
    s_fg2 = data(rowU,13);

    % Finding the final values of s_f and s_fg using linear interpolation
    s_f  = s_f1  + (s_f2  -  s_f1)*(p - p1)/(p2 - p1);
    s_fg = s_fg1 + (s_fg2 - s_fg1)*(p - p1)/(p2 - p1);

    x = (s - s_f)/s_fg;
    
    % Evaluating properties depending on the phase of the substance
    if(x<0)                     % Sub-cooled liquid phase
    
    % Data for subcooled liquid has not been provided so we assign all the
    % properties to 0 by default.
    
        T=0;
        u=0;
        h=0;
        v=0;
        x=0;
        disp("Data unavailable for substance in subcooled state");
        return
    elseif (x>=0 && x<1)        % Saturated liquid vapour mixture
        
    % Evaluating all properties using the closest rows that were
    % determined and then using interpolation to get the final values
        
        v_f1 = data(rowL,3);
        v_fg1 = data(rowL,4);

        v_f2 = data(rowU,3);        
        v_fg2 = data(rowU,4);

        % Find final values of v_f and v_fg using linear interpolation
        v_f  = v_f1  + (v_f2  -  v_f1)*(p - p1)/(p2 - p1);
        v_fg = v_fg1 + (v_fg2 - v_fg1)*(p - p1)/(p2 - p1);

        u_f1 = data(rowL,6);
        u_fg1 = data(rowL,7);

        u_f2 = data(rowU,6);
        u_fg2 = data(rowU,7);

        u_f  = u_f1  + (u_f2  -  u_f1)*(p - p1)/(p2 - p1);
        u_fg = u_fg1 + (u_fg2 - u_fg1)*(p - p1)/(p2 - p1);            


        h_f1 = data(rowL,9);
        h_fg1 = data(rowL,10);
        
        h_f2 = data(rowU,9);
        h_fg2 = data(rowU,10);

        h_f  = h_f1  + (h_f2  -  h_f1)*(p - p1)/(p2 - p1);
        h_fg = h_fg1 + (h_fg2 - h_fg1)*(p - p1)/(p2 - p1);            

        T1 = data(rowL,2);
        T2 = data(rowU,2);
        
        % Calculating the final values of the required properties
        T  = T1  + (T2  -  T1)*(p - p1)/(p2 - p1);
        v = v_f + x*v_fg;
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


    elseif (x>1)                        % Superheated vapour region
        x =1;
        
        data2 = readmatrix('CO2.xlsx','Sheet','supHeatCO2');
        
        % rowL and rowU represent the rows between which the given P lies
        for j=1:27
            i = (j-1)*10 + 1;
            
            if (data2(i, 1)>=p)
                temp_rowL = i-1; 
                temp_rowU = i;
                break
            end
        end
        
        % Evaluating pL and pU using the closest rows that were
        % determined 
        pL = data2(temp_rowL, 1);
        pU = data2(temp_rowU, 1);
        
        % Using interpolation to get the final values
        T1 = interp1( data2(temp_rowL:temp_rowL+9,6), data2(temp_rowL:temp_rowL+9,2), s);
        T2 = interp1( data2(temp_rowU:temp_rowU+9,6), data2(temp_rowU:temp_rowU+9,2), s);
         
        u1 = interp1( data2(temp_rowL:temp_rowL+9,6), data2(temp_rowL:temp_rowL+9,4), s);
        u2 = interp1( data2(temp_rowU:temp_rowU+9,6), data2(temp_rowU:temp_rowU+9,4), s);
        
        h1 = interp1( data2(temp_rowL:temp_rowL+9,6), data2(temp_rowL:temp_rowL+9,5), s);
        h2 = interp1( data2(temp_rowU:temp_rowU+9,6), data2(temp_rowU:temp_rowU+9,5), s);
        
        v1 = interp1( data2(temp_rowL:temp_rowL+9,6), data2(temp_rowL:temp_rowL+9,3), s);
        v2 = interp1( data2(temp_rowU:temp_rowU+9,6), data2(temp_rowU:temp_rowU+9,3), s);
        
        % Calculating the final values of the required properties
        T  = T1  + (T2  -  T1)*(p - pL)/(pU - pL);
        u  = u1  + (u2  -  u1)*(p - pL)/(pU - pL);
        h  = h1  + (h2  -  h1)*(p - pL)/(pU - pL);
        v  = v1  + (v2  -  v1)*(p - pL)/(pU - pL);        

                
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