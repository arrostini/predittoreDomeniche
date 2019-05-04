
function[d_hat] =  prediz(h,d)
    tab = readtable('previsioni_consumi.xlsx');
    mat = tab{:,:};
    d = ceil(d/7);
    d_hat = mat(h,d);
end