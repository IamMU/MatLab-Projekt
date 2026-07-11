# Analyse und Visualisierung langfristiger HRV-Änderungen

**Thema:** 7 
**Datum:** 11.07.2026 

---

## 1. Einleitung in die Thematik (Grundlagen der HRV)

Die **Herzfrequenzvariabilität (HRV)** beschreibt die natürliche Schwankung der zeitlichen Abstände zwischen aufeinanderfolgenden Herzschlägen (RR-Intervalle). Entgegen der intuitiven Annahme schlägt ein gesundes Herz nicht wie ein Metronom. Die zeitlichen Abstände variieren kontinuierlich im Millisekundenbereich. Diese Variabilität ist ein hochsensibler Indikator für die Anpassungsfähigkeit und Gesundheit des **Autonomen Nervensystems (ANS)**.

Das ANS steuert unbewusste Körperfunktionen und besteht im Wesentlichen aus zwei Antagonisten:
* **Der Sympathikus ("Gaspedal"):** Wird bei Stress, körperlicher Aktivität oder Gefahr aktiviert. Er erhöht die Herzfrequenz und *senkt* die HRV.
* **Der Parasympathikus ("Bremse", Vagusnerv):** Dominiert in Ruhe-, Erholungs- und Schlafphasen. Er senkt die Herzfrequenz und *erhöht* die HRV, insbesondere gekoppelt an die Atmung (Respiratorische Sinusarrhythmie - RSA).

Da die HRV ein sogenanntes **nichtstationäres Signal** ist, verändert sie sich über einen Zeitraum von 24 Stunden extrem (circadianer Rhythmus). Ziel dieses Projekts ist es, diese komplexen Langzeit-Änderungen aus einem EDF-Datensatz zu extrahieren und durch Frequenzbandanalyse (FFT) gemäß der medizinischen S2k-Leitlinie auszuwerten.

---

## 2. Programmarchitektur und Funktionsweise

Um die massiven Datenmengen (24 Stunden bei z.B. 250 Hz) effizient zu verarbeiten, wurde das MATLAB-Projekt streng modular und parametergesteuert aufgebaut. Die Steuerung erfolgt über eine zentrale `main.m` Datei.

### Die Verarbeitungspipeline (Ordnerstruktur `/src`):
1. **Import (`load_ecg_data`):** Einlesen der rohen EKG-Werte aus dem `.EDF`-Format (`/data`).
2. **Vorverarbeitung (`preprocess_ecg`):** Stabilisierung des Signals mittels Highpass-Filter (gegen Baseline-Wanderung), Bandstop-Filter (gegen 50-Hz-Netzbrummen) und Lowpass-Filter (gegen Muskelartefakte).
3. **Peak-Detektion (`detect_r_peaks`):** Adaptive Erkennung der R-Zacken basierend auf Schwellenwerten (Standardabweichung), um Fehl-Erkennungen von T-Wellen zu vermeiden.
4. **Transformation (`calculate_rr_intervals` & `interpolate_rr_signal`):** Berechnung der RR-Zeiten und anschließende kubische Spline-Interpolation auf ein festes 4-Hz-Raster, welches für die FFT zwingend notwendig ist.
5. **Spektralanalyse (`calculate_fft_spectrum` & `calculate_hrv_bands`):** Anwendung der Kurzzeit-Fourier-Transformation (STFT) über gleitende 5-Minuten-Fenster. Berechnung der spektralen Leistung in den genormten Bändern: **VLF** (0.0033-0.04 Hz), **LF** (0.04-0.15 Hz) und **HF** (0.15-0.40 Hz).
6. **Visualisierung:** Export aller Graphen in den `/results` bzw. `/assets` Ordner.

---

## 3. Detaillierte Daten- und Graphenanalyse

Im Folgenden werden die generierten Visualisierungen der Pipeline detailliert analysiert und medizinisch interpretiert (gemäß den Aufgaben 2.8 bis 2.11).

### 3.1 Signalgüte und Peak-Detektion
Eine korrekte HRV-Auswertung ist wertlos, wenn die R-Zacken fehlerhaft erkannt werden.

![Vorverarbeitung](assets/preprocessing_plot.png)
*Abbildung 1: Rohsignal (oben) im Vergleich zum gefilterten Signal (unten).*
**Analyse:** Das Rohsignal unterliegt einer massiven Baseline-Wanderung, meist verursacht durch die Atembewegung des Thorax. Das gefilterte Signal beweist die exzellente Wirkung der Filter-Pipeline: Die Nulllinie ist absolut stabil, und das hochfrequente Rauschen ist eliminiert.

