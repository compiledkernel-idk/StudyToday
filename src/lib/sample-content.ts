// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import type { Subject } from './store'

export const sampleSubjects: Subject[] = [
  {
    id: 'biologie',
    naam: 'Biologie',
    icon: '🧬',
    volgorde: 1,
    topics: [
      {
        id: 'fotosynthese',
        subjectId: 'biologie',
        titel: 'Fotosynthese',
        slug: 'fotosynthese',
        content: `# Fotosynthese

Fotosynthese is het proces waarbij planten **lichtenergie** omzetten in **chemische energie**. Dit is een van de belangrijkste processen op aarde, omdat het de basis vormt voor vrijwel alle voedselketens.

## Hoe werkt het?

Planten vangen zonlicht op met behulp van **chlorofyl**, het groene pigment in hun bladeren. Dit pigment bevindt zich in speciale celorganellen genaamd **chloroplasten**.

De basisformule van fotosynthese is:

> 6 CO₂ + 6 H₂O + lichtenergie → C₆H₁₂O₆ + 6 O₂

Dit betekent dat planten **koolstofdioxide** en **water** gebruiken, samen met licht, om **glucose** en **zuurstof** te maken.

## Belangrijke termen

- **Chlorofyl**: Het groene pigment dat licht absorbeert
- **Chloroplast**: Het celorganel waar fotosynthese plaatsvindt
- **Stomata**: Kleine openingen in bladeren voor gasuitwisseling
- **Glucose**: De suiker die als energiebron wordt geproduceerd
- **Xyleem**: Transportweefsel dat water naar de bladeren brengt

:::meerkeuze
vraag: Welk gas nemen planten op tijdens fotosynthese?
opties:
  - Zuurstof
  - Stikstof
  - Koolstofdioxide*
  - Waterstof
uitleg: Planten nemen CO₂ (koolstofdioxide) op uit de lucht en geven O₂ (zuurstof) af als bijproduct.
:::

:::invullen
vraag: Het groene pigment in bladeren heet ___
antwoord: chlorofyl
hint: Begint met 'ch' en geeft bladeren hun groene kleur
:::

:::waar-of-niet
vraag: Planten hebben alleen zonlicht nodig om te groeien.
antwoord: niet waar
uitleg: Planten hebben naast zonlicht ook water, koolstofdioxide en mineralen nodig om te groeien.
:::

:::koppelen
vraag: Koppel elk onderdeel aan zijn functie
paren:
  - [Chlorofyl, Absorbeert lichtenergie]
  - [Stomata, Gasuitwisseling]
  - [Xyleem, Watervervoer]
  - [Chloroplast, Plaats van fotosynthese]
:::

:::open
vraag: Leg in je eigen woorden uit waarom fotosynthese belangrijk is voor het leven op aarde.
kernwoorden: [zuurstof, voedsel, energie, CO₂, voedselketen]
:::

:::meerkeuze
vraag: Waar vindt fotosynthese plaats in een plantencel?
opties:
  - Mitochondriën
  - Celkern
  - Chloroplasten*
  - Ribosomen
uitleg: Chloroplasten zijn de celorganellen die chlorofyl bevatten en waar het proces van fotosynthese plaatsvindt.
:::
`,
      },
      {
        id: 'cellen',
        subjectId: 'biologie',
        titel: 'Cellen',
        slug: 'cellen',
        content: `# Cellen — De Bouwstenen van het Leven

Alle levende organismen bestaan uit **cellen**. Een cel is de kleinste eenheid van leven. Er zijn twee hoofdtypen cellen: **prokaryote** cellen (zoals bacteriën) en **eukaryote** cellen (zoals planten- en diercellen).

## Onderdelen van een diercel

| Organel | Functie |
|---------|---------|
| **Celkern** | Bevat het DNA, bestuurt de cel |
| **Celmembraan** | Beschermt de cel, regelt transport |
| **Cytoplasma** | Gelachtige vloeistof in de cel |
| **Mitochondriën** | Energieproductie (celademhaling) |
| **Ribosomen** | Maken eiwitten aan |

## Verschil planten- en diercel

Plantencellen hebben extra onderdelen die diercellen niet hebben:
- **Celwand**: Stevige buitenlaag van cellulose
- **Chloroplasten**: Voor fotosynthese
- **Grote vacuole**: Opslag van water en voedingsstoffen

:::meerkeuze
vraag: Welk organel wordt de 'energiecentrale' van de cel genoemd?
opties:
  - Ribosomen
  - Mitochondriën*
  - Celkern
  - Chloroplasten
uitleg: Mitochondriën zetten glucose om in energie (ATP) via celademhaling. Ze worden daarom de 'energiecentrales' van de cel genoemd.
:::

:::waar-of-niet
vraag: Zowel planten- als diercellen hebben een celwand.
antwoord: niet waar
uitleg: Alleen plantencellen hebben een celwand (gemaakt van cellulose). Diercellen hebben alleen een celmembraan.
:::

:::invullen
vraag: De gelachtige vloeistof in een cel heet het ___
antwoord: cytoplasma
hint: Begint met 'cyto'
:::

:::koppelen
vraag: Koppel het organel aan de juiste functie
paren:
  - [Celkern, Bestuurt de cel]
  - [Mitochondriën, Maakt energie]
  - [Ribosomen, Maakt eiwitten]
  - [Celmembraan, Beschermt de cel]
:::

:::meerkeuze
vraag: Wat heeft een plantencel dat een diercel NIET heeft?
opties:
  - Celmembraan
  - Celkern
  - Chloroplasten*
  - Mitochondriën
uitleg: Chloroplasten komen alleen voor in plantencellen. Ze bevatten chlorofyl en zijn nodig voor fotosynthese.
:::
`,
      },
      {
        id: 'ecosystemen',
        subjectId: 'biologie',
        titel: 'Ecosystemen',
        slug: 'ecosystemen',
        content: `# Ecosystemen

Een **ecosysteem** is een leefgemeenschap van organismen samen met hun niet-levende omgeving. Alle organismen in een ecosysteem zijn met elkaar verbonden door voedselrelaties.

## Voedselketen

Een voedselketen laat zien wie wat eet:

> Gras → Konijn → Vos → Arend

Elke schakel in de keten noemen we een **trofisch niveau**:
1. **Producenten**: Planten die energie maken via fotosynthese
2. **Primaire consumenten**: Herbivoren (planteneters)
3. **Secundaire consumenten**: Carnivoren (vleeseters)
4. **Tertiaire consumenten**: Toproofdieren
5. **Reducenten**: Breken dood materiaal af (schimmels, bacteriën)

## Voedselweb

In werkelijkheid eten de meeste dieren meer dan één soort voedsel. Daarom spreken we van een **voedselweb** — een netwerk van meerdere voedselketens.

:::meerkeuze
vraag: Wat is de rol van planten in een ecosysteem?
opties:
  - Reducenten
  - Consumenten
  - Producenten*
  - Afbrekers
uitleg: Planten zijn producenten — ze maken hun eigen voedsel via fotosynthese en vormen de basis van elke voedselketen.
:::

:::invullen
vraag: Een netwerk van meerdere voedselketens noemen we een ___
antwoord: voedselweb
hint: Twee woorden, begint met 'voedsel'
:::

:::waar-of-niet
vraag: Reducenten staan altijd aan het begin van een voedselketen.
antwoord: niet waar
uitleg: Reducenten (zoals schimmels en bacteriën) breken dood organisch materiaal af. Ze staan niet aan het begin maar spelen een rol bij het recyclen van voedingsstoffen.
:::

:::koppelen
vraag: Koppel het trofisch niveau aan het juiste voorbeeld
paren:
  - [Producent, Gras]
  - [Primaire consument, Konijn]
  - [Secundaire consument, Vos]
  - [Reducent, Schimmel]
:::

:::open
vraag: Wat zou er gebeuren als alle producenten uit een ecosysteem zouden verdwijnen?
kernwoorden: [voedselketen, energie, herbivoren, uitsterven, instorten]
:::
`,
      },
    ],
  },
]
