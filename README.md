# Wazuh, open source SIEM/XDR

## 0. Garść informacji na początek.
- SIEM, ang. Security Information and Event Management to rozwiązanie, które zbiera, agreguje i analizuje dane z różnych źródeł w organizacji, takich jak aplikacje, urządzenia, serwery czy użytkownicy. SIEM umożliwia monitorowanie w czasie rzeczywistym, identyfikację zagrożeń oraz reagowanie na incydenty bezpieczeństwa. Jest kluczowym narzędziem w centrach operacji bezpieczeństwa (SOC), pomagając organizacjom w spełnianiu wymogów zgodności i ochronie przed cyberzagrożeniami. 
- XDR, ang. Extended Detection and Response to zaawansowana technologia cyberbezpieczeństwa, która integruje dane z różnych warstw bezpieczeństwa, takich jak punkty końcowe, sieci, chmury czy aplikacje. XDR umożliwia wykrywanie, analizowanie i reagowanie na zagrożenia w sposób zautomatyzowany i skoordynowany. Dzięki temu organizacje mogą szybciej identyfikować i neutralizować zaawansowane ataki.
- SOAR, ang. Security Orchestration, Automation, and Response to narzędzie, które automatyzuje procesy związane z zarządzaniem incydentami bezpieczeństwa. SOAR integruje różne systemy bezpieczeństwa, umożliwiając ich współpracę, oraz automatyzuje powtarzalne zadania, co pozwala zespołom SOC skupić się na bardziej złożonych problemach. Dzięki temu zwiększa się efektywność operacji bezpieczeństwa i skraca czas reakcji na zagrożenia

## 1. Czym jest Wazuh, open source SIEM/XDR i jakie problemy rozwiązuje.
Wazuh to otwartoźródłowa platforma bezpieczeństwa, która łączy funkcje SIEM (Security Information and Event Management) oraz XDR (Extended Detection and Response). Jest to kompleksowe narzędzie do monitorowania, wykrywania i reagowania na zagrożenia w środowiskach lokalnych, wirtualnych, kontenerowych oraz chmurowych. Wazuh to rozwiązanie, które umożliwia organizacjom monitorowanie infrastruktury IT, analizowanie danych logów oraz reagowanie na incydenty bezpieczeństwa. Rozproszona architektura liczona często w tysiącach maszyn fizycznych i wirtualnych, dostęp do środowisk powoduje iż monitoring administracyjny jest niewystarczający - skupia się też na innych zadaniach. Wazuh jak już wyżej wspomniano jest rozwiązaniem typu SIEM/XDR, a więc potrafi rozpoznać na podstawie wzorców zagrożenia i potrafi je interpretować, XDR zaś odpowiada za możliwość reagowania na zaistniały incydent.

**Przykład**
Monitorujemy dostęp do serwera poprzez SSH. SIEM informuje nas o fakcie wielokrotnych prób logowania z danego adresu IP. Następnie, po wielu próbach następuje skuteczne logowanie z tego adresu. Zadajmy zatem pytanie, czy był to atak, czy też niefrasobliwy legalny użytkownik zwyczajnie miał problem z logowaniem, bo albo zapomniał hasła, albo mu klucz przestał działać itd. Oceną i reakcją na powyższe zdarzenie powinien się zająć Wazuh, a dokładniej jego reguły XDR. To Wazuh powinien podjąć decyzję (oczywiście nie jest ona obecnie autonomiczna) o tym, czy zablokować taki adres IP z uwagi na wysokie prawdopodobieństwo przełamania zabezpieczeń użytkownika SSH. 

Przykład ten, oczywiście pozbawiony jest wielu narzędzi administracyjnych z których korzystmy, nie mniej jednak pokazuje potrzebę analizy wielu aspektów nie tylko związanych z podatnościami. 

---

### Komponenty Wazuh:
- Agenci Wazuh: instalowani na punktach końcowych, zbierają dane z logów, konfiguracji systemów i aplikacji.
- Serwer Wazuh: analizuje dane zebrane przez agentów, wykorzystując reguły i dekodery do identyfikacji zagrożeń.
- Indekser Wazuh: indeksuje i przechowuje dane, umożliwiając ich szybkie przeszukiwanie.
- Dashboard Wazuh: interfejs użytkownika do wizualizacji danych, zarządzania konfiguracją i monitorowania stanu systemu.

