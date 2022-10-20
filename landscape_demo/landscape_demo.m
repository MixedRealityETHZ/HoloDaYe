fid  = fopen('SWISSALTI3D_2_XYZ_CHLV95_LN02_2684_1248.xyz');
data = textscan(fid,'%f%f%f','Delimiter',' ','HeaderLines',1);
x = cell2mat(data(1));
y = cell2mat(data(2));
z = cell2mat(data(3));
x_space = (max(x) - min(x))/2+1;
y_space = (max(y) - min(y))/2+1;
Z = zeros(x_space, y_space);
for i=1:y_space
    Z(i,:) = z((i-1)*x_space+1:i*x_space);
end

mesh(min(x):2:max(x),max(y):-2:min(y),Z)
axis tight; hold on
plot3(x,y,z,'.','MarkerSize',1)