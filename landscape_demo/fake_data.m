x = -10000:20:10000;
y = -10000:20:10000;
[X,Y] = meshgrid(x,y);
Z = sqrt(X.*X+Y.*Y).*(0.5*sin(1/300*sqrt(X.*X+Y.*Y))+0.5).*(abs(X)./sqrt(X.*X+Y.*Y));
mesh(X,Y,Z);
