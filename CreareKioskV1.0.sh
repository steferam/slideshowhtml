#!/bin/bash
# Scritto da Stefano Mercurio
# http://www.netlivein.it
version=1.0.0
#
# Preparazione scheda immagine lite
# https://downloads.raspberrypi.org/raspbian_lite_latest
#
sito="'http://172.16.1.4/orarioint/'"
sito="'http://www.netlivein.it'"


#####################################################################
# Da fare per nuova versione
#
# chiede conferma per fare aggiornameno
# opzionale chiedere sito per configurazione
# opzionale valutare scrpt per installare webserber per funzionare autonomamente 
# valutare se automatizzare configurazione iniziale (espansione file system)
#
#
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
  echo "#    Script per automatizzare la realizaione di un chiosco Mercurio    #"
  echo "#                                                                      #"
  echo "#       che apre una pagina web ('http://172.16.1.4/orarioint/')       #"
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
  raspi-config
}

installazione() {
  apt-get update
  apt-get upgrade -y
  apt-get install openbox -y
  apt-get install xorg -y
  apt-get install python-webkit -y
}

creo_web_pi() {
  echo "#!/usr/bin/env python" > /usr/bin/web.py
  echo >> /usr/bin/web.py
  echo "import gtk, webkit" >> /usr/bin/web.py
  echo >> /usr/bin/web.py
  echo "win = gtk.Window()" >> /usr/bin/web.py
  echo "win.connect('destroy', lambda w: gtk.main_quit())" >> /usr/bin/web.py
  echo >> /usr/bin/web.py
  echo "win.fullscreen()" >> /usr/bin/web.py
  echo >> /usr/bin/web.py
  echo "scroller = gtk.ScrolledWindow()" >> /usr/bin/web.py
  echo "web = webkit.WebView()" >> /usr/bin/web.py
  echo >> /usr/bin/web.py
  echo "web.open("$sito")" >> /usr/bin/web.py
  echo >> /usr/bin/web.py
  echo "win.add(scroller)" >> /usr/bin/web.py
  echo "scroller.add(web)" >> /usr/bin/web.py
  echo >> /usr/bin/web.py
  echo "win.show_all()" >> /usr/bin/web.py
  echo >> /usr/bin/web.py
  echo "gtk.main()" >> /usr/bin/web.py
  chmod +x /usr/bin/web.py
}

preparo_GUI() {
  echo "#!/bin/sh" > /etc/init.d/kiosk
  echo "### BEGIN INIT INFO" >> /etc/init.d/kiosk
  echo "# Provides:          kiosk" >> /etc/init.d/kiosk
  echo "# Required-Start:    " >> /etc/init.d/kiosk
  echo "# Required-Stop:     " >> /etc/init.d/kiosk
  echo "# Default-Start:     2 3 4 5" >> /etc/init.d/kiosk
  echo "# Default-Stop:      0 1 6" >> /etc/init.d/kiosk
  echo "# Short-Description: Il totem Netlivein" >> /etc/init.d/kiosk
  echo "# Description:       Totem per la sola navigazione internet" >> /etc/init.d/kiosk
  echo "### END INIT INFO" >> /etc/init.d/kiosk
  echo  >> /etc/init.d/kiosk
  echo "startx" >> /etc/init.d/kiosk
  chmod +x /etc/init.d/kiosk
  update-rc.d kiosk defaults
}

autostart() {
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
  echo > /etc/xdg/openbox/menu.xml
  echo "<?xml version='1.0' encoding='UTF-8'?>" >> /etc/xdg/openbox/menu.xml
  echo >> /etc/xdg/openbox/menu.xml
  echo "<openbox_menu xmlns='http://openbox.org/'" >> /etc/xdg/openbox/menu.xml
  echo "        xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'" >> /etc/xdg/openbox/menu.xml
  echo "        xsi:schemaLocation='http://openbox.org/" >> /etc/xdg/openbox/menu.xml
  echo "                file:///usr/share/openbox/menu.xsd'>" >> /etc/xdg/openbox/menu.xml
  echo >> /etc/xdg/openbox/menu.xml
  echo "<menu id='root-menu' label='Openbox 3'>" >> /etc/xdg/openbox/menu.xml
  echo " <item label='Riavvia'>" >> /etc/xdg/openbox/menu.xml
  echo "    <action name='Execute'>" >> /etc/xdg/openbox/menu.xml
  echo "	<command>sudo reboot</command>" >> /etc/xdg/openbox/menu.xml
  echo "    </action>" >> /etc/xdg/openbox/menu.xml
  echo "  </item>" >> /etc/xdg/openbox/menu.xml
  echo " <item label='Spegni'>" >> /etc/xdg/openbox/menu.xml
  echo "    <action name='Execute'>" >> /etc/xdg/openbox/menu.xml
  echo "	<command>sudo halt</command>" >> /etc/xdg/openbox/menu.xml
  echo "    </action>" >> /etc/xdg/openbox/menu.xml
  echo "  </item>" >> /etc/xdg/openbox/menu.xml
  echo "</menu>" >> /etc/xdg/openbox/menu.xml
  echo >> /etc/xdg/openbox/menu.xml
  echo "</openbox_menu>" >> /etc/xdg/openbox/menu.xml
}

procedo() {
  #echo $sito
  configura_pi
  installazione
  creo_web_pi
  preparo_GUI
  autostart
  ripulisco_openbox
  reboot
}

istruzioni