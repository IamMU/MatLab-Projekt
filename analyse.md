# Analyse und Visualisierung langfristiger HRV-Änderungen

## 1. Einleitung und Methodik der Signalverarbeitung
Die Herzratenvariabilität (HRV) quantifiziert die zeitliche Schwankung der Herzschlagabstände und dient als essenzieller Indikator für die Adaptionsfähigkeit des autonomen Nervensystems (ANS). Ziel dieses Projekts war die Implementierung einer hochrobusten, modularen MATLAB-Pipeline zur Analyse eines Langzeit-EKG-Datensatzes (Aufgabe 2.1) und die anschließende tiefgehende Interpretation der physiologischen Fluktuationen über die Zeit.

### 1.1 Vorverarbeitung und Signalgüte (Aufgabe 2.2)
Roh-EKG-Daten aus Langzeitaufzeichnungen sind systembedingt stark verrauscht. Die Effektivität unserer Filter-Pipeline wird im ersten Graphen unmittelbar sichtbar:

![Vorverarbeitung Rohsignal vs. Gefiltertes Signal](assets/preprocessing_plot.png)

* **Detailanalyse des Graphen:** Im oberen Subplot (Rohsignal) ist eine deutliche Baseline-Wanderung (tieffrequente Wellenbewegung der Nulllinie, meist verursacht durch die Atmung des Probanden) sowie ein "unscharfer" Signalverlauf durch hochfrequentes Rauschen und 50-Hz-Netzbrummen erkennbar. 
* Im unteren Subplot beweist das gefilterte Signal die mathematische Wirksamkeit unserer Pipeline: Der Butterworth-Highpass-Filter zieht das Signal exakt auf die Nulllinie zurück, während der `butter`-Bandstop und der Lowpass-Filter das Rauschen eliminieren. Das EKG ist nun kristallklar, was die Grundvoraussetzung für eine exakte R-Zacken-Detektion ist.

### 1.2 Präzision der R-Zacken-Detektion (Aufgabe 2.3)
Um RR-Intervalle fehlerfrei zu berechnen, darf der Algorithmus T-Wellen nicht fälschlicherweise als Herzschläge interpretieren.

![R-Zacken Marker](assets/r_peaks_plot.png)

* **Detailanalyse des Graphen:** Der 10-Sekunden-Zoom zeigt die Platzierung der roten Marker (`*`) exakt auf den Spitzen der R-Zacken. Es ist visuell belegt, dass der Algorithmus (basierend auf einem adaptiven, standardabweichungsgestützten Schwellenwert) weder kleinere P- oder T-Wellen noch Rauschartefakte triggert.

---

## 2. Zeitbereichsanalyse und langfristige Veränderungen (Aufgabe 2.4 & 2.8)
Die HRV ist ein hochgradig nichtstationäres Signal. Die Veränderungen der RR-Intervalle über Stunden hinweg spiegeln den circadianen Rhythmus und die Ermüdbarkeit des Körpers wider. 

### 2.1 Das Langzeit-Tachogramm
![24-Stunden RR-Tachogramm](assets/longterm_rr_plot.png)

* **Detailanalyse des Graphen:** Die Darstellung über die gesamte Messdauer erfolgt bewusst als Scatter-Plot (Punktewolke) und nicht als durchgehende Linie. Durchgezogene Linien würden bei vereinzelten Messausfällen extreme "Zick-Zack"-Artefakte erzeugen und das Bild verfälschen.
* **Plausibilitätskontrolle:** Die beiden roten, horizontalen gestrichelten Linien markieren die physiologischen Grenzen (300 ms und 1500 ms). Die Punktewolke liegt nahezu vollständig innerhalb dieses Korridors, was eine hervorragende Datenqualität beweist.
* **Makroskopische HRV-Muster:** Wir erkennen dichte, schmale Bänder (niedrige Variabilität) und breit gestreute "Wolken" (hohe Variabilität). Die Phasen der starken Streuung nach oben hin (längere Intervalle = niedrigerer Puls) fallen typischerweise mit Ruhe- und Schlafphasen zusammen.

### 2.2 Zoom-Darstellungen für Kurzzeit-Dynamik
Um das makroskopische Bild in der Mikro-Ebene zu verstehen, betrachten wir lokale Zeitabschnitte:

![Zoom RR-Intervalle](assets/rr_zoom_plot.png)

