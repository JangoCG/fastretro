# Datenschutzerklärung / Privacy Policy

*English version below – englische Version weiter unten*

---

# Datenschutzerklärung für **Fast Retro**

**Stand:** 20. Juni 2025

## 1. Verantwortlicher

Cengiz Gürtusgil
Angelika-Machinek-Str. 20, 60486 Frankfurt am Main, Deutschland  
E-Mail: cengiz@gurtus.com  
Datenschutz-Anfragen: cengiz@gurtus.com  
Web: <https://fastretro.app>

---

## 2. Zusammenfassung

* **Fast Retro** ist ein kostenloses Open-Source-Tool für agile Retrospektiven. Der Quellcode ist öffentlich einsehbar,
  sodass die Datenverarbeitung transparent nachvollzogen werden kann.
* **Keine Registrierung nötig** – zur Teilnahme reicht ein frei wählbarer Name / Nickname.
* Es werden **nur technisch notwendige Daten** verarbeitet.
* **Serverstandort:** Deutschland (Hetzner).
* **CDN / DDoS-Schutz:** Cloudflare (USA). Cloudflare ist nach dem EU-US Data Privacy Framework zertifiziert.
* Alle Verbindungen sind **TLS-verschlüsselt**.
* **Keine Tracking- oder Marketing-Cookies** → kein Cookie-Banner erforderlich.
* Unsere Auftragsverarbeiter implementieren umfassende technische und organisatorische Maßnahmen gemäß Art. 32 DSGVO,
  einschließlich Verschlüsselung, Zugangskontrollen und regelmäßiger Sicherheitsaudits.

---

## 3. Welche Daten wir verarbeiten

### 3.1 Automatisch übertragene Verbindungsdaten

* IP-Adresse, Datum / Uhrzeit, angeforderte URL, HTTP-Status, Referrer, Browser- und Betriebssysteminformationen.
* Zweck: Betriebssicherheit, Fehlerdiagnose, Abwehr von Angriffen, Performance-Optimierung.
* Speicherdauer:
    * Hetzner-Serverlogs werden nach **7 Tagen** gelöscht.
    * Cloudflare speichert Verbindungsdaten nur so lange, wie es für den jeweiligen Verarbeitungszweck erforderlich ist.
      Nach Zweckerreichung werden die Daten gelöscht oder anonymisiert. Cloudflare ist Auftragsverarbeiter gemäß Art. 28
      DSGVO und verpflichtet sich laut Data Processing Addendum zur Einhaltung technischer und organisatorischer
      Schutzmaßnahmen sowie zur Löschung oder Rückgabe aller personenbezogenen Daten nach Zweckerfüllung oder
      Vertragsende.

### 3.2 Daten innerhalb einer Retrospektive

* Name / Nickname (frei wählbar)
* Retrospektive-Inhalte (Karten, Kommentare, Votes)
* Raum-ID und Session-ID (Cookie) zur Zuordnung der Sitzung

### 3.3 Technisch notwendige Cookies

* `laravel_session` – hält die Sitzung; gelöscht beim Schließen des Browsers
* `XSRF-TOKEN` – CSRF-Schutz; gelöscht beim Schließen des Browsers
* `__cf_bm` – Cloudflare-Bot-Schutz; Laufzeit ca. 30 Minuten
* `__cfruid` – Cloudflare-Load-Balancing (nur in Fehlerfällen); Session-Ende

---

## 4. Rechtsgrundlagen

* **Art. 6 Abs. 1 lit. f DSGVO** – berechtigtes Interesse (IT-Sicherheit, Funktionsfähigkeit, Performance).
* **Art. 6 Abs. 1 lit. b DSGVO** – Bereitstellung der Retro-Funktion (quasi-vertragliche Pflicht).
* **Art. 6 Abs. 1 lit. c DSGVO** – gesetzliche Aufbewahrungs- bzw. Nachweispflichten (falls einschlägig).

---

