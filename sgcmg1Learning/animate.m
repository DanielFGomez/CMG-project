i=1;
j=0;
figure
numFrames=find(History(:,5)==floor(numEpisodes),1)+500;
mov = struct('cdata', [],...
                        'colormap', []);
n=1;
for k=0.2:0.25:1.2
    while(i<200)
        
        xpos=sin(History(i+j,1));
        ypos=cos(History(i+j,1));
        
        gimbalX=xpos+0.2*sin(History(i+j,3));
        gimbalY=ypos+0.2*cos(History(i+j,3));
        
        plot([0 xpos],[0 ypos],[0 50*History(i+j,4)],[0 0],[xpos,gimbalX],[ypos,gimbalY],'LineWidth',8);
        %legend('Pendulum','Control')
        title(strcat('Episode Number ',num2str(History(i+j,5)),' q=',num2str(History(i+j,1)),' dq=',num2str(History(i+j,2))));
        axis([-1,1,0,2]);
        i=i+1;
        pause(0.01)
        mov(n)=getframe;
        n=n+1;
    end
    i=0;
    j=find(History(:,5)==floor(k*(numEpisodes)),1);
end
movie2avi(mov,'prueba');