![R-Zacken Marker](assets/r_peaks_plot.png)
*Abbildung 2: 10-Sekunden Ausschnitt mit Peak-Markern.*
**Analyse:** Die roten Sternchen belegen visuell die Präzision des adaptiven Algorithmus. P- und T-Wellen werden konsequent ignoriert, lediglich die signifikanten R-Zacken werden für die Zeitvektor-Extraktion herangezogen.

---

### 3.2 Zeitbereichsanalyse: Langfristige HRV-Veränderungen (Aufgabe 2.8)

Die Analyse des 24-Stunden-Tachogramms ist der erste Schritt zur Beurteilung der autonomen Regulation.

![Langzeit-Tachogramm](assets/longterm_rr_plot.png)
*Abbildung 3: 24h RR-Tachogramm mit Plausibilitätsgrenzen.*

**Tiefenanalyse (Aufgabe 2.8):**
Der Scatter-Plot (Punktdarstellung) zeigt die RR-Intervalle in Sekunden über den Verlauf des Tages. 
* **Plausibilität:** Die Datenwolke bewegt sich fast ausnahmslos im physiologisch möglichen Korridor zwischen den roten gestrichelten Linien (300 ms und 1500 ms).
* **Circadianer Rhythmus:** Makroskopisch lassen sich klare Phasen trennen. Phasen mit einem dichten, komprimierten Band am unteren Rand (kurze RR-Intervalle = hohe Herzfrequenz) spiegeln Wachzustände, körperliche Aktivität oder Stress wider. Die Streuung ist hier extrem gering.
* **Schlaf- und Erholungsphasen:** Deutlich erkennbar sind Phasen, in denen sich die Punktewolke massiv nach oben (bis über 1.0 Sekunden) ausweitet. Diese extreme Varianz ist ein Zeichen für den Schlaf-Wach-Zyklus, bei dem der Vagusnerv die Kontrolle übernimmt und eine tiefe Erholung einleitet.

![RR Zoom](assets/rr_zoom_plot.png)
*Abbildung 4: Kurzzeit-Zoom (5 Minuten) zweier unterschiedlicher physiologischer Zustände.*

**Tiefenanalyse der Mikro-Ebene:** Der Zoom offenbart, dass die HRV aus ineinandergreifenden Wellen besteht. Besonders bei Erholung sieht man eine niederfrequente Sinuswelle, die dem Signal überlagert ist. Dies ist die **Respiratorische Sinusarrhythmie (RSA)** – das Herz schlägt beim Einatmen schneller und beim Ausatmen langsamer. Die Sichtbarkeit dieser Welle beweist eine gesunde parasympathische Kontrolle.

---

### 3.3 Frequenzbereichsanalyse: Das Wasserfalldiagramm (Aufgabe 2.9 & 2.10)

Um die sympathovagale Balance zu quantifizieren, müssen wir in den Frequenzbereich wechseln.

![Wasserfalldiagramm](assets/waterfall_plot.png)
*Abbildung 5: 3D-Wasserfalldiagramm der gleitenden FFT (X=Frequenz, Y=Zeit, Z=Spektrale Leistung).*

**Tiefenanalyse (Aufgabe 2.10):**
* **Darstellungsoptimierung:** Die Begrenzung der X-Achse auf maximal 0.5 Hz sowie die Anwendung einer gedämpften Skalierung (z.B. Quadratwurzel `sqrt`) der Z-Achse ist essenziell. Da HRV-Signale dem $1/f$-Gesetz (Pink Noise) folgen, würde eine lineare Darstellung den HF-Bereich durch die gigantische Leistung im VLF-Bereich völlig unsichtbar machen.
* **Band-Verschiebungen:** Auf dem Boden (`Z=0`) markieren gestrichelte Linien die Leitlinien-Bänder (VLF, LF, HF). 
* **Physiologisches Muster:** Im Verlauf der Zeit (Y-Achse) sieht man deutlich, wie sich die spektrale Leistung verschiebt. Das VLF-Band ist durchgehend dominant (verantwortlich für Thermoregulation und Langzeit-Hormonschwankungen). Spannend wird es ab der 0.15 Hz Grenze (HF-Band): In Erholungsphasen baut sich hier eine kleine, aber signifikante "Hügelkette" auf (vagale Dominanz). In Aktivitätsphasen ebnet sich dieses HF-Band fast vollständig zu einem flachen Tal ein, und die Energie verschiebt sich leicht in Richtung LF-Band (Barorezeptor-Reflex, Sympathikus-Aktivität).

---

### 3.4 Statistische Auswertung und Trends (Aufgabe 2.11)

![HRV Trends](assets/hrv_trends.png)
*Abbildung 6: Verlauf der absoluten und relativen HRV-Bänder über die Zeit.*

