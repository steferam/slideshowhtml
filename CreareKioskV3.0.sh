#!/bin/bash
# Scritto da Stefano Mercurio
# http://www.netlivein.it
version=1.0.0
#
# Preparazione scheda immagine lite
# https://downloads.raspberrypi.org/raspbian_lite_latest
#

#sito="'http://172.16.1.4/orarioint/'"
#sito="'http://www.netlivein.it'"
sito="'http://localhost/slideshowhtml'"

#####################################################################
# Da fare per nuova versione
#
# bugs Nel rilanziare la procedura vengono accodate nuove linee uguali nel file /etc/xdg/openbox/autostart
#
# cambiare le password
#
#####################################################################


istruzioni () {
  clear
  echo "########################################################################"
  echo "#                                                                      #"
  echo "#                         Stefano Mercurio                             #"
  echo "#                                                                      #"
  echo "#                         www.netlivein.it                             #"
  echo "#                                                                      #"
  echo "#                                                                      #"
  echo "#        Script per automatizzare la realizaione di un kiosk           #"
  echo "#                                                                      #"
  echo "#      che apre una pagina web ('http://localhost/slideshowhtml')      #"
  echo "#                                                                      #"
  echo "########################################################################"
  echo
  echo
  read -p "Vuoi continare? (S/s)" -n 1 -r
  if [[ $REPLY =~ ^[Ss]$ ]]
  then
     echo
     echo
     echo "########################################################################"
     echo "#                                                                      #"
     echo "#                   Procedo con l'installazione                        #"
     echo "#                                                                      #"
     echo "########################################################################"
	 procedo
  else
     echo
     echo
     echo "########################################################################"
     echo "#                                                                      #"
     echo "#                      Installazione fermata                           #"
     echo "#                                                                      #"
     echo "########################################################################"
  fi
}

configura_pi() {
  do_change_locale
  do_change_timezone
  do_configure_keyboard
}

installazione() {
  apt-get update
  apt-get upgrade -y
  apt-get install openbox -y
  apt-get install xorg -y
  apt-get install python-webkit -y
  apt-get install apache2 -y
  apt-get install git -y
}

creo_web_pi() {
  echo
  echo
  echo "########################################################################"
  echo "#                                                                      #"
  echo "#                 Preparo il Browser Web con Phyton                    #"
  echo "#                                                                      #"
  echo "########################################################################"
  echo "#!/usr/bin/env python"
  echo "#!/usr/bin/env python" > /usr/bin/web.py
  echo "" | tee -a /usr/bin/web.py
  echo "import gtk, webkit" | tee -a /usr/bin/web.py
  echo "" | tee -a /usr/bin/web.py
  echo "win = gtk.Window()" | tee -a /usr/bin/web.py
  echo "win.connect('destroy', lambda w: gtk.main_quit())" | tee -a /usr/bin/web.py
  echo "" | tee -a /usr/bin/web.py
  echo "win.fullscreen()" | tee -a /usr/bin/web.py
  echo "" | tee -a /usr/bin/web.py
  echo "scroller = gtk.ScrolledWindow()" | tee -a /usr/bin/web.py
  echo "web = webkit.WebView()" | tee -a /usr/bin/web.py
  echo "" | tee -a /usr/bin/web.py
  echo "web.open("$sito")" | tee -a /usr/bin/web.py
  echo "" | tee -a /usr/bin/web.py
  echo "win.add(scroller)" | tee -a /usr/bin/web.py
  echo "scroller.add(web)" | tee -a /usr/bin/web.py
  echo "" | tee -a /usr/bin/web.py
  echo "win.show_all()" | tee -a /usr/bin/web.py
  echo "" | tee -a /usr/bin/web.py
  echo "gtk.main()" | tee -a /usr/bin/web.py
  chmod +x /usr/bin/web.py
}

