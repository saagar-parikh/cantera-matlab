clear all;

T_TVtest1 = 299;
v_TVtest1 = 0.004;
T_TVtest2 = 295;
v_TVtest2 = 0.018;
% TVtest(T_TVtest1, v_TVtest1);
% TVtest(T_TVtest2, v_TVtest2);

P_PVtest1 = 6300000;
v_PVtest1 = 0.003;
P_PVtest2 = 6900000;
v_PVtest2 = 0.007;
PVtest(P_PVtest2, v_PVtest2);

function TVtest(T_TVtest, v_TVtest)
    CO2 = Solution('liquidvapor.cti','carbondioxide');
    
    setState_TV(CO2, [T_TVtest, v_TVtest]);
    [p, v, T, u, h, s, x] = SetProperties_CO2_TV(T_TVtest, v_TVtest);

    p_cantera = pressure(CO2);
    v_cantera = 1/density(CO2);
    T_cantera = temperature(CO2);
    u_cantera = intEnergy_mass(CO2);
    h_cantera = enthalpy_mass(CO2);
    s_cantera = entropy_mass(CO2);
    x_cantera = vaporFraction(CO2);

    p_error = percentage_error(p_cantera, p)
    v_error = percentage_error(v_cantera, v)
    T_error = percentage_error(T_cantera, T)
    u_error = percentage_error(u_cantera, u)
    h_error = percentage_error(h_cantera, h)
    s_error = percentage_error(s_cantera, s)
    x_error = percentage_error(x_cantera, x)
end

function PVtest(P_PVtest, v_PVtest)
    CO2 = Solution('liquidvapor.cti','carbondioxide');
    
    setState_PV(CO2, [P_PVtest, v_PVtest]);
    [p, v, T, u, h, s, x] = SetProperties_CO2_PV(P_PVtest, v_PVtest);

    p_cantera = pressure(CO2);
    v_cantera = 1/density(CO2);
    T_cantera = temperature(CO2);
    u_cantera = intEnergy_mass(CO2);
    h_cantera = enthalpy_mass(CO2);
    s_cantera = entropy_mass(CO2);
    x_cantera = vaporFraction(CO2);

    p_error = percentage_error(p_cantera, p)
    v_error = percentage_error(v_cantera, v)
    T_error = percentage_error(T_cantera, T)
    u_error = percentage_error(u_cantera, u)
    h_error = percentage_error(h_cantera, h)
    s_error = percentage_error(s_cantera, s)
    x_error = percentage_error(x_cantera, x)
end

function PStest(P_PStest, s_PStest)
    CO2 = Solution('liquidvapor.cti','carbondioxide');
    
    setState_SP(CO2, [s_PStest, P_PStest]);
    [p, v, T, u, h, s, x] = SetProperties_CO2_PS(P_PStest, s_PStest);

    p_cantera = pressure(CO2);
    v_cantera = 1/density(CO2);
    T_cantera = temperature(CO2);
    u_cantera = intEnergy_mass(CO2);
    h_cantera = enthalpy_mass(CO2);
    s_cantera = entropy_mass(CO2);
    x_cantera = vaporFraction(CO2);

    p_error = percentage_error(p_cantera, p)
    v_error = percentage_error(v_cantera, v)
    T_error = percentage_error(T_cantera, T)
    u_error = percentage_error(u_cantera, u)
    h_error = percentage_error(h_cantera, h)
    s_error = percentage_error(s_cantera, s)
    x_error = percentage_error(x_cantera, x)
end

function [error] = percentage_error(cant,calc)
    error = ((calc - cant) / cant)*100;
end





