"""THE MOUNTAIN MAN: Dashrath Manjhi, about 61 s, Hindi voice-over.

One wall, left to right then down:
  cold open (the hills, the stamp, the title)  ->  the Bihar map  ->  the two villages and the hill
  (the long road, Falguni, Manjhi)  ->  down to the work (1960, hammer and chisel, the tally, 22 years)
  ->  the path itself (1982, 360 x 30 ft)  ->  back up to the short road  ->  back to the stamp  ->  the whole wall.

Every time comes from the voice-over: doc.L(i) line start, doc.E(i) line end, doc.W(i, word) when a
spoken (Hindi) word lands. World units are 4K px at zoom 1.
"""
from engine import (HILITE, MUSTARD, RED, RUST, WHITE, BigText, Card, Chalk, Counter, Film, GeoMap, MapPin, PenMark,
                    Print, RegionFill, Route, Stamp, StringLine)

CREAMY = (244, 238, 226)
K = 80000                         # map scale: Bihar about 7,000 px across

CO = (-12500, 0)                  # cold open cluster, out on the cork left of the map
VG, VW = (10100, -300), (14500, -300)   # the two villages, right of the map
HILL = (12300, -300)
WORK = (2500, 9800)               # the work cluster, below
PATH = (15500, 9800)              # the finished path


