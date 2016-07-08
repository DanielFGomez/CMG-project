x=-pi/2:pi/100:pi/2;
for i=1:101
rew(i)=reward(x(i),0);
j=j+1;
end
figure
plot(x*180/pi,rew,'linewidth',2)
xlabel('Angle (°)','FontSize',14)
ylabel('Reward','FontSize',14)

xlabel('Ángulo (°)','fontsize',20)
ylabel('Premio','fontsize',20)