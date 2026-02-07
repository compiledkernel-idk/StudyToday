# SPDX-FileCopyrightText: 2026 compiledkernel-idk
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""
sample_content.py - Sample Biologie (Biology) content in Dutch.

Provides realistic study content with embedded question blocks that can be
parsed by content_parser.parse_content().
"""

from __future__ import annotations


def get_sample_subjects() -> list[dict]:
    """Return a list of sample subject dicts with topics and embedded questions."""

    fotosynthese_content = """\
# Fotosynthese

## Wat is fotosynthese?

Fotosynthese is het proces waarbij **groene planten**, algen en sommige bacteriën \
lichtenergie omzetten in chemische energie. Dit proces vindt plaats in de \
**chloroplasten** van plantencellen, met name in het **bladgroenkorrel** (chlorofyl).

De algemene vergelijking van fotosynthese is:

**6 CO₂ + 6 H₂O + lichtenergie → C₆H₁₂O₆ + 6 O₂**

## De lichtreactie

De **lichtreactie** vindt plaats in de **thylakoïdmembranen** van de chloroplasten. \
Tijdens deze fase wordt lichtenergie opgevangen door chlorofyl en omgezet in \
chemische energie in de vorm van **ATP** en **NADPH**. Water wordt hierbij gesplitst \
(*fotolyse*), waarbij zuurstof vrijkomt als bijproduct.

:::meerkeuze
vraag: Waar vindt de lichtreactie van fotosynthese plaats?
opties: A) In de mitochondriën B) In de thylakoïdmembranen C) In het cytoplasma D) In de celkern
correct: 1
uitleg: De lichtreactie vindt plaats in de thylakoïdmembranen van de chloroplasten, waar chlorofyl het licht opvangt.
:::

## De donkerreactie (Calvincyclus)

De **donkerreactie**, ook wel de **Calvincyclus** genoemd, vindt plaats in het \
**stroma** van de chloroplasten. Ondanks de naam heeft deze reactie geen \
duisternis nodig — het betekent alleen dat licht niet *direct* nodig is.

Tijdens de Calvincyclus wordt **CO₂** vastgelegd en omgezet in **glucose** met \
behulp van de ATP en NADPH uit de lichtreactie.

:::invullen
vraag: De donkerreactie vindt plaats in het _____ van de chloroplasten.
antwoord: stroma
hint: Het is de vloeistof rondom de thylakoïden.
:::

## Factoren die fotosynthese beïnvloeden

Verschillende factoren beïnvloeden de snelheid van fotosynthese:

- **Lichtintensiteit**: meer licht = snellere fotosynthese (tot een maximum)
- **CO₂-concentratie**: meer CO₂ = snellere reactie (tot een maximum)
- **Temperatuur**: enzymen werken optimaal rond **25-35°C**
- **Watervoorziening**: water is een grondstof voor de reactie

:::waar-of-niet
vraag: Bij een hogere temperatuur verloopt fotosynthese altijd sneller.
antwoord: niet
uitleg: Boven de optimale temperatuur denatureren enzymen, waardoor de fotosynthese juist afneemt.
:::

## Belang van fotosynthese

Fotosynthese is essentieel voor het leven op aarde. Het zorgt voor:

1. **Zuurstofproductie** — nodig voor de ademhaling van de meeste organismen
2. **Voedselproductie** — glucose als energiebron voor de plant en andere organismen
3. **CO₂-opname** — helpt bij het reguleren van het broeikaseffect

:::koppelen
vraag: Koppel de juiste termen aan hun functie in fotosynthese.
paren: Chlorofyl = Vangt lichtenergie op, Stroma = Plaats van de Calvincyclus, Thylakoïd = Plaats van de lichtreactie, ATP = Energiedrager
:::

:::open
vraag: Leg uit waarom fotosynthese belangrijk is voor het leven op aarde. Noem minstens drie redenen.
kernwoorden: zuurstof, glucose, voedsel, CO₂, broeikaseffect, energie, ademhaling
:::
"""

    cellen_content = """\
# Cellen

## De bouwstenen van het leven

Alle levende organismen zijn opgebouwd uit **cellen**. De cel is de kleinste \
eenheid van leven die zelfstandig kan functioneren. Er zijn twee hoofdtypen cellen:

- **Prokaryote cellen** — geen celkern (bijv. bacteriën)
- **Eukaryote cellen** — wel een celkern (bijv. planten- en diercellen)

## De plantencel

Een plantencel bevat de volgende organellen:

| Organel | Functie |
|---------|---------|
| **Celwand** | Stevigheid en bescherming |
| **Celmembraan** | Regelt transport van stoffen |
| **Celkern** | Bevat DNA, stuurt celprocessen aan |
| **Chloroplasten** | Fotosynthese |
| **Mitochondriën** | Celademhaling (energieproductie) |
| **Vacuole** | Opslag van water en stoffen |
| **Endoplasmatisch reticulum** | Eiwitsynthese en transport |

:::meerkeuze
vraag: Welk organel is verantwoordelijk voor de celademhaling?
opties: A) Chloroplasten B) Celkern C) Mitochondriën D) Vacuole
correct: 2
uitleg: Mitochondriën zijn de 'energiecentrales' van de cel en zorgen voor de celademhaling waarbij glucose wordt omgezet in ATP.
:::

## Verschil tussen planten- en diercellen

Plantencellen hebben enkele onderdelen die diercellen **niet** hebben:

- **Celwand** — geeft extra stevigheid
- **Chloroplasten** — voor fotosynthese
- **Grote centrale vacuole** — voor wateropslag

Diercellen hebben daarentegen **lysosomen** die belangrijker zijn voor de \
afbraak van afvalstoffen.

