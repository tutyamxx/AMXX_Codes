
/* --| Includem ce ne trebuie */
#include < amxmodx >
#include < amxmisc >
#include < sockets >

/* --| Fortam ";" la fiecare sfarsit de rand */
#pragma semicolon 1

/* --| Definim numele fisierului CFG si celuilalt LOG */
#define LOG_NUMEFISIER		"NovuslinkRedirect.log"
#define CFG_NUMEFISIER 		"NovuslinkRedirect.cfg"

/* --| Definim versiunea PLUGINULUI */
#define PLUGIN_VERSION 		"5.0.0"

/* --| Aici e ipul serverului tau! daca ipul din cfg nu e egal cu asta shutdown! */
#define SERVER_IP_LCENTA 	"80.96.216.57"

/* --| In cate secunde se va opri serverul daca nu are licenta valida */
#define SERVER_SECUNDE_OPRIRE 	31 
 
/* --| Aici scriem ce TAG sa ne apara cand vor aparea mesaje LOG si etc. */
#define TAG_PLUGIN 		"[Novuslink Redirect STATS]"

/* --| Aici sunt listate urmatoarele functii globale */
new gCvarRedirectIp;
new gCvarRedirectPort;
new gCvarRedirectPassword;
new gCvarRedirectHost;
new gCvarRedirectPath;
new gCvarRedirectUsername;
new gCvarRedirectUpdate;

new gRedirectHost[ 50 ];
new gRedirectName[ 50 ];
new gRedirectPath[ 50 ];

new gError;

public plugin_init()
{
	/* --| Inregistram pluginul sa apara in lista cand dam amx_plugins */
	register_plugin( "NovusLink Redirect STATS", PLUGIN_VERSION, "Novuslink TEAM" );
	
	/* --| Inregistram cvarurile care vor fi puse in fisierul CFG */
	gCvarRedirectIp = register_cvar( "novuslink_redirect_server", "80.96.216.57" );
	gCvarRedirectPort = register_cvar( "novuslink_redirect_serverport", "00000" );
	gCvarRedirectPassword = register_cvar( "novuslink_redirect_serverpw", "" );
	
	/* --| Inregistram cvarurile care vor trebui modificate de catre utilizator pentru a isi seta
	   --| Propria baza de date! */
	   
	gCvarRedirectHost = register_cvar( "novuslink_redirect_host", "www.novuslink.ro" );
	gCvarRedirectPath = register_cvar( "novuslink_redirect_path", "/webscript" );
	gCvarRedirectUsername = register_cvar( "novuslink_redirect_username", "Novuslink Default Username" );
	
	/* --| Aici setam la cate minute/secunde sa dea pluginul update in baza de date
	   --| Calculam asa:
	   --| 1 minut = 60 secunde
	   --| 15 minute = 15 * 60 = 900
	   --| Important! Ca sa mearga bine pluginul tre sa modifici aici jos secundele.. iei calculatoru si faci
	   --| Altfel nu va merge! */
	   
	gCvarRedirectUpdate = register_cvar( "novuslink_redirect_uptime", "900" );
	
	/* --| Aici e taskul care se repeta la secundele editate de dv, adica cele originale 900 = 15 minute */
	set_task( float( get_pcvar_num( gCvarRedirectUpdate ) ), "RedirectServer", _, _, _, "b" );
	
	/* --| Aflam IP-ul serverului care ruleaza */
	new szServerIp[ 40 ];
	get_pcvar_string( gCvarRedirectIp, szServerIp, charsmax( szServerIp ) );
	
	/* --| Daca IP-ul serverului nu este egal cu cel din fisierul CFG atunci facem urmatoarele lucruri! */
	if( !equal( szServerIp, SERVER_IP_LCENTA ) )
	{
		/* --| Afisam niste mesaje in consola serverului */
		server_print( "%s Nu detii o licenta valabila! Serverul se va opri in %d secunde!", TAG_PLUGIN, SERVER_SECUNDE_OPRIRE );
		server_print( "%s Pentru mai multe detalii acceseaza http://www.novuslink.ro", TAG_PLUGIN );
		
		/* --| Setam un task, ca dupa ce au trecut secundele setare, original = 31, atunci oprim serverul */
		set_task( float( SERVER_SECUNDE_OPRIRE ), "ServerShutDown" );
	}
	
	/* --| Iar daca IP-lu serverului este egal cu cel din fisieurl CFG facem urmatoarele lucruri */
	else
	{
		/* --| Afisam niste mesaje in consola serverului */
		server_print( "%s Felicitari! Detii o licenta valida, iar pluginul functioneaza perfect!", TAG_PLUGIN );
		server_print( "%s Pentru mai multe detalii acceseaza http://www.novuslink.ro", TAG_PLUGIN );
		
		/* --| Creem un fisier log separat, si afisam in el urmatoarele mesaje: */
		log_to_file( LOG_NUMEFISIER, "%s Felicitari! Detii o licenta valida, iar pluginul functioneaza perfect!", TAG_PLUGIN );
		log_to_file( LOG_NUMEFISIER, "%s Pentru mai multe detalii acceseaza http://www.novuslink.ro", TAG_PLUGIN );
	}
}