preparo_GUI() {
  echo
  echo
  echo "########################################################################"
  echo "#                                                                      #"
  echo "#                 Script per avviare interfacciaGUI                    #"
  echo "#                                                                      #"
  echo "########################################################################"
  echo "#!/bin/sh"
  echo "#!/bin/sh" > /etc/init.d/kiosk
  echo "### BEGIN INIT INFO" | tee -a /etc/init.d/kiosk
  echo "# Provides:          kiosk" | tee -a /etc/init.d/kiosk
  echo "# Required-Start:    " | tee -a /etc/init.d/kiosk
  echo "# Required-Stop:     " | tee -a /etc/init.d/kiosk
  echo "# Default-Start:     2 3 4 5" | tee -a /etc/init.d/kiosk
  echo "# Default-Stop:      0 1 6" | tee -a /etc/init.d/kiosk
  echo "# Short-Description: Il totem Netlivein" | tee -a /etc/init.d/kiosk
  echo "# Description:       Totem per la sola navigazione internet" | tee -a /etc/init.d/kiosk
  echo "### END INIT INFO" | tee -a /etc/init.d/kiosk
  echo "" | tee -a /etc/init.d/kiosk
  echo "startx" | tee -a /etc/init.d/kiosk
  chmod +x /etc/init.d/kiosk
  update-rc.d kiosk defaults
}

autostart() {
  echo
  echo
  echo "########################################################################"
  echo "#                                                                      #"
  echo "#                Accodo comandi per avviare il browser                 #"
  echo "#                                                                      #"
  echo "#                nel file openbox                                      #"
  echo "#                                                                      #"  
  echo "########################################################################"
  echo "" | tee -a /etc/xdg/openbox/autostart
  echo "#Disabilita lo screensaver" | tee -a /etc/xdg/openbox/autostart
  echo "xset -dpms &" | tee -a /etc/xdg/openbox/autostart
  echo "xset s noblank &" | tee -a /etc/xdg/openbox/autostart
  echo "xset s off &" | tee -a /etc/xdg/openbox/autostart
  echo "" | tee -a /etc/xdg/openbox/autostart
  echo "# Lancia l'applicativo" | tee -a /etc/xdg/openbox/autostart
  echo "web.py &" | tee -a /etc/xdg/openbox/autostart
}

ripulisco_openbox() {
  echo
  echo
  echo "########################################################################"
  echo "#                                                                      #"
  echo "#Ricostruisco il menù di openBox                                       #"
  echo "#                                                                      #"
  echo "#In cui verrà permesso solo il riavvio e lo spegnimento del dispositivo#"
  echo "#                                                                      #"
  echo "########################################################################"
  echo > /etc/xdg/openbox/menu.xml
  echo "<?xml version='1.0' encoding='UTF-8'?>" | tee -a /etc/xdg/openbox/menu.xml
  echo "" | tee -a /etc/xdg/openbox/menu.xml
  echo "<openbox_menu xmlns='http://openbox.org/'" | tee -a /etc/xdg/openbox/menu.xml
  echo "        xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'" | tee -a /etc/xdg/openbox/menu.xml
  echo "        xsi:schemaLocation='http://openbox.org/" | tee -a /etc/xdg/openbox/menu.xml
  echo "                file:///usr/share/openbox/menu.xsd'>" | tee -a /etc/xdg/openbox/menu.xml
  echo "" | tee -a /etc/xdg/openbox/menu.xml
  echo "<menu id='root-menu' label='Openbox 3'>" | tee -a /etc/xdg/openbox/menu.xml
  echo " <item label='Riavvia'>" | tee -a /etc/xdg/openbox/menu.xml
  echo "    <action name='Execute'>" | tee -a /etc/xdg/openbox/menu.xml
  echo "	<command>sudo reboot</command>" | tee -a /etc/xdg/openbox/menu.xml
  echo "    </action>" | tee -a /etc/xdg/openbox/menu.xml
  echo "  </item>" | tee -a /etc/xdg/openbox/menu.xml
  echo " <item label='Spegni'>" | tee -a /etc/xdg/openbox/menu.xml
  echo "    <action name='Execute'>" | tee -a /etc/xdg/openbox/menu.xml
  echo "	<command>sudo halt</command>" | tee -a /etc/xdg/openbox/menu.xml
  echo "    </action>" | tee -a /etc/xdg/openbox/menu.xml
  echo "  </item>" | tee -a /etc/xdg/openbox/menu.xml
  echo "</menu>" | tee -a /etc/xdg/openbox/menu.xml
  echo "" | tee -a /etc/xdg/openbox/menu.xml
  echo "</openbox_menu>" | tee -a /etc/xdg/openbox/menu.xml
}