def build_film(doc):
    L, E, W = doc.L, doc.E, doc.W
    film = Film(doc.duration, fps=30, look="wall")
    shot, cue = film.shot, film.cue

    bihar = film.add(GeoMap(doc.map("bihar"), K, look="explainer"))
    gehlaur, gaya = bihar.place("Gehlaur"), bihar.place("Gaya")

    # ============================================================ COLD OPEN (1-3)
    cx, cy = CO
    hills = film.add(Print("P01", cx, cy + 200, 3800, rot=-1.4, t_in=0.0))
    film.add(BigText("ONE MAN", cx - 900, cy - 1650, 300, W(1, "आदमी") - 0.1, t_out=L(3), rgb=CREAMY, type_on=0.3))
    film.add(BigText("ONE HAMMER", cx + 1100, cy - 1650, 300, W(1, "हथौड़ा") - 0.1, t_out=L(3), rgb=CREAMY, type_on=0.3))
    film.add(Stamp("MADMAN?", cx + 700, cy + 900, size=420, rot=-8, t_in=W(2, "पागल") - 0.05))
    title_t = W(3, "झुक") + 0.1
    film.add(BigText("THE MOUNTAIN MAN", cx, cy - 2250, 640, title_t, bar=HILITE, bar_h=0.92, rgb=(30, 26, 22), shadow=False, hit=0.9))
    cue("boom", title_t, 0.5)

    shot(0.0, cx + 200, cy - 300, 0.80, rot=-1.0, radius=2400, strength=0.45)
    shot(W(1, "पहाड़") - 0.2, cx, cy - 100, 0.62, rot=-0.5, radius=2600, strength=0.45)
    shot(L(2) + 0.4, cx + 400, cy + 600, 0.74, rot=0.0, radius=2200, strength=0.5)
    shot(W(2, "पागल") + 0.25, cx + 650, cy + 850, 0.92, rot=0.6, radius=1600, strength=0.55)
    shot(L(3) + 0.4, cx, cy - 300, 0.52, rot=0.2, radius=3400, strength=0.45)
    shot(E(3) + 0.3, cx, cy - 900, 0.48, rot=0.0, radius=3800, strength=0.4)

    # ============================================================ THE REASON (4-7)
    # 4 the map: Bihar fills, a pin on Gehlaur, Gaya beside it
    film.add(RegionFill(bihar, ["Bihar"], RUST, L(4) + 0.2, to_rgb=MUSTARD, t_change=L(5) + 0.4, alpha=0.9))
    film.add(BigText("BIHAR", -600, -2200, 520, W(4, "बिहार") + 0.1, rgb=CREAMY, shadow=True))
    film.add(MapPin(*gaya, "GAYA", t_in=W(4, "गया"), label_side="left", size=2.4, label_size=170))
    film.add(MapPin(*gehlaur, "GEHLAUR", t_in=W(4, "गहलौर") - 0.1, label_side="right", size=3.0, label_size=210))
    shot(L(4) + 0.3, 0, -300, 0.30, radius=6500, strength=0.3)
    shot(W(4, "गया") + 0.2, gehlaur[0] - 300, gehlaur[1] - 200, 0.55, radius=3000, strength=0.45)
    shot(E(4) + 0.1, gehlaur[0] + 300, gehlaur[1], 0.68, radius=2600, strength=0.5)

    # 5 out to the two villages: the hill between them, the long road around it
    film.add(StringLine(gehlaur, (VG[0] - 120, VG[1] - 60), t_in=L(5) - 0.1, dur=0.8, sag=0.03, width=18))
    film.add(MapPin(*VG, "GEHLAUR", t_in=L(5) + 0.3, label_side="left", size=2.6, label_size=170))
    film.add(MapPin(*VW, "HOSPITAL", t_in=W(5, "अस्पताल") - 0.1, label_side="right", size=2.6, label_size=170))
    film.add(Print("P01", HILL[0], HILL[1] + 150, 2200, rot=2.0, t_in=W(5, "पथरीला") - 0.25, pin=True))
    long_road = film.add(Route(VG, VW, t_in=W(5, "पथरीला"), dur=1.4, bend=-0.55, width=60, t_out=W(13, "पंद्रह") + 0.6))
    km55 = film.add(BigText("55 KM", HILL[0], HILL[1] - 3450, 520, W(5, "पहाड़") + 0.2, t_out=W(13, "पंद्रह") + 0.6, rgb=CREAMY))
    shot(L(5) + 0.5, 8000, -300, 0.30, radius=7000, strength=0.25)
    shot(W(5, "अस्पताल") + 0.3, HILL[0], -900, 0.33, radius=5200, strength=0.3)
    shot(E(5) + 0.2, HILL[0], -1200, 0.36, radius=5200, strength=0.3)

    # 6 Falguni
    falg = film.add(Card(HILL[0] - 2200, 3500, 3600, 1700, L(6) + 0.1, title="FALGUNI DEVI",
                         lines=["Injured crossing the hill", "No treatment in time"], accent=RED, rot=-1.2,
                         title_size=300, body_size=170))
    film.add(StringLine((VG[0] + 60, VG[1] + 120), (HILL[0] - 3800, 2700), t_in=L(6) + 0.2, dur=0.6, sag=0.05, width=14))
    film.add(PenMark("underline", HILL[0] - 2200, 4250, 2900, 40, t_in=W(6, "इलाज") - 0.1, dur=0.5, width=26, rgb=RED, rot=-1.2))
    shot(L(6) + 0.5, HILL[0] - 2200, 3500, 0.78, rot=-0.8, radius=2200, strength=0.55)
    shot(E(6) - 0.1, HILL[0] - 2100, 3700, 0.84, rot=-0.4, radius=2100, strength=0.55)

    # 7 Manjhi, by his statue at Gehlaur
    statue = film.add(Print("P05", HILL[0] + 2500, 3900, 2000, rot=1.6, t_in=W(7, "दशरथ") - 0.15,
                            label="DASHRATH MANJHI", label_t=W(7, "मांझी")))
    film.add(StringLine((HILL[0] - 400, 3600), (HILL[0] + 1500, 2500), t_in=W(7, "दशरथ"), dur=0.5, sag=0.05, width=14))
    shot(W(7, "दशरथ") + 0.25, HILL[0] + 2500, 3700, 0.70, rot=0.8, radius=2300, strength=0.55)
    shot(W(7, "रास्ता"), HILL[0] + 1600, 2200, 0.48, rot=0.3, radius=3600, strength=0.4)

    # ============================================================ THE WORK (8-10)
    wx, wy = WORK
    cue("riser", L(8) - 1.0, 0.4, dur=0.9)
    film.add(BigText("1960", wx - 2600, wy - 2200, 1100, L(8) + 0.05, bar=HILITE, bar_h=0.42, hit=0.8))
    film.add(Card(wx - 2600, wy + 400, 3600, 1700, W(8, "हथौड़ा") - 0.15, title="HAMMER + CHISEL",
                  lines=["That was all he had"], accent=MUSTARD, rot=1.0, title_size=300, body_size=170))
    shot(L(8) + 0.4, wx - 2600, wy - 1700, 0.62, rot=-0.6, radius=2600, strength=0.5)
    shot(W(8, "हथौड़ा") + 0.3, wx - 2600, wy, 0.58, rot=0.4, radius=2800, strength=0.5)

    # 9 no machine, no help: struck through; then the tally, one mark per blow
    film.add(BigText("NO MACHINE", wx + 1900, wy - 1500, 380, W(9, "मशीन") - 0.15, rgb=CREAMY))
    film.add(BigText("NO HELP", wx + 1900, wy - 900, 380, W(9, "मदद") - 0.15, rgb=CREAMY))
    film.add(PenMark("strike", wx + 1900, wy - 1640, 2600, 0, t_in=W(9, "मशीन") + 0.2, dur=0.3, width=30, rgb=RED))
    film.add(PenMark("strike", wx + 1900, wy - 1040, 2000, 0, t_in=W(9, "मदद") + 0.2, dur=0.3, width=30, rgb=RED))
    blows = [W(9, "अकेले") + 0.1, W(9, "चोट") - 0.05, W(9, "चोट", nth=1) - 0.05, E(9) - 0.1]
    film.add(Chalk(wx + 1000, wy + 400, blows, height=480, gap=170, width=34, rgb=CREAMY))
    for t in blows[1:3]:
        film.shake(t, 18, 0.25)
    shot(L(9) + 0.3, wx + 1900, wy - 1300, 0.66, rot=-0.4, radius=2300, strength=0.5)
    shot(W(9, "चोट") - 0.2, wx + 1700, wy - 300, 0.58, rot=0.3, radius=2200, strength=0.55)

    # 10 the years roll up to twenty-two
    film.add(Counter(wx + 6800, wy - 300, 1400, 22, W(10, "पाँच") - 0.1, dur=W(10, "बाईस") - W(10, "पाँच") + 0.15, caption="YEARS"))
    shot(L(10) + 0.3, wx + 5800, wy - 300, 0.55, radius=2800, strength=0.45)
    shot(W(10, "बाईस") + 0.2, wx + 6800, wy - 200, 0.72, rot=0.6, radius=2200, strength=0.55)

    # ============================================================ THE PATH (11-13)
    px, py = PATH
    film.add(BigText("1982", px, py - 3300, 1000, W(11, "बयासी") - 0.2, bar=HILITE, bar_h=0.42, hit=0.8))
    path = film.add(Print("P03", px, py, 4200, rot=-1.0, t_in=W(11, "बयासी") + 0.1, label="THE PATH, GEHLAUR", label_t=W(11, "रास्ता")))
    shot(L(11) + 0.5, px - 600, py - 2600, 0.60, rot=-0.4, radius=2600, strength=0.45)
    shot(W(11, "रास्ता"), px, py, 0.58, rot=-0.6, radius=3000, strength=0.45)

    film.add(Counter(px - 1500, py + 2650, 820, 360, W(12, "तीन") - 0.1, dur=0.9, suffix=" FT", caption="LONG"))
    film.add(Counter(px + 1700, py + 2650, 820, 30, W(12, "तीस") - 0.1, dur=0.6, suffix=" FT", caption="WIDE"))
    shot(L(12) + 0.4, px - 900, py + 1900, 0.58, rot=0.2, radius=2800, strength=0.45)
    shot(W(12, "तीस") + 0.3, px + 600, py + 2200, 0.60, rot=0.4, radius=2800, strength=0.45)

    # 13 back up to the villages: the long road fades, the short one cuts straight through the hill
    film.add(Route((VG[0] + 150, VG[1]), (VW[0] - 150, VW[1]), t_in=W(13, "पंद्रह") - 0.3, dur=0.6, bend=0.02, width=70, rgb=HILITE))
    film.add(BigText("15 KM", HILL[0], HILL[1] + 2050, 560, W(13, "पंद्रह") - 0.05, bar=HILITE, bar_h=0.92, rgb=(30, 26, 22), shadow=False))
    film.add(PenMark("strike", HILL[0], HILL[1] - 3600, 2400, 0, t_in=W(13, "पचपन") + 0.4, dur=0.35, width=36, rgb=RED))
    shot(L(13) + 0.6, HILL[0], -1600, 0.36, rot=0.0, radius=5000, strength=0.3)
    shot(W(13, "पंद्रह") + 0.3, HILL[0], 300, 0.42, rot=0.3, radius=4200, strength=0.35)

    # ============================================================ CLOSE (14-15)
    film.add(PenMark("strike", cx + 700, cy + 900, 2900, 0, t_in=W(14, "पागल") + 0.15, dur=0.4, width=46, rgb=CREAMY, rot=-8))
    film.add(PenMark("ellipse", cx, cy - 2250, 7600, 1300, t_in=W(14, "माउंटेन") - 0.1, dur=0.7, width=30, rgb=CREAMY, rot=-2, seed=9))
    shot(L(14) + 0.5, cx + 500, cy + 700, 0.62, rot=-0.6, radius=2400, strength=0.5)
    shot(W(14, "माउंटेन"), cx, cy - 1700, 0.50, rot=0.0, radius=3800, strength=0.4)
    shot(L(15) + 0.4, cx + 3000, cy, 0.30, radius=9000, strength=0.25)
    shot(W(15, "इरादा"), 1500, 3500, 0.15, radius=18000, strength=0.15)
    shot(film.duration, 1700, 3700, 0.112, radius=26000, strength=0.08)

    film.fade_in, film.fade_out = 0.6, 1.6
    return film