## 5. Speicherdauer / Löschung

* Serverlogs bei Hetzner – Löschung nach **7 Tagen**.
* Verbindungsdaten bei Cloudflare – Speicherung nur solange erforderlich für den jeweiligen Zweck, anschließende
  Löschung oder Anonymisierung.
* Session-Cookie – endet mit dem Schließen des Browsers.
* Retrospektive-Inhalte und Name/Nickname – Löschung durch Moderator oder automatisch **90 Tage** nach letzter
  Aktivität.

---

## 6. Empfänger / Auftragsverarbeiter

### Hetzner Online GmbH (Deutschland)

* Hosting unseres Servers in ISO 27001-zertifizierten Rechenzentren.
* Auftragsverarbeitungsvertrag nach Art. 28 DSGVO liegt vor.
* Bei Nutzung von Serverstandorten außerhalb Deutschlands können lokale Rechenzentrumsbetreiber als Subunternehmer
  eingesetzt werden.
* Datenschutzerklärung: <https://www.hetzner.com/de/rechtliches/datenschutz>

### Cloudflare Inc. (USA)

* Content-Delivery-Network, TLS-Proxy, DDoS-Schutz.
* Zertifiziert nach dem EU-US Data Privacy Framework.
* Datentransfer in die USA erfolgt auf Basis:
* EU-Standardvertragsklauseln (EU SCCs)
* EU-US Data Privacy Framework
* Angemessenheitsbeschluss der EU-Kommission
* Cloudflare verpflichtet sich, personenbezogene Daten nur für die Erbringung der Services zu verarbeiten und nach
  Zweckerreichung zu löschen oder zurückzugeben.
* Datenschutzerklärung: <https://www.cloudflare.com/privacypolicy/>

### Simple Analytics B.V. (Niederlande)

* Privacy-freundliche Website-Analytik ohne Cookies oder persönliche Daten.
* **Keine personenbezogenen Daten:** Simple Analytics sammelt ausschließlich anonyme Metriken (Seitenaufrufe, Zeitzone 
  als Proxy für Land, anonymisierte User-Agents, UTM-Parameter).
* **Keine IP-Adressen:** IP-Adressen werden bei jeder Anfrage sofort verworfen, nicht gespeichert oder gehasht.
* **Keine Cookies:** Es werden keinerlei Tracking-Cookies oder ähnliche Technologien verwendet.
* **EU-Hosting:** Daten werden ausschließlich in den Niederlanden (EU) gespeichert bei DSGVO-konformen Anbietern.
* **Kein Consent erforderlich:** Da keine personenbezogenen Daten verarbeitet werden, ist keine Einwilligung nötig.
* Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse an Website-Optimierung).
* Datenschutzerklärung: <https://simpleanalytics.com/privacy>

Es erfolgt **keine Weitergabe** Ihrer Daten an sonstige Dritte, außer wir sind gesetzlich dazu verpflichtet.

---

## 7. Internationale Datenübertragungen

Bei der Nutzung von Cloudflare als CDN werden personenbezogene Daten in die USA übertragen. Diese Übertragung erfolgt
auf Basis:

* Der EU-Standardvertragsklauseln (Module 2: Controller to Processor)
* Des EU-US Data Privacy Framework, für das Cloudflare zertifiziert ist
* Zusätzlicher technischer und organisatorischer Schutzmaßnahmen gemäß dem Cloudflare Data Processing Addendum

---

## 8. Sicherheitsmaßnahmen

* TLS 1.2+-Verschlüsselung sämtlicher Verbindungen.
* DDoS- und Bot-Abwehr durch Cloudflare.
* Least-Privilege-Zugriffskonzepte, regelmäßige Sicherheits-Updates.
* Umfassende technische und organisatorische Maßnahmen bei unseren Auftragsverarbeitern:
    * Verschlüsselung bei Übertragung und Speicherung
    * Zugangs- und Zugriffskontrollen
    * Regelmäßige Sicherheitsaudits und Zertifizierungen (ISO 27001, SOC 2)
    * Incident-Response-Management
    * Datensicherung und Wiederherstellungsverfahren

