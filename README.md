# DevOps_exam 

* oppgave 1
** a https://cfdxyornhb.execute-api.eu-west-1.amazonaws.com/Prod/generate
** b https://github.com/mbjobb/DevOps_exam/actions/runs/12024143533
* oppgave 2
** push til main https://github.com/mbjobb/DevOps_exam/actions/runs/12024277081
** push til no-apply-only-plan https://github.com/mbjobb/DevOps_exam/actions/runs/12024303280
** SQS kø URL https://sqs.eu-west-1.amazonaws.com/244530008913/knr14_Lambda_SQS
* oppgave 3
** Taggestrategi: henter ut versjon fra github eller bruker v0.0.1 som fallback dersom repo'et ikke har en versjon. Dette gir muligheten for automatisk semantisk versjonering av dockerhub imaget som samsvarer med gihub versjonen, men kan gjøre latest ustabil, etter som det fortsatt kan skje endringer der.
** https://sqs.eu-west-1.amazonaws.com/244530008913/knr14_Lambda_SQS    mbjobb/sqs_prompt_as_argument 
* oppgave 5
1. ** Automatisering og kontinuerlig levering (CI/CD)
Serverless arkitektur kan gjøre det både enklere og raskere å deploye, siden deployment og byggingen av infrastrukturen kan være en del av CI/CD pipelinen. AWS har også støtte for blå/grønn deployment, samt at det finnes ferdige løsninger både for kanarifugl deployment og feature toggles.
Vi har ikke vært borti kubernetes, så den opplevelsen vi har av mikrotjenester er manuell deployment fra docker images. Det er mulig å gjøre blå/grønn deployment, samt delvis oppgradering av kjørende tjenster, men det er en relativt manuell prosess og krever at gatewayen og data access layeret var designet for det.
2. ** Observability (overvåkning)
Mye av loggingen er gjort relativt automatisk i aws, og siden en serverless arkitektur er basert på å dele ting opp i så små og separate biter som mulig gjør det det relativt lett å overvåke enkelte deler av systemet. To spesifikke utfordringer for FaaS arkitekturer er at det både kan være vanskelig å samle logger, og at man ikke har nødvendigvis har disse lokalt, eller tillgang til hardwaren det blir lagret i.
Dersom loggene er lagret i skyen har man heller ikke tilgang til dem når provideren er nede, og det er jo ett prima eksempel på en situasjon man gjerne vill ha tillgang til dem. Serverless arkitektur gjør det også vanskelig å å følge data fra start til slutt, og se hvordan den muterer på veien, og siden kostnadene er basert på minne og kjøretid er det lett å bli fristet til å ikke håndtere det.
Det at både resursene og hvilken availability zone ting kjører i kan variere gjør også observability vanskligere i en serverless sammenheng.
3. ** Skalerbarhet og kostnadskontroll
Serverless er uten tvil enklest å skalere, og om man enten har god innsikt i- eller stor variasjon i ressurskravene kan det være kostnadseffektivt. Det er også en veldig billig måte å få noe opp og kjøre, så man kan få pengeflyt.
Ulempene er at kostnadene kan spinne ut av kontroll. Har sett en del reddit posts og memes om folk som glemte å stenge ned en instans, og endte opp med syke regninger. Det er også fare for at man leaker credentials.
Når det kommer til ressursutnyttelse har serverless en fordel i at man kan provisjonere det man trenger, og skalere raskt etter behov. 
4. ** Eierskap og ansvar
Her det mindre forskjell mellom de to. Man har vell mer tilgjenlighet i en serverless arkitektur, men servere kan også være eksternt tilgjenelig både gjennom VPN og SSH. Det viiktigste her er at uvikler, drifter og tester har blitt slått sammen til ett og samme team. Dette gjør det enklere å ta personlig anvsar ettersom det er deg selv du skyter i foten når du slurver. Skin in the game som foreleseren vår er glad i å si.
Man har ikke lenger noen andre å skylde på, og ender derfor opp med mange muligheter til både å lære og utvikle seg selv.
