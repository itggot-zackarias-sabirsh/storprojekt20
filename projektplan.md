# Projektplan

## 1. Projektbeskrivning (Beskriv vad sidan ska kunna göra)
Jag har gjort ett forum likt twitter, där användare kan lägga upp korta stycken text. Dessa poster är tilldelade tags. Användare kan radera och redigera sina egna poster och om man har adminbehörigheter kan man radera allas poster.
## 2. Vyer (visa bildskisser på dina sidor)

## 3. Databas med ER-diagram (Bild)
se misc mapp
## 4. Arkitektur (Beskriv filer och mappar - vad gör/inehåller de?)
layout.slim
    Layoutfilen skapar en kosekvent header för alla sidor, den har även en del teknisk funktionalitet, exempelvis att länka alla slim-dokument till ett css-dokument.

start.slim
    Denna fil är det första en användare möter, ett inloggningsformuläret för att komma vidare till nästa del.

home.slim
    Denna fil är huvuddelen av hemsidan. Det är här användare kan se, skapa, redigera och radera poster.

error.slim
    Visar upp ev.error. Exempelvis om man skriver fel lösenord.