![Komponenty](https://documentation.wazuh.com/current/_images/wazuh-components-and-data-flow1.png)


## 2. Wymagania środowiskowe i szybka instalacja
Oczywiście wymagania mocno zależą od kilku kluczowych czynników, tj. ilości agentów, ilości przetwarzanych danych, czasu przechowywania tychże danych - retencja danych. Należy również wziąć pod uwagę czy Wazuh jest instalowany jednowęzłowo, czy w klastrze. W przypadku klastra zasoby wymagane do płynnej i sprawnej obsługi będą zwielokrotnione co podwyższa koszt administracyjny narzędzia. Nie mniej jednak na potrzeby naszego szkolenia uruchomimy jeden węzeł Wazuh na którym będą pracować wszystkie komponenty. Zatem do dzieła.


- Uruchom maszynę wirtualną w oparciu o kontener LXC.

[Terraform LXD - provider](https://github.com/terraform-lxd/terraform-provider-lxd)

> Krótkie wyjaśnienie poniższego polecenia. Uruchamiam maszynę wirtualną `--vm` na bazie obrazu `Ubuntu 22.04` na przygotowanym wcześniej dysku `-s nex`. Użyto limity dla CPU `limits.cpu=4` oraz limity dla pamięci RAM `limits.memory=8GB`. Dysk pod naszego "Wazuha" ustawiono na 100GB `-d root,size=100GB`. 

**UWAGA!, możesz pominąć `-s nex` jeśli posiadacz wystarczająco dużo miejsca na domyślnym zasobie**

```bash
lxc launch ubuntu:22.04 s1 --vm -s nex -c limits.cpu=4 -c limits.memory=8GB -d root,size=100GB
```

- Następnie, po utworzeniu maszyny wirtualnej wykonujemy następujące polecenia: update i upgrade systemu oraz pobranie skryptu instalacyjnego i instalacja wszystkich komponentów na maszynie jednowęzłowej.

```bash
apt update && apt upgrade --y
curl -sO https://packages.wazuh.com/4.11/wazuh-install.sh && bash ./wazuh-install.sh -a
```

**UWAGA! Na koniec instalacji, w terminalu zostanie wyświetlone hasło dla użytkownika "admin"**

## 3. Co warto wykonać po instalacji.
Z uwagi na wysoką krytyczność usługi dla organizacji warto zadbać o zmianę haseł. Do tego celu służy przygotowany skrypt, który w sposób automatyczny wygeneruje nowe hasła i przypisze je do poszczególnych komponentów.

- Poniższe polecenie zapisze do pliku zewnętrznego wszystkie zmienione hasła.
```bash
lxc exec s1 -- ./wazuh-passwords-tool.sh -a > ~/Wazuh-$(date +%Y%m%d%H%M)
```

Z pewnością warto zmienić tryb wyświetlania na ciemny. W tym celu przechodzimy 
- Dashboard
`Menu > Dashboards Management > Advanced settings > Appearance`


## 4. Dostęp agentowy i bezagentowy.
Agent Wazuh to kluczowy komponent platformy Wazuh, który jest instalowany na monitorowanych urządzeniach końcowych, takich jak serwery, komputery czy urządzenia sieciowe. Jego głównym zadaniem jest zbieranie danych związanych z bezpieczeństwem i przesyłanie ich do serwera Wazuh w celu analizy.

- Jednym ze sposobów instalacji jest pobranie paczki poprzez przygotowane polecenie dla dowolnego dostępnego systemu. Poniżej polecenie pobierające paczkę przy pomocy aplikacji `wget` oraz instalacja pakietu wraz ze wskazaniem adresu mangera Wazuh, czyli serwera Wazuh.

```bash
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.11.1-1_amd64.deb && sudo WAZUH_MANAGER='wazuh.lxc' dpkg -i ./wazuh-agent_4.11.1-1_amd64.deb
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

- Agentless to funkcja, która pozwala monitorować urządzenia końcowe bez konieczności instalowania na nich agenta. Zamiast tego, Wazuh wykorzystuje istniejące protokoły, takie jak SSH (Secure Shell), aby uzyskać dostęp do danych i przesyłać je do serwera Wazuh. Dzięki temu można monitorować urządzenia, na których instalacja dodatkowego oprogramowania jest niemożliwa lub niepożądana, takie jak routery, zapory sieciowe, przełączniki czy systemy Linux/BSD

[Dokumentacja połączenia w tybie agentless](https://documentation.wazuh.com/current/user-manual/capabilities/agentless-monitoring/connection.html)

Listę dostępnych hostów w trybie agentless możemy przejrzeć na serwerze wywołując polecenie
```bash
/var/ossec/agentless/register_host.sh list
```

## 5. Dane, dane i jeszcze raz dane, czyli jakie informacje przetwarzamy

- Fragment konfiguracji agenta Wazuh w lokalizacji /var/ossec/etc/ossec.conf
```
 <!-- File integrity monitoring -->
  <syscheck>
    <disabled>no</disabled>

    <!-- Frequency that syscheck is executed default every 12 hours -->
    <frequency>43200</frequency>

    <scan_on_start>yes</scan_on_start>

    <!-- Directories to check  (perform all possible verifications) -->
    <directories>/etc,/usr/bin,/usr/sbin</directories>
    <directories>/bin,/sbin,/boot</directories>

    <!-- Files/directories to ignore -->
    <ignore>/etc/mtab</ignore>
    <ignore>/etc/hosts.deny</ignore>
```

## 6. Wymogi zmian