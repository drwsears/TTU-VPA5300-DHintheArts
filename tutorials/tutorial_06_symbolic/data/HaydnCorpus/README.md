Sears, David R. W., Marcus T. Pearce, William E. Caplin, and Stephen McAdams. 2017. "Simulating melodic and harmonic expectations for tonal cadences using probabilistic models." Journal of New Music Research. https://doi.org/10.1080/09298215.2017.1367010


NOTES ON THE SUPPLEMENTARY FILES.
========================

* Each movement is represented with a midi file (e.g., haydn_op17_no01_mv01.mid) and an annotation file (e.g., haydn_op17_no01_mv01.txt).

* All movements were downloaded from the KernScores database in MIDI format (http://kern.ccarh.org/). To ensure each instrumental part would qualify as monophonic, all trills, extended string techniques, and other ornaments were removed. For events presenting extended string techniques (e.g., double stops), note events in each part were retained that preserved the voice leading both wihtin and between instrumental parts. 

* Each tab-delimited txt file contains the following three headings: (1) Descriptive Information, (2) Tonal Regions, and (3) Cadences.

  (1) Composer, Genre, Opus, Work, Mvt, Year, Time Signature, Pulse, Key Signature, and Upbeat (or anacrusis). 'Pulse' refers to the note duration at which tonal regions or cadences are identified. For example, a quarter note represents the pulse duration in common time movements, so a cadence terminating on beat three receives a value of 3, whereas a cadence terminating on the and of beat three receives a value of 3.5.

  (2) Key, Mode, Start Bar Number, Start Pulse Number (using the pulse duration specified in Descriptive Information), End Bar Number, and End Pulse Number. The words "Begin" and "End" appear if the boundary for a particular tonal region appears at the beginning or end of the midi file, respectively. Note that tonal regions may overlap due to the presence of a pivot region.

  (3) Cadence Category (PAC, IAC, HC, DC, EV), Melodic Dissonance, Violin Bar Number, Violin Pulse Number, Cello Bar Number, Cello Pulse Number. If the cadence contains a melodic dissonance, the terminal events of the cadence may appear in different metric positions in the first violin and cello, hence the additional annotations for both instrumental parts.