---

## 9. Rechte der betroffenen Personen

Sie haben das Recht auf:

* **Auskunft** (Art. 15 DSGVO)
* **Berichtigung** (Art. 16 DSGVO)
* **Löschung** (Art. 17 DSGVO)
* **Einschränkung der Verarbeitung** (Art. 18 DSGVO)
* **Datenübertragbarkeit** (Art. 20 DSGVO)
* **Widerspruch** (Art. 21 DSGVO)

sowie das Recht auf **Beschwerde** bei der zuständigen Aufsichtsbehörde:

Der Hessische Beauftragte für Datenschutz und Informationsfreiheit  
Postfach 3163, 65021 Wiesbaden  
E-Mail: poststelle@datenschutz.hessen.de

Für Datenschutzanfragen kontaktieren Sie uns bitte unter: cengiz@gurtus.com

---

## 10. Änderungen dieser Erklärung

Die aktuelle Version finden Sie immer unter <https://fastretro.app/privacy>. Bei wesentlichen Änderungen informieren wir
innerhalb der Anwendung.

---

## 11. Kontakt

Cengiz Gürtusgil  
Angelika-Machinek-Str. 20, 60486 Frankfurt am Main, Deutschland  
E-Mail: cengiz@gurtus.com  
Datenschutz-Anfragen: cengiz@gurtus.com

---

# Privacy Policy for **Fast Retro**

**Effective:** 20 June 2025

## 1. Controller

Cengiz Gürtusgil
Angelika-Machinek-Str. 20, 60486 Frankfurt am Main, Germany  
Email: cengiz@gurtus.com  
Data protection inquiries: cengiz@gurtus.com  
Web: <https://fastretro.app>

---

## 2. Summary

* **Fast Retro** is a free open-source tool for agile retrospectives. The source code is publicly viewable, making data
  processing transparent and verifiable.
* **No registration required** – participation only requires a freely chosen name/nickname.
* Only **technically necessary data** is processed.
* **Server location:** Germany (Hetzner).
* **CDN / DDoS protection:** Cloudflare (USA). Cloudflare is certified under the EU-US Data Privacy Framework.
* All connections are **TLS-encrypted**.
* **No tracking or marketing cookies** → no cookie banner required.
* Our data processors implement comprehensive technical and organizational measures according to Art. 32 GDPR, including
  encryption, access controls, and regular security audits.

---

## 3. What data we process

### 3.1 Automatically transmitted connection data

* IP address, date/time, requested URL, HTTP status, referrer, browser and operating system information.
* Purpose: Operational security, error diagnosis, attack defense, performance optimization.
* Retention period:
    * Hetzner server logs are deleted after **7 days**.
    * Cloudflare stores connection data only as long as necessary for the respective processing purpose. After purpose
      fulfillment, data is deleted or anonymized. Cloudflare is a data processor according to Art. 28 GDPR and commits
      according to the Data Processing Addendum to comply with technical and organizational protective measures as well
      as to delete or return all personal data after purpose fulfillment or contract termination.

### 3.2 Data within a retrospective

* Name/nickname (freely chosen)
* Retrospective content (cards, comments, votes)
* Room ID and session ID (cookie) for session assignment

### 3.3 Technically necessary cookies

* `laravel_session` – maintains the session; deleted when browser is closed
* `XSRF-TOKEN` – CSRF protection; deleted when browser is closed
* `__cf_bm` – Cloudflare bot protection; runtime approx. 30 minutes
* `__cfruid` – Cloudflare load balancing (only in error cases); session end

---

## 4. Legal basis

* **Art. 6 para. 1 lit. f GDPR** – legitimate interest (IT security, functionality, performance).
* **Art. 6 para. 1 lit. b GDPR** – provision of retro function (quasi-contractual obligation).
* **Art. 6 para. 1 lit. c GDPR** – legal retention or proof obligations (if applicable).

