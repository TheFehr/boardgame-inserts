#!/usr/bin/env python3
"""Place the trays in the box and write site/pregen/layout.json.
Layers from the top: main board, booklets, player boards (back-left); trays below.
Checks: inside box, no tray overlaps another tray or a layer, and reports gaps under layers."""
import json, struct, itertools, os
here = os.path.dirname(os.path.abspath(__file__))
pre = os.path.join(here, 'site/pregen')
BOX = (285, 285, 72)
MAIN, RB, BOOK, PB = 10.12, 3, 9, 22.9
LAYERS = dict(   # x, y, z, w, d, h
    main=(0, 0, BOX[2] - MAIN, 285, 285, MAIN),
    rulebook=(0, 0, BOX[2] - MAIN - RB, 285, 285, RB),
    booklets=(0, 0, BOX[2] - MAIN - RB - BOOK, 210, 278, BOOK),
    boards=(0, 160, 23, 240, 125, PB),
)
def size(t):
    d = open(f'{pre}/{t}.stl', 'rb').read(); n = struct.unpack('<I', d[80:84])[0]
    mx = [-1e9]*3
    for i in range(n):
        v = struct.unpack('<12fH', d[84+i*50:134+i*50])
        for k in range(3):
            for c in range(3): mx[c] = max(mx[c], v[3+k*3+c])
    return round(mx[0], 1), round((mx[1]-0.9)/2, 1), round(mx[2], 1)   # STL y holds box + lid side by side
P = {}
for i, c in enumerate(('green', 'yellow', 'red')):
    P[f'chance_{c}'] = (i*76, 0, 0)
    P[f'sector_{c}'] = (i*76, 0, 27.5)
    P[f'hex_{c}'] = (i*76, 108, 0)
P['ship'] = (228, 0, 0)
P['cards_small'] = (228, 88, 0)
P['characters'] = (0, 160, 0)
P['misc_tokens'] = (240, 160, 0)
P['misc_top'] = (240, 160, 36)
out = []
for n, (x, y, z) in P.items():
    w, d, h = size(n); out.append(dict(name=n, x=x, y=y, z=z, w=w, d=d, h=h))
ok = True
def hit(a, b):
    return all(a[k] < b[k] + b[s] - 1e-6 and b[k] < a[k] + a[s] - 1e-6 for k, s in (('x','w'),('y','d'),('z','h')))
L = {k: dict(zip(('x','y','z','w','d','h'), v)) for k, v in LAYERS.items()}
for t in out:
    if t['x'] + t['w'] > BOX[0] + 1e-6 or t['y'] + t['d'] > BOX[1] + 1e-6 or t['z'] + t['h'] > BOX[2]: print('OUTSIDE', t['name']); ok = False
    for ln, l in L.items():
        if hit(t, dict(l, z=l['z'] + 0.06, h=l['h'] - 0.06)): print('COLLIDES with', ln, ':', t['name'], 'top', t['z'] + t['h'], '>', l['z']); ok = False
for a, b in itertools.combinations(out, 2):
    if hit(a, b): print('OVERLAP', a['name'], b['name']); ok = False
for a, b in itertools.combinations(L.values(), 2):
    pass
if hit(L['boards'], L['booklets']): print('LAYERS COLLIDE: boards/booklets'); ok = False
for t in out:   # gap between a tray top and whatever lies directly above it
    above = [l['z'] for l in L.values() if l['x'] < t['x'] + t['w'] and t['x'] < l['x'] + l['w'] and l['y'] < t['y'] + t['d'] and t['y'] < l['y'] + l['d'] and l['z'] >= t['z'] + t['h'] - 0.06]
    above += [o['z'] for o in out if o is not t and o['z'] >= t['z'] + t['h'] - 1e-6 and o['x'] < t['x'] + t['w'] and t['x'] < o['x'] + o['w'] and o['y'] < t['y'] + t['d'] and t['y'] < o['y'] + o['d']]
    gap = round(min(above) - (t['z'] + t['h']), 1) if above else None
    t['gap'] = gap
    if gap and gap > 0.05: print(f"gap {gap} mm above {t['name']}")
json.dump(dict(box=BOX, layers=L, trays=out), open(f'{pre}/layout.json', 'w'))
print('OK' if ok else 'PROBLEMS')
