# Docker Tutorial

Dieses Repository enthält ein Beispiel-Projekt für Forschende, die **Docker zum ersten Mal ausprobieren** möchten. Es zeigt, wie man ein Analyse-Skript (R) mit Docker containerisiert und reproduzierbar macht.

Das Projekt enthält alle Dateien, um das Beispiel, welches im Tutorial-Video gezeigt wurde, selber auszuprobieren. 

**Link zum Tutorial von EVA4MII:**

## 📁 Dateien im Repository

```
.
├── Dockerfile                     # Anleitung für Docker, wie das Image gebaut wird
├── Docker_Tutorial.R              # Das R-Skript (Analyse-Code)
├── pima-docker-repo.tar           # Gesamtes Projekt als TAR-Datei
├── Docker_In/
│   └── pima_raw_data.csv          # Eingabedaten (CSV) 
└── Docker_Out/
    ├── pima_summary_metrics.csv   # Beispiel-Ergebnis: Statistiken
    └── pima_bmi_glucose_plot.png  # Beispiel-Ergebnis: Plot
```

| Datei | Erklärung |
|-------|-----------|
| **Dockerfile** | Sagt Docker: "Starte mit R, installiere diese Pakete, kopiere das Skript." Kann mit jedem Texteditor geöffnet und bearbeitet werden; wichtig: Datei hat keine Dateiendung! |
| **Docker_Tutorial.R** | Das R-Skript: liest CSV → berechnet Statistiken → erstellt Plot → speichert Ergebnisse |
| **Docker_In/** | Ordner für Eingabedaten |
| **pima_raw_data.csv** | Eingabedaten: Gesundheitsmessungen von Frauen der Pima-Indianer-Bevölkerung |
| **Docker_Out/** | Ordner für Ergebnisse. Enthält bereits die Dateien, die das R-Skript generiert. |
| **pima-docker-repo.tar** | Docker Image als TAR-Export - so kann das Projekt mit Kolleg:innen geteilt werden |

## 🚀 Workflow in Docker Desktop

Hier sind alle Schritte: **Build → Save → Load → Run**

### Schritt 0: Das R-Skript verstehen

Bevor du das Image baust, schau dir `Docker_Tutorial.R` an. Das Skript hat **Docker-spezifische Besonderheiten**:

**1. Umgebungsvariable für den Dateinamen:**
```r
csv_filename <- Sys.getenv("CSV_FILE")
```
Das Skript erwartet, dass du die CSV-Datei als **Umgebungsvariable `CSV_FILE`** übergibst. So kann das gleiche Skript mit verschiedenen Dateien laufen.

**2. Feste Input/Output-Ordner:**
```r
input_file <- file.path("/input", csv_filename)
write.csv(summary_stats, "/output/pima_summary_metrics.csv", row.names = FALSE)
```
Das Skript erwartet:
- Eingabedaten im Container-Ordner `/input/` (wird von außen mounted)
- Ergebnisse werden in `/output/` gespeichert (wird von außen mounted)

Du bindest diese Ordner während der Container-Erstellung ein (s. Schritt 4).

**3. Fehlerbehandlung & Logging:**
Das Skript gibt hilfreiche Fehlermeldungen aus (mit `cat()`), z.B. wenn die CSV nicht gefunden wird. Das hilft beim Debugging.

**Was Kolleg:innen wissen müssen:**

Wenn du das Image/Container mit Kollegen teilst, sag ihnen:
- ✅ Wie heißen die **Umgebungsvariablen** für das Skript? (Antwort: `CSV_FILE`)
- ✅ Welche **Ergebnisdateien** werden erstellt? (Antwort: `pima_summary_metrics.csv` und `pima_bmi_glucose_plot.png`)
- ✅ Welche **Ordner** müssen gemountet werden? (Antwort: `/Docker_In` und `/Docker_Out`)

### Schritt 1: Docker Image bauen

1. Klone dieses Repo oder lade es dir als .zip herunter und entpacke es
2. Docker Desktop starten
3. Öffne das **Terminal** 
4. Navigiere zum Repo-Ordner:
   ```bash
   cd /pfad/zum/pima-docker-repo
   ```

5. Baue das Image:
   ```bash
   docker build -t pima-analysis:1.0 .
   ```

Docker liest die `Dockerfile`, installiert die R-Pakete und erstellt ein Image. Das dauert beim ersten Mal ein paar Minuten.

### Schritt 2: Image als TAR speichern

Speichere das fertige Image als TAR-Datei – so kannst du es mit Kolleg:innen teilen:

```bash
docker save pima-analysis:1.0 -o pima-analysis.tar
```

Die Datei `pima-analysis.tar` wird im aktuellen Ordner erstellt.

### Schritt 3: Image laden (von TAR)

Wenn du das Image später (oder auf einem anderen Computer) nutzen möchtest, lade es aus der TAR:

```bash
docker load --input pima-analysis.tar
```

Wenn du das Image erstmalig entpackst, dann taucht es nun im Images Tab im DockerDesktop auf und kann von dort ausgeführt werden.


### Schritt 4: Container ausführen

1. Öffne den **Images Tab in DockerDesktop**
2. Klicke beim Image auf das **Play-Icon** (▶)
3. Lege einen Namen für den Container fest, bspw.: docker_tutorial
4. **Volumes** hinzufügen (optional settings Tab)
   - Lege die Host Paths fest, das sind die Pfade zu den Input und Output Ordnern, die lokal auf deinem Rechner liegen
   - Lege die Container Paths fest, diese stehen im R-Skript und müssen dir vom Skript-Ersteller mitgeteilt werden; in unserem Falle /input und /output
   - mehrere Volumes kannst du mit dem **+** Symbol hinzufügen
5. **Environment Variables** hinzufügen
   - die Variable heißt CSV_FILE
   - der Value ist der Dateiname unserer Input-Datei, hier_ pima_raw_data.csv
6. Klicke auf **Run**: Container startet


### Schritt 5: Ergebnisse anschauen

Im `output/`-Ordner auf deinem Rechner findest du nun:
- **pima_summary_metrics.csv** – Statistiken (Anzahl, Durchschnitte, Diabetes-Häufigkeit)
- **pima_bmi_glucose_plot.png** – Visualisierung (Beziehung BMI ↔ Glukose)

---

**Viel Erfolg beim Lernen! 🐳**