---

## 5. Retention period / deletion

* Server logs at Hetzner – deletion after **7 days**.
* Connection data at Cloudflare – storage only as long as necessary for the respective purpose, subsequent deletion or
  anonymization.
* Session cookie – ends when browser is closed.
* Retrospective content and name/nickname – deletion by moderator or automatically **90 days** after last activity.

---

## 6. Recipients / data processors

### Hetzner Online GmbH (Germany)

* Hosting of our server in ISO 27001-certified data centers.
* Data processing agreement according to Art. 28 GDPR is in place.
* When using server locations outside Germany, local data center operators may be used as subcontractors.
* Privacy policy: <https://www.hetzner.com/de/rechtliches/datenschutz>

### Cloudflare Inc. (USA)

* Content delivery network, TLS proxy, DDoS protection.
* Certified under the EU-US Data Privacy Framework.
* Data transfer to the USA is based on:
* EU Standard Contractual Clauses (EU SCCs)
* EU-US Data Privacy Framework
* Adequacy decision of the EU Commission
* Cloudflare commits to process personal data only for the provision of services and to delete or return it after
  purpose fulfillment.
* Privacy policy: <https://www.cloudflare.com/privacypolicy/>

### Simple Analytics B.V. (Netherlands)

* Privacy-friendly website analytics without cookies or personal data.
* **No personal data:** Simple Analytics exclusively collects anonymous metrics (page views, timezone as proxy for 
  country, anonymized user agents, UTM parameters).
* **No IP addresses:** IP addresses are immediately discarded with every request, not stored or hashed.
* **No cookies:** No tracking cookies or similar technologies are used whatsoever.
* **EU hosting:** Data is stored exclusively in the Netherlands (EU) with GDPR-compliant providers.
* **No consent required:** Since no personal data is processed, no consent is necessary.
* Legal basis: Art. 6 para. 1 lit. f GDPR (legitimate interest in website optimization).
* Privacy policy: <https://simpleanalytics.com/privacy>

There is **no disclosure** of your data to other third parties, unless we are legally obligated to do so.

---

## 7. International data transfers

When using Cloudflare as CDN, personal data is transferred to the USA. This transfer is based on:

* EU Standard Contractual Clauses (Module 2: Controller to Processor)
* The EU-US Data Privacy Framework, for which Cloudflare is certified
* Additional technical and organizational protective measures according to the Cloudflare Data Processing Addendum

---

## 8. Security measures

* TLS 1.2+ encryption of all connections.
* DDoS and bot defense through Cloudflare.
* Least-privilege access concepts, regular security updates.
* Comprehensive technical and organizational measures at our data processors:
    * Encryption during transmission and storage
    * Access and access controls
    * Regular security audits and certifications (ISO 27001, SOC 2)
    * Incident response management
    * Data backup and recovery procedures

---

## 9. Rights of data subjects

You have the right to:

* **Information** (Art. 15 GDPR)
* **Rectification** (Art. 16 GDPR)
* **Erasure** (Art. 17 GDPR)
* **Restriction of processing** (Art. 18 GDPR)
* **Data portability** (Art. 20 GDPR)
* **Objection** (Art. 21 GDPR)

as well as the right to **complaint** to the competent supervisory authority:

The Hessian Commissioner for Data Protection and Freedom of Information  
Postfach 3163, 65021 Wiesbaden  
Email: poststelle@datenschutz.hessen.de

For data protection inquiries, please contact us at: cengiz@gurtus.com

---

## 10. Changes to this declaration

The current version can always be found at <https://fastretro.app/privacy>. In case of significant changes, we will
inform within the application.

---

## 11. Contact

Cengiz Gürtusgil  
Angelika-Machinek-Str. 20, 60486 Frankfurt am Main, Germany  
Email: cengiz@gurtus.com  
Data protection inquiries: cengiz@gurtus.com
