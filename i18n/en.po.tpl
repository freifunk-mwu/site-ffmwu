msgid ""
msgstr ""
"Content-Type: text/plain; charset=UTF-8\n"
"Project-Id-Version: PACKAGE VERSION\n"
"PO-Revision-Date: 2015-03-23 17:07+0100\n"
"Last-Translator: Tobias Hachmer <tobias@hachmer.de>\n"
"Language-Team: English\n"
"Language: en\n"
"MIME-Version: 1.0\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=(n != 1);\n"

msgid "gluon-config-mode:welcome"
msgstr ""
"Welcome! This is the configuration wizard of your new Freifunk node in ${city}.<br />"
"<p>Complete this form as you like and send it afterwards.</p>"
"<dl>"
"<dt>Hostname</dt>"
"<dd>Choose a creative hostname (e.g.locations, food, persons or characters of a TV series - the fancier the better). "
"Avoid hostnames which exist already. Allowed are only the letters A-Za-z and as a special character \"-\".</dd>"
"<dt>Auto-Update</dt>"
"<dd>It is not expulsed that something weird happens to your node while it is performing an Auto-Update. "
"However, we encourage you to enable this very helpful function which is enabled by default.</dd>"
"<dt>E-Mail</dt>"
"<dd>It is up to you to state your e-mail address or something else which help us to contact you in cases we need to. "
"Have in mind that the contact will be public visible.</dd>"
"</dl><br />"

msgid "gluon-config-mode:pubkey"
msgstr ""
"This is the public key which belongs to your node. It has to be activated first before your node "
"will be able to connect to the Freifunk network in ${city} through the Internet.<br />"
"Please send this key and the key of this node (<em><%=hostname%></em>) to "
"<a href="mailto:${descr_mailkeys}?&amp;subject=New%20Freifunk%20node%3A%20<%=hostname%>&amp;body=Name%3A%20<%=hostname%>%0D%0AKey%3A%20<%=pubkey%>%0D%0AMAC%3A%20<%=sysconfig.primary_mac%>%0D%0A">${descr_mailkeys}</a>.<br />"
"<small>One click on the e-mail link should open your e-mail application and a new e-mail form filled in with all relevant information.</small><br />"
"Please beautify this mail with some fancy information, e.g. the actual weather, nice stuff about your pet or your motivation participating with Freifunk. "
"Whatever, just something to sweeten the boring work of the guys who activate your vpn key. Thanks in advance!"

msgid "gluon-config-mode:reboot"
msgstr ""
"Your node is currently rebooting and will connect to Freifunk nodes within wifi reach afterwards. "
"If you have activated the vpn function your node will connect to the Freifunk network through the internet "
"after whether the vpn public key is activated.<br />"
"You can obtain further information about the local Freifunk community in ${city} from the webpage "
"<a href="http://${descr_url}/">${site_name}</a><br />"
"Have a lot fun exploring Freifunk in ${city}!<br />"