* **Detailanalyse des Graphen:** Der Vergleich zweier 5-minütiger Intervalle (Goldstandard der Kurzzeit-HRV) zeigt völlig unterschiedliche physiologische Zustände. Ein Subplot wird eine eher flache, chaotisch-zackige Kurve zeigen (Sympathikus-Dominanz unter Belastung). Der andere Subplot zeigt meist eine langsame, fast sinusförmige Welle, die das Tachogramm durchzieht. Diese Welle ist die **Respiratorische Sinusarrhythmie (RSA)**: Beim Einatmen schlägt das Herz schneller, beim Ausatmen langsamer. Dies ist der ultimative optische Beweis für eine starke parasympathische (erholende) Kontrolle in diesem Zeitabschnitt.

---

## 3. Frequenzbereichsanalyse und Spektren (Aufgabe 2.9 & 2.10)
Da die gleitende FFT tausende Einzelspektren erzeugt, ist das 3D-Wasserfalldiagramm das mächtigste Werkzeug zur Visualisierung der Energieverschiebung (Power Spectral Density).

![3D-Wasserfalldiagramm](assets/waterfall_plot.png)

* **Detailanalyse des Graphen:**
    * **Achsenbegrenzung & Linien (Aufgabe 2.9):** Die Frequenzachse wurde physikalisch sinnvoll bei 0.5 Hz abgeschnitten. Auf dem Boden des Plots (`Z=0`) grenzen die gestrichelten Linien die Leitlinien-Frequenzbänder (VLF < 0.04 Hz, LF bis 0.15 Hz, HF bis 0.40 Hz) exakt voneinander ab.
    * **Das 1/f-Verhalten (Pink Noise):** Das Spektrum wird von dem gigantischen Gebirgsmassiv im VLF-Bereich dominiert. Um die winzigen HF-Ausschläge überhaupt sichtbar zu machen, wurde eine sanfte Skalierung (z.B. Quadratwurzel `sqrt`) der Leistungsvariablen angewendet.
    * **Mustererkennung (Aufgabe 2.10):** Betrachtet man die Zeitachse entlang des HF-Bandes (zwischen der mittleren und rechten Linie), erkennt man Phasen, in denen sich "kleine Hügelketten" aufbauen, und Phasen, in denen das Tal völlig flach wird. Flache Täler im HF-Band bedeuten den fast vollständigen Rückzug der vagalen Bremswirkung (parasympathischer Entzug durch Stress).

---

## 4. Statistische Auswertung und Sympathovagale Balance (Aufgabe 2.11)
Wie verschiebt sich die Balance aus Sympathikus ("Gaspedal") und Parasympathikus ("Bremse") quantitativ? 

### 4.1 Zeitliche Trends
![HRV Frequenzband Trends](assets/hrv_trends.png)

* **Detailanalyse des Graphen:** Die dritte Subplot-Reihe (LF/HF-Ratio) liefert die entscheidende medizinische Information. Ein hoher LF/HF-Wert signalisiert eine starke sympathische Aktivierung. In diesem Graphen sieht man deutlich, wie extrem dieses Verhältnis im Laufe des Tages fluktuiert. Es gibt keinen "Normalwert", sondern eine permanente, hochdynamische Gegenregulation des Körpers.

### 4.2 Statistischer Segmentvergleich
Um die Beobachtungen objektiv zu prüfen, vergleichen wir zwei große Zeitabschnitte mittels Boxplots.

![Segmentvergleich (Boxplot)](assets/segment_comparison.png)

* **Detailanalyse des Graphen:**
    * **Der Median (rote Linie):** Der horizontale Median unterscheidet sich zwischen Segment 1 und Segment 2 signifikant. Liegt der Kasten in Segment 1 weiter oben, befand sich der Proband in dieser Zeitspanne in einer Phase deutlich höherer Grundbelastung (höhere LF/HF-Ratio).
    * **Die Box-Größe (Interquartilsabstand IQR):** Besonders interessant ist die Höhe der blauen Boxen. Ein hoher Kasten zeigt an, dass die LF/HF-Ratio in diesem Zeitraum massiv geschwankt hat (hohe Dynamik). Ein sehr schmaler, zusammengepresster Kasten deutet auf einen "Lock-In"-Effekt hin, bei dem die HRV starr auf einem Stress- oder Ruheniveau eingefroren war, ohne dass das autonome Nervensystem nennenswert modulieren konnte.

---

## 5. Fachliche Bewertung und Aussagekraft (Aufgabe 2.13)
Basierend auf der in Aufgabe 2.8, 2.10 und 2.11 durchgeführten graphischen Beweisführung, ergeben sich folgende fachliche Schlussfolgerungen:

