f1 = fopen("/home/drlxj/ethz/mr/result/h.txt");
h = textscan(f1, '%f');
h = h{1,1};

f2 = fopen("/home/drlxj/ethz/mr/result/d.txt");
d = textscan(f2, '%f');
d = d{1,1};

angle = 45:1:224;
angle = angle' * pi / 180;

p_x = d .* cos(angle) + 20160;
p_y = d .* sin(angle) - 14560;

%% Initialize video
myVideo = VideoWriter('myVideoFile'); %open video file
myVideo.FrameRate = 10;  %can adjust this, 5 - 10 works well for me
open(myVideo)

hold on;
x = -40000:160:40000;
y = -40000:160:40000;
[X,Y] = meshgrid(x,y);
Z = sqrt(X.*X+Y.*Y).*(0.5*sin(1/1200*sqrt(X.*X+Y.*Y))+0.5).*(abs(X)./sqrt(X.*X+Y.*Y)) / 10;
Z(X.*X+Y.*Y > 39112.82854 ^ 2) = -1;
mesh(X,Y,Z);

org_x = 19840;
org_y = -14240;
org_z = sqrt(org_x.*org_x+org_y.*org_y).*(0.5*sin(1/1200*sqrt(org_x.*org_x+org_y.*org_y))+0.5).*(abs(org_x)./sqrt(org_x.*org_x+org_y.*org_y)) / 10;



for i=1:180
    x1 = [p_x(i), org_x];
    y1 = [p_y(i), org_y];
    z1 = [h(i), org_z];
    plot3(x1, y1, z1, 'red')
    pause(.1)
    hold on;

    frame = getframe(gcf); %get frame
    writeVideo(myVideo, frame);
end

xlabel('x', 'Interpreter', 'Latex')
ylabel('y', 'Interpreter', 'Latex')
zlabel('z', 'Interpreter', 'Latex')

close(myVideo)