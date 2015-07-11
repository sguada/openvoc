function gtitle(title_text)
supAxes=[.05 .05 .875 .875];
ax=axes('Units','Normal','Position',supAxes,'Visible','off','tag','suplabel');
set(get(ax,'Title'),'Visible','on')
title(title_text,'FontSize',14,'FontWeight','bold');