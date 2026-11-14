import json, os
HERE=os.path.dirname(os.path.abspath(__file__))
from PIL import Image, ImageDraw, ImageFont
L=json.load(open(os.path.join(HERE,'site/pregen/layout.json')))
S=2.6; M=20
def F(n): return ImageFont.truetype('/usr/share/fonts/truetype/freefont/FreeSansBold.ttf',n)
COL={'green':(120,200,120),'yellow':(240,215,90),'red':(225,110,100)}
def colr(n):
    for k,v in COL.items():
        if n.endswith(k): return v
    return {'ship':(170,170,220),'cards_small':(230,170,120),'characters':(150,190,230),'misc_tokens':(80,190,200),'misc_top':(110,215,225)}[n]
LAB={
 'chance_green':'Chance\ncards','chance_yellow':'Chance\ncards','chance_red':'Chance\ncards',
 'sector_green':'Sector\nData','sector_yellow':'Sector\nData','sector_red':'Sector\nData',
 'hex_green':'19 hex\ntiles','hex_yellow':'19 hex\ntiles','hex_red':'19 hex\ntiles',
 'ship':'Ship','cards_small':'Salvage |\nAssignment',
 'characters':'Characters+SOS+Died+Settled Victory | Micro-Expansion | 6 cube colours',
 'misc_tokens':'30 round\ntokens\n(2 stacks)','misc_top':'D6+red cube\nd8 x2\ngold cubes\ncredit bars'}
trays=L['trays']
def panel(title,sub,items):
    w=int(285*S)+2*M; h=int(285*S)+2*M+100
    im=Image.new('RGB',(w,h),'white'); d=ImageDraw.Draw(im)
    d.text((M,8),title,fill='black',font=F(26)); d.text((M,40),sub,fill=(90,90,90),font=F(16))
    oy=70
    d.rectangle([M,oy+M,M+285*S,oy+M+285*S],outline='black',width=3)
    def box(x,y,ww,dd,fill,label,alpha=None,fs=14):
        X0=M+x*S; X1=X0+ww*S; Y1=oy+M+(285-y)*S; Y0=Y1-dd*S
        d.rectangle([X0,Y0,X1,Y1],fill=fill,outline='black',width=2)
        if label:
            lines=label.split(' | ') if ' | ' in label else label.split('\n')
            yy=(Y0+Y1)/2-len(lines)*(fs+2)/2
            for ln in lines:
                tw=d.textlength(ln,font=F(fs)); d.text(((X0+X1)/2-tw/2,yy),ln,fill='black',font=F(fs)); yy+=fs+2
    for it in items:
        box(*it)
    d.text((M,h-30),'front of box (open side of lids)',fill=(90,90,90),font=F(14))
    return im
def T(n): return next(t for t in trays if t['name']==n)
def tr(n,hl=True,lab=True):
    t=T(n); return (t['x'],t['y'],t['w'],t['d'],colr(n),LAB[n] if lab else '')
def ghost(n): t=T(n); return (t['x'],t['y'],t['w'],t['d'],(225,225,225),'',None)
P=[]
low=['chance_green','chance_yellow','chance_red','hex_green','hex_yellow','hex_red','ship','cards_small','characters','misc_tokens']
P.append(panel('1  Floor level','Put these 10 trays in first (all lids on top, slide opening toward the front)',[tr(n) for n in low]))
items=[ghost(n) for n in low]
for n in ['sector_green','sector_yellow','sector_red','misc_top']: items.append(tr(n))
P.append(panel('2  Stack on top','Sector Data trays on the Chance trays; dice/bars/cubes tray on the token tray',items))
items=[ghost(n) for n in low+['sector_green','sector_yellow','sector_red','misc_top']]
b=L['layers']['boards']; items.append((b['x'],b['y'],b['w'],b['d'],(190,150,220),'6 player boards (Crew Consoles)\n240 x 125, about 23 mm'))
P.append(panel('3  Player boards','Six boards stacked (about 23 mm), flat on the characters tray (back-left)',items))
items=[ghost(n) for n in low+['sector_green','sector_yellow','sector_red','misc_top']]+[(b['x'],b['y'],b['w'],b['d'],(225,225,225),'')]
k=L['layers']['booklets']; items.append((k['x'],k['y'],k['w'],k['d'],(240,170,200),'3 Encounter Booklets\n210 x 278, stacked'))
P.append(panel('4  Booklets','3 booklets lie flat on the Sector trays and the player boards',items))
rb=L['layers']['rulebook']; m=L['layers']['main']
base=[ghost(n) for n in low+['sector_green','sector_yellow','sector_red','misc_top']]+[(k['x'],k['y'],k['w'],k['d'],(225,225,225),'')]
P.append(panel('5  Rule book','Main rule book, full box footprint, lies flat on the booklets (3 mm)',base+[(rb['x'],rb['y'],rb['w'],rb['d'],(240,200,120),'Rule book\n285 x 285 x 3')]))
P.append(panel('6  Main board','Folded main board on top, flush with the rim (10.12 mm)',base+[(rb['x'],rb['y'],rb['w'],rb['d'],(225,225,225),''),(m['x'],m['y'],m['w'],m['d'],(160,185,240),'Main board (folded)\n285 x 285 x 10')]))
w,h=P[0].size
sheet=Image.new('RGB',(2*w,3*h),'white')
for i,p in enumerate(P): sheet.paste(p,((i%2)*w,(i//2)*h))
sheet.save(os.path.join(HERE,'site/fill-order.png'))
print(sheet.size)