creo_pagina() {
  echo
  echo
  echo "########################################################################"
  echo "#                                                                      #"
  echo "#  Costruisco una pagina di esempio                                    #"
  echo "#                                                                      #"
  echo "#  La pagina è raggiungibile al seguente percorso per la sua modifica  #"
  echo "#                                                                      #"
  echo "#  /var/www/html/index.html                                            #"  
  echo "#                                                                      #"
  echo "########################################################################"
  cp /var/www/html/index.html /var/www/html/index.original
  #----------------------------------------------------------------------------
  #
  #            inizia la pagina
  #
  #----------------------------------------------------------------------------
  echo "<html>" > /var/www/html/index.html
  echo "" | tee -a /var/www/html/index.html
  echo "<head>" | tee -a /var/www/html/index.html
  echo "<title>Chiosco</title>" | tee -a /var/www/html/index.html
  echo "</head>" | tee -a /var/www/html/index.html
  echo "" | tee -a /var/www/html/index.html
  echo "<body>" | tee -a /var/www/html/index.html
  echo "" | tee -a /var/www/html/index.html
  echo "<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%'>" | tee -a /var/www/html/index.html
  echo "  <tr>" | tee -a /var/www/html/index.html
  echo "    <td width='100%'>" | tee -a /var/www/html/index.html
  echo "    <h1 align='center'><font face='Courier New'>Qui inserisci il banner</font></h1>" | tee -a /var/www/html/index.html
  echo "    </td>" | tee -a /var/www/html/index.html
  echo "  </tr>" | tee -a /var/www/html/index.html
  echo "  <tr>" | tee -a /var/www/html/index.html
  echo "    <td width='100%' bgcolor='#0000FF'>" | tee -a /var/www/html/index.html
  echo "    <h1 align='center'><font face='Courier New' color='#FFFFFF'>Qui inserisci il titolo</font></h1>" | tee -a /var/www/html/index.html
  echo "    </td>" | tee -a /var/www/html/index.html
  echo "  </tr>" | tee -a /var/www/html/index.html
  echo "  <tr>" | tee -a /var/www/html/index.html
  echo "    <td width='100%'><h1><font face='Courier New'>Qui inserisci il link di una pagina. Esempio:<a href='http://172.16.1.4/orarioint'>Orario</a></font></h1></td>" | tee -a /var/www/html/index.html
  echo "  </tr>" | tee -a /var/www/html/index.html
  echo "  <tr>" | tee -a /var/www/html/index.html
  echo "    <td width='100%'><h1><font face='Courier New'>Qui inserisci il link di un altra pagina. Esempio:<a href='http://172.16.1.18'>Supplenze</a></font></h1></td>" | tee -a /var/www/html/index.html
  echo "  </tr>" | tee -a /var/www/html/index.html
  echo "</table>" | tee -a /var/www/html/index.html
  echo "" | tee -a /var/www/html/index.html
  echo "</body>" | tee -a /var/www/html/index.html
  echo "" | tee -a /var/www/html/index.html
  echo "</html>" | tee -a /var/www/html/index.html
}

do_configure_keyboard() {
  dpkg-reconfigure keyboard-configuration &&
  printf "Ricarica la mappa dei tasti. Questo potrebbe richiedere un po 'di tempo\n" &&
  invoke-rc.d keyboard-setup start
}

do_change_locale() {
  dpkg-reconfigure locales
}

do_change_timezone() {
  dpkg-reconfigure tzdata
}

preparoambiente (){
  git clone https://github.com/steferam/slideshowhtml.git
  cp -R slideshowhtml /var/www/html
  sudo chown -R www-data:www-data /var/www/html/slideshowhtml
  echo
  echo
  echo "########################################################################"
  echo "#                                                                      #"
  echo "#                   Installazione terminata                            #"
  echo "#                                                                      #"
  echo "#   sostituire le immagini in /var/www/html/slideshowhtml/media        #"
  echo "#                                                                      #"
  echo "#                                                                      #"
  echo "#   modificare la pagina /var/www/html/slideshowhtml/index.html        #"
  echo "#                                                                      #"
  echo "#                                                                      #"
  echo "#                                                                      #"
  echo "#                                                                      #"  
  echo "########################################################################" 
  read -p "Premere un tasto per riavviare" -n 1 -r  
}

procedo() {
  configura_pi
  installazione
  creo_web_pi
  preparo_GUI
  autostart
  ripulisco_openbox
  creo_pagina
  preparoambiente
  reboot
}

istruzioni
