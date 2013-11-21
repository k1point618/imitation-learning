% Author: Russ Tedrake   russt@mit.edu
% http://groups.csail.mit.edu/locomotion/software.html
function status = draw_acrobot(l1,l2,t,x)
      persistent hFig L1r L1a L2r L2a;

      if (isempty(hFig))
        hFig = figure(32);
        set(hFig,'DoubleBuffer','on');
        av = pi/2*[1:.05:3];
        r = .04*min([l1 l2]);
        L1x = [r*cos(av) l1+r*cos(av+pi)];
        L1y = [r*sin(av) r*sin(av+pi)];
        L1r = (L1x.^2+L1y.^2).^.5;
        L1a = atan2(L1y,L1x);
        L2x = [r*cos(av) l2+r*cos(av+pi)];
        L2y = [r*sin(av) r*sin(av+pi)];
        L2r = (L2x.^2+L2y.^2).^.5;
        L2a = atan2(L2y,L2x);
      end
  
      figure(hFig);
      clf;
      
      patch(L1r.*sin(L1a+x(1)),-L1r.*cos(L1a+x(1)),0*L1a,'r');
      hold on
      patch(l1*sin(x(1))+L2r.*sin(L2a+x(1)+x(2)),-l1*cos(x(1))-L2r.*cos(L2a+x(1)+x(2)),1+0*L2a,'b');
      plot3(0,0,2,'k+');
      axis image
      view(0,90)
      axis off
      axis((l1+l2)*1.1*[-1 1 -1 1 -1 1000]);
      
      title(['t = ', num2str(t,'%.2f') ' sec']);
      drawnow;
      
      status = 0;