**Die LF/HF-Ratio:** Der untere Subplot zeigt die Ratio aus LF (Gaspedal) und HF (Bremse). Ein Ausreißer nach oben bedeutet Stress/Anspannung. Man sieht eine starke Fluktuation, die beweist, dass das autonome System unentwegt Gegenregulationsprozesse ("Fight or Flight" vs. "Rest and Digest") ausführt.

![Segment Vergleich](assets/segment_comparison.png)
*Abbildung 7: Boxplot-Vergleich zweier definierter Zeitsegmente.*

**Statistischer Beweis (Aufgabe 2.11):** Dieser Graph ist der mathematische Beweis für die Notwendigkeit der Langzeitanalyse. Der Boxplot teilt den Datensatz (z.B. Tag vs. Nacht).
* **Median-Verschiebung:** Die horizontale rote Linie (Median) verschiebt sich signifikant. Ein hohes Niveau in Segment 1 beweist eine stärkere sympathische Grundbelastung als im Vergleichssegment.
* **Interquartilsabstand (IQR):** Die Höhe des blauen Kastens zeigt die Streuung der Ratio. Ein hoher Kasten bedeutet hohe Dynamik; ein gestauchter Kasten deutet auf einen "Lock-In" Zustand hin, bei dem der Körper auf einem bestimmten Stress- oder Erholungsniveau festgefahren war.

---

## 4. Performance-Analyse (Aufgabe 2.12)

Da ein 24h EKG mit 250 Hz über 21 Millionen Datenpunkte erzeugt, sind algorithmische Effizienz und Speichermanagement entscheidend. Entsprechende Daten wurden in der `performance_report.txt` gesammelt.

1. **Speicherbedarf & Datenhaltung:** Das Rohsignal belegt massiv RAM. Ein Kernprinzip unserer Architektur ist es, das EKG-Signal nach der R-Peak-Erkennung zu verwerfen. Die gesamte anschließende komplexe FFT-Mathematik operiert ausschließlich auf den Vektoren der RR-Intervalle. Dies reduziert den Speicher-Footprint um über 99 % und verhindert Out-Of-Memory Fehler.
2. **FFT-Laufzeiten:** Statt zehntausende 5-Minuten-Fenster durch ineffiziente `for`-Schleifen iterativ zu berechnen, nutzt unsere Pipeline die vektorisierte MATLAB-Funktion `spectrogram`. Die Berechnungszeit der Spektren konnte so auf wenige Sekundenbruchteile gedrückt werden.
3. **Visualisierungsperformance:** Das Rendern von 3D-Flächen (Wasserfall) für hunderttausende FFT-Punkte überlastet gängige Grafik-Renderer. Durch den Cut-off der nicht-physiologischen Frequenzen oberhalb von 0.5 Hz wurde der Render-Aufwand drastisch reduziert, was das Programm hochgradig responsiv macht.

---

## 5. Fachliche Bewertung und Leitfragen (Aufgabe 2.13)

Zusammenfassend lässt sich der Datensatz anhand der Leitfragen (Aufgabe 5) wie folgt bewerten:

**1. Stabilität der HRV & Aussagekraft langfristiger Analysen:**
Das Signal ist hochgradig instabil – und das ist ein Beweis für einen gesunden Probanden! Eine dauerhaft stabile, starre HRV (wie bei einem Metronom) ist klinisch ein Zeichen für massive Erschöpfung, Alterung oder Herzkrankheiten. Die 24-Stunden Analyse entlarvt, was ein 5-Minuten-Ruhe-EKG verschweigen würde: Nämlich die tatsächliche *Reaktions- und Erholungsfähigkeit* des Systems nach Stressphasen.

**2. Physiologische Trends und Muster (Wasserfall):**
Der Tag wird von LF und VLF dominiert. Die vagale Erholung ist im Wasserfalldiagramm als ansteigende Leistung im HF-Band zu erkennen. Fehlt diese HF-Erhebung im Schlaf gänzlich, würde dies auf ein massives Regenerationsdefizit (z.B. chronischer Stress, Übertraining) hindeuten.

**3. Autonome Regulation (LF, HF, LF/HF):**
Die Parameter verhalten sich dynamisch. Bei sympathischer Erregung (Aktivität) wird die parasympathische Bremse (HF) sofort zurückgefahren. Dadurch steigt der Quotient LF/HF. Im Moment der Ruhe greift die Atmung wieder stärker in den Rhythmus ein (RSA), die HF-Power schnellt in die Höhe und der Quotient fällt drastisch ab. 

**Fazit:**
Die entwickelte MATLAB-Pipeline erfüllt nicht nur alle technischen Anforderungen der Signalverarbeitung, sondern visualisiert die physiologische Realität der autonomen Regulation nach aktuellen medizinischen Standards (S2k). Die Segmentierung der Zeitbereiche beweist erfolgreich die tageszeitabhängige Dynamik des menschlichen Herzens.