:::waar-of-niet
vraag: Diercellen bevatten chloroplasten.
antwoord: niet
uitleg: Chloroplasten komen alleen voor in plantencellen (en sommige algen). Diercellen kunnen geen fotosynthese uitvoeren.
:::

## Celdeling: mitose

**Mitose** is het proces waarbij een cel zich deelt in twee identieke dochtercellen. \
Dit is belangrijk voor **groei**, **herstel** en **vervanging** van cellen.

De fasen van mitose zijn:

1. **Profase** — chromosomen worden zichtbaar, kernmembraan verdwijnt
2. **Metafase** — chromosomen liggen op de evenaar van de cel
3. **Anafase** — chromatiden worden naar de polen getrokken
4. **Telofase** — nieuwe kernmembranen vormen zich, cel splitst

:::invullen
vraag: Tijdens de _____ liggen de chromosomen op de evenaar van de cel.
antwoord: metafase
hint: Deze fase begint met de letter M en betekent letterlijk 'midden-fase'.
:::

:::koppelen
vraag: Koppel elke fase van mitose aan de juiste beschrijving.
paren: Profase = Chromosomen worden zichtbaar, Metafase = Chromosomen op de evenaar, Anafase = Chromatiden naar de polen, Telofase = Nieuwe kernmembranen vormen
:::

:::open
vraag: Beschrijf het verschil tussen een prokaryote en een eukaryote cel. Geef van beide een voorbeeld.
kernwoorden: celkern, DNA, bacterie, prokaryoot, eukaryoot, organellen, membraan
:::
"""

    ecosystemen_content = """\
# Ecosystemen

## Wat is een ecosysteem?

Een **ecosysteem** is een samenlevingsverband van **levende organismen** \
(biotische factoren) en hun **niet-levende omgeving** (abiotische factoren). \
Voorbeelden van ecosystemen zijn een bos, een meer, een woestijn of een koraalrif.

### Biotische factoren
- Planten, dieren, schimmels, bacteriën
- Onderlinge relaties: predatie, competitie, symbiose

### Abiotische factoren
- Temperatuur, licht, water, bodem, mineralen
- Bepalen welke organismen er kunnen leven

:::meerkeuze
vraag: Welke van de volgende is een abiotische factor?
opties: A) Een wolf B) Temperatuur C) Een eikenboom D) Bacteriën
correct: 1
uitleg: Temperatuur is een niet-levende (abiotische) factor. Wolven, eikenbomen en bacteriën zijn allemaal levende (biotische) factoren.
:::

## Voedselketens en voedselwebben

Energie stroomt door een ecosysteem via **voedselketens**:

**Producent → Primaire consument → Secundaire consument → Tertiaire consument**

Voorbeeld:
- **Gras** (producent) → **Konijn** (herbivoor) → **Vos** (carnivoor) → **Arend** (toppredator)

Meerdere voedselketens vormen samen een **voedselweb**. Bij elke stap gaat \
ongeveer **90%** van de energie verloren als warmte.

:::invullen
vraag: Bij elke stap in de voedselketen gaat ongeveer _____% van de energie verloren.
antwoord: 90
hint: Het is een hoog percentage — slechts een tiende gaat verder.
:::

## Kringlopen

Stoffen worden in een ecosysteem **hergebruikt** via kringlopen:

### De koolstofkringloop
1. Planten nemen **CO₂** op via fotosynthese
2. Dieren eten planten en ademen **CO₂** uit
3. Dode organismen worden afgebroken door **reducenten** (schimmels, bacteriën)
4. Fossiele brandstoffen geven bij verbranding CO₂ af

### De stikstofkringloop
- **Stikstofbindende bacteriën** zetten N₂ om in bruikbare stikstofverbindingen
- Planten nemen **nitraat** op via hun wortels
- Dieren krijgen stikstof via voedsel

:::waar-of-niet
vraag: Planten nemen stikstof rechtstreeks op als N₂ uit de lucht.
antwoord: niet
uitleg: Planten kunnen geen N₂ gas gebruiken. Stikstofbindende bacteriën moeten het eerst omzetten in nitraat of ammonium.
:::

## Verstoringen van ecosystemen

Menselijke activiteiten kunnen ecosystemen verstoren:

- **Ontbossing** — verlies van habitats en biodiversiteit
- **Vervuiling** — giftige stoffen in water, bodem en lucht
- **Klimaatverandering** — verschuiving van leefgebieden
- **Overbevissing** — verstoring van voedselwebben

:::koppelen
vraag: Koppel de verstoring aan het gevolg.
paren: Ontbossing = Verlies van habitats, Vervuiling = Giftige stoffen in het milieu, Klimaatverandering = Verschuiving van leefgebieden, Overbevissing = Verstoring van voedselwebben
:::

:::open
vraag: Leg uit hoe de koolstofkringloop werkt en welke rol fotosynthese en ademhaling daarin spelen.
kernwoorden: CO₂, fotosynthese, ademhaling, planten, dieren, reducenten, kringloop, glucose
:::
"""

    biologie_subject = {
        "id": "bio-001",
        "naam": "Biologie",
        "icon": "\U0001f9ec",  # 🧬
        "volgorde": 0,
        "topics": [
            {
                "id": "topic-bio-001",
                "subjectId": "bio-001",
                "titel": "Fotosynthese",
                "content": fotosynthese_content,
                "slug": "fotosynthese",
            },
            {
                "id": "topic-bio-002",
                "subjectId": "bio-001",
                "titel": "Cellen",
                "content": cellen_content,
                "slug": "cellen",
            },
            {
                "id": "topic-bio-003",
                "subjectId": "bio-001",
                "titel": "Ecosystemen",
                "content": ecosystemen_content,
                "slug": "ecosystemen",
            },
        ],
    }

    return [biologie_subject]
