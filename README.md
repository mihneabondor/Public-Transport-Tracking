## Securitatea Datelor:
Busify evită pe cât posibil să lucreze cu date cu caracter personal, aceste este și motivul pentru care evit să introduc un sistem de creare de conturi. Singurele date pe care Busify le colectează sunt, ocazional, locațiile dispozitivelor, pentru statistică și analiza pieței. Aceste statistici sunt folosit cu scop de a afla în care parte a orașului se află cea mai multă activitate a aplicației și unde ar trebui insistat cu partea de marketing.

Doarece Busify nu lucrează cu date cu caracter personal, este posibilă implementarea algoritmului de peer connectivity (mai multe detalii în documentație).

Apelurile dispozitivelor la server-ul Busify sunt complet sigure, folosind criptarea standard utf8. Dispozitivele vor trimit o cerere server-ului, server-ul va trimite datele, iar apoi aceste va primi înapoi "OK" din partea acelui dispozitiv, fiind singura dată care iese din telefon în urma refresh-ului. După primirea confirmării din partea dispozitivului, pentru a economisi baterie, server-ul va închide sesiunea cu acel dispozitiv și o va redeschide abia la următorul refresh.

## Echipă:
Mihnea Bondor este singura persoană care a contribuit la crearea versiunii de iOS a aplicației Busify.

## Date externe: 📖
Datele care descriu un program special sunt scrise manual și postate într-un fișier pe site-ul aplicației, la care aplicația face apel pentru a verifica noutăți de fiecare dată când este deschisă. Știrile sunt preluate de pe server-ul RSS public, fiind aceeași sursă ca și cea de pe site-ul oficial [CTP](https://ctpcj.ro/index.php/ro/).

ETA-ul este calculat dinamic, în funcție de viteza vehiculului, distanța între el și user și datele despre trafic pe ruta acelui vehicul (provenit prin API-ul de la Google Maps explicat mai jos).

Informațiile despre direcții provin de la API-ul de direcții de la Google Maps, fiind în esență un alt server la care se fac apeluri folosing cheia privată, coordonatele de început, coordonatele destinației și tipul de călătorie dorit (adică transport în comun). https://developers.google.com/maps/documentation/directions/overview

Informațiile despre vehicule provin de la nou API Tranzy, la care m-am alăturat încă de la lansare și la care am ajutat prin testare continuă și feedback constructiv pentru a rezolvare potențialele erori. De menționat este faptul că harta site-ului oficial CTP folosește aceeași sursă precum Busify. https://tranzy.ai/
   
Doarece implementarea oficială a achizițiilor în aplicație este complexă, folosesc un serviciu extern numit RevenueCat, care înlocuiește clase întregi de cod în cateva linii, iar restul se face pe site-ul lor oficial într-o manieră mai intuitivă și ușor de înțeles. https://www.revenuecat.com/

Notificările dinamice provin de la un serviciu de încredere pe care l-am folosit și în alte proiecte numit OneSignal. În concordanță cu acest serviciu folosesc Zapier pentru a “asculta” server-ul RSS pentru noi articole. Când se ivește o nouă știre, Zapier trimite o notificare către OneSignal care creează o notificare și o trimite tuturor utilizatorilor care au acceptat să primească astfel de notificări. https://zapier.com/ https://onesignal.com/

Server-ul propriu este oferit de către DigitalOcean și momentan se află în Varșovia, folosit la stocarea datelor din server-ele oficiale și la care se conectează fiecare dispozitiv în momentul deschiderii aplicației. https://www.digitalocean.com/