public plugin_cfg()
{
	/* --| Aflam directorul "configs" din folderul amxmodx/, si fisierul CFG! */
	new szConfigsDir[ 32 ];
	new szFile[ 192 ];
	
	get_configsdir( szConfigsDir, charsmax( szConfigsDir ) );
	formatex( szFile, charsmax( szFile ), "%s/%s", szConfigsDir, CFG_NUMEFISIER );
	
	/* --| Daca fisierul CFG exista atunci executam cvarurile din el */
	if( file_exists( szFile ) )
	{
		/* --| Executam fisierul CFG */
		server_cmd( "exec %s", szFile );
		
		/* --| Trimitem un mesaj de succes in consola serverului si in fisierul LOG */
		server_print( "%s Fisierul ^"%s^" a fost incarcat cu succes!", TAG_PLUGIN, szFile );
		log_to_file( LOG_NUMEFISIER, "%s Fisierul <%s> a fost incarcat cu succes!", TAG_PLUGIN, szFile );
	}
	
	/* --| Daca fisierul CFG nu exista, atunci facem urmatoarele lucruri! */
	else
	{
		/* --| Trimitem un mesaj de eroare in consola serverului si in fisierul LOG, ca fisierul CFG nu exista! */
		server_print( "%s Eroare! Fisierul ^"%s^" nu a fost gasit!", TAG_PLUGIN, szFile );
		log_to_file( LOG_NUMEFISIER, "%s Eroare! Fisierul ^"%s^" nu a fost gasit!", TAG_PLUGIN, szFile );
	}
}

public RedirectServer()
{
	/* --| Aflam PORT-ul serverului */
 	/* --| Nu folosim PCVAR pentru port, deoarece il utilizam doar odata in acest plugin */

	new RedirectPort[ 10 ];
	get_cvar_string( "port", RedirectPort, charsmax( RedirectPort ) );
	
	/* --| Reluam cvarurile pentru baza de date */
	get_pcvar_string( gCvarRedirectHost, gRedirectHost, charsmax( gRedirectHost ) );
	get_pcvar_string( gCvarRedirectPath, gRedirectPath, charsmax( gRedirectPath ) );
	get_pcvar_string( gCvarRedirectUsername, gRedirectName, charsmax( gRedirectName ) );
	
	/* --| Practic, aici nu e nevoie sa explic tot ce se intampla, deoarece e simplu
	   --| In acest public, serverul face update la scripturile web si trimite noile informatii */
	   
	new RedirectSocket = socket_open( gRedirectHost, 80, SOCKET_TCP, gError);
	
	new szData[ 512 ];
	formatex( szData, charsmax( szData ), "GET %s/alive.php?p=%s&f=%s HTTP/1.1^r^nHost:%s^r^nConnection: close^r^n^r^n", gRedirectPath, RedirectPort, gRedirectName, gRedirectHost );
	
	socket_send( RedirectSocket, szData, charsmax( szData ) );
}

public ServerPlayers()
{
	/* --| Urcam numarul de redirectionati in baza de date web! */
	
	/* --| Luam cvarurile pentru baza de date */
	get_pcvar_string( gCvarRedirectHost, gRedirectHost, charsmax( gRedirectHost ) );
	get_pcvar_string( gCvarRedirectPath, gRedirectPath, charsmax( gRedirectPath ) );
	get_pcvar_string( gCvarRedirectUsername, gRedirectName, charsmax( gRedirectName ) );
	
	/* --| Nici aici nu mai e nimic de explicat, doar comunicam cu baza de date!
	   --| Practic, urcam noii jucatori redirectionati, si reimprospatam baza de date! */
	   
	new PlayerSocket = socket_open( gRedirectHost, 80, SOCKET_TCP, gError);
	
	new PlayerCount[ 512 ];
	formatex( PlayerCount, charsmax( PlayerCount ), "GET %s/new.php?f=%s HTTP/1.1^r^nHost:%s^r^nConnection: close^r^n^r^n", gRedirectPath, gRedirectName, gRedirectHost );
	
	socket_send( PlayerSocket, PlayerCount, charsmax( PlayerCount ) );
}

public ServerShutDown()
{
	/* --| Practic, aici oprim serverul deoarece nu detinem o licenta valida! */
	/* --| Trimitem comanda de exit la server, poate fi si 'quit' sau 'exit' e tot acelasi lucru! */
	
	server_cmd( "exit" );
	
	/* --| Afisam niste mesaje in fisierul LOG */
	log_to_file( LOG_NUMEFISIER, "%s Nu detii o licenta valabila! Serverul a fost oprit!", TAG_PLUGIN );
	log_to_file( LOG_NUMEFISIER, "%s Pentru mai multe detalii acceseaza http://www.novuslink.ro", TAG_PLUGIN );
}

public client_connect( id )
{
	/* --| Cand se conecteaza un jucator pe server.. */
	
	/* --| Luam parola serverului */
	new szServerPassword[ 30 ];
	get_pcvar_string( gCvarRedirectPassword, szServerPassword, charsmax( szServerPassword ) );
	
	/* --| Luam IP-ul din fisierul CFG pentru a ii redirectiona pe acea adresa! */
	new szServerIp[ 32 ];
	get_pcvar_string( gCvarRedirectIp, szServerIp, charsmax( szServerIp ) );
	
	/* --| Verificam daca intradevar se conecteaza un jucator, si verificam daca nu e BOT */
	if( is_user_connecting( id ) && !is_user_bot( id ) )
	{
		/* --| Urcam numarul de redirectionati in baza de date web! */
		ServerPlayers();
	}
	
	/* --| Verificam jucatorii de pe server, iar daca sunt mai multi sau egali cu 0, atunci ii redirectionam
	   --| spre noul IP din fisierul CFG ! */

	if( get_playersnum() >= 0 )
	{
		/* --| Verificam daca serverul are o parola */
		if( !equal( szServerPassword, "" ) )
		{
			/* --| Setam parola din fisierul CFG jucatorului, ca sa se poata conecta pe server! */
			client_cmd( id, "password %s", szServerPassword );
		}
		
		/* --| Acum redirectionam jucatorul spre noua adresa din fisierul CFG */
		client_cmd( id, "Connect %s:%d", szServerIp, get_pcvar_num( gCvarRedirectPort ) );
	}
}