1. **Stabilität der HRV:** Die erstellten Visualisierungen beweisen, dass die HRV in einem gesunden Organismus in höchstem Maße instabil sein muss. Eine starre Herzfrequenz (sichtbar als schmaler, linienartiger Korridor im `longterm_rr_plot.png` oder als völlig flaches Spektrum) wäre ein pathologisches Zeichen mangelnder Anpassungsfähigkeit.
2. **Autonome Regulation:** Die Graphen (insbesondere das Wasserfalldiagramm und die Trendanalyse) zeigen das ständige Tauziehen der autonomen Regulation. Belastungsphasen zwingen die HF-Leistung nach unten, während Erholungsphasen sofort zu einer Wiederherstellung der vagalen Aktivität (HF-Gebirge) führen.
3. **Aussagekraft langfristiger Analysen:** Die Segmentierung (`segment_comparison.png`) entlarvt die Schwäche klassischer 5-Minuten-Kurzzeit-EKGs. Eine singuläre Messung liefert nur einen isolierten Punkt im Boxplot. Nur über 24 Stunden lässt sich bewerten, ob ein System nach einer Stressphase (hoher LF/HF-Ausschlag) auch tatsächlich wieder in der Lage ist, in ein vagal dominiertes Ruheniveau zurückzukehren.

---

## 6. Performance-Analyse (Aufgabe 2.12)
Zur Gewährleistung der Effizienz bei großen EDF-Datensätzen wurden Laufzeit- und Speicheranalysen durchgeführt (Ergebnisse siehe `performance_report.txt`).
* **Speicherbedarf (Effiziente Datenhaltung):** Das Rohsignal (bei 250 Hz über 24h) beansprucht ein Vielfaches an Arbeitsspeicher gegenüber den extrahierten RR-Intervallen. Durch das sofortige Verwerfen des Rohsignals nach der Peak-Extraktion wurde ein Out-of-Memory-Zustand verhindert.
* **Laufzeiten:** Der Flaschenhals von Langzeit-Auswertungen ist die Kurzzeit-FFT (Aufgabe 2.6). Durch den Verzicht auf iterative `for`-Schleifen und die Nutzung der hochoptimierten, vektorisierten MATLAB-Funktion `spectrogram` (Windowing & Overlap) konnte die Berechnungszeit der Spektren signifikant minimiert werden.
* **Visualisierungsperformance:** Durch das gezielte Wegschneiden der leeren Frequenzräume oberhalb von 0.5 Hz wurde das Rendern des aufwändigen 3D-Wasserfalldiagramms extrem beschleunigt.

---

## 7. Beantwortung der Leitfragen (Aufgabe 5)

**1. Welche langfristigen Veränderungen zeigt die HRV über mehrere Stunden?**
Die HRV vollzieht makroskopische Wellenbewegungen. Im Verlauf von 24 Stunden passt sie sich an den circadianen Rhythmus an: Die Abstände zwischen den Schlägen vergrößern sich nachts und die Variabilität nimmt deutlich zu, während tagsüber eng getaktete Intervalle mit geringer Streuung dominieren.

**2. Welche Muster lassen sich in den Wasserfalldarstellungen erkennen?**
Es zeigt sich eine deutliche Verschiebung der spektralen Leistungsdichte. Das VLF-Band dominiert durchgehend, jedoch verschieben sich in Ruhe- und Schlafphasen deutliche Energieanteile in das parasympathische HF-Band, was sich als Entstehen kleinerer "Hügelketten" im hinteren Teil der Frequenzachse visualisiert.

**3. Wie verändern sich LF-, HF- und LF/HF Werte über die Zeit?**
Sie agieren weitgehend als Antagonisten. In Belastungssituationen fällt die absolute HF-Leistung, während der LF-Anteil relativ stabil bleibt oder steigt, wodurch die LF/HF-Ratio nach oben schnellt. Im Schlaf kehrt sich dieses Muster um und der Quotient fällt auf sein Minimum.

**4. Welche physiologischen Zusammenhänge lassen sich beobachten?**
Besonders in den `rr_zoom_plots` sowie im HF-Band des FFT-Spektrums ist der Einfluss der Atmung auf den Herzschlag (Respiratorische Sinusarrhythmie) unverkennbar. Dies belegt die direkte vagale Kontrolle des Herzens.

**5. Welche Herausforderungen entstehen bei der Verarbeitung großer EKG-Datensätze?**
Die massive Anzahl an Datenpunkten erfordert ein striktes Speichermanagement (Downsampling durch RR-Extraktion). Zudem erfordert die visuelle Darstellung (Wasserfall, 24h-Scatter) fortgeschrittene Techniken wie logarithmische oder Quadratwurzel-Skalierung, da die enormen Amplitudenunterschiede zwischen VLF und HF eine lineare Betrachtung unmöglich machen.