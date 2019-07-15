program sokoban_u;
uses WinCRT, sysutils, strutils, Graph;
type blok_kolory = record
	X, Y, R, G, B: integer;
	A: real;
end;

var	mapa: array[0..20, 0..20] of integer;
	f: text;
	iG_1, iG_2: smallint;
	bloczek: array[0..10, 0..39, 0..39] of blok_kolory;
	klawisz: char;
	licz_x, licz_y, LB_licznik, i_y, i_x, gracz_x, gracz_y, status_gry, ruchy, max_status, poziom: integer;
	
{const vga: word = $A000;}
{#var oldmode: byte;}
	
procedure checkPlayer();
begin
	for licz_y := 0 to 20 do
		for licz_x := 0 to 20 do
			if (mapa[licz_x, licz_y] = 3) OR (mapa[licz_x, licz_y] = 6) then
			begin
				gracz_x := licz_x;
				gracz_y := licz_y;
			end;
end;
	
procedure drawBG();
begin
	SetRGBPalette(0, 54, 54, 54);
	SetFillStyle(1, 0);
	Bar(0, 0, GetMaxX, GetMaxY);
end;

function usun(ciag: string): string;
var	i: integer = 1;
	n: string = '';
begin
	repeat
		if (' ' <> ciag[i]) OR (#9 <> ciag[i]) then
			n := n+ciag[i];
		inc(i);
	until i > length(ciag);
	usun := n;
end;

procedure loadMap(nazwa_mapy: string);
var znaki: string;
	sep1, sep2, eline, g_X, g_Y, rodzaj: integer;
begin
	assign(f, 'data\maps\'+nazwa_mapy);
	reset(f);
	repeat
		ReadLn(f, znaki);
		sep1 := Pos('|', znaki);
		sep2 := PosEx('|', znaki, sep1+1);
		eline := length(znaki); 
		g_X := StrToInt(Copy(znaki, 1, sep1-1));
		g_Y := StrToInt(Copy(znaki, sep1+1, sep2-sep1-1));
		rodzaj := StrToInt(Copy(znaki, sep2+1, eline));
		mapa[g_X][g_Y] := rodzaj;
	until eof(f);
	close(f);
end;

procedure resetMap();
begin
	for i_y := 0 to 39 do
		for i_x := 0 to 39 do
			mapa[i_x][i_y] := 0;
end;

procedure LoadBlock(bname: string);
var f: text;
	_1, _2, _3, _4, _5, koniec: integer;
	i_y, i_x: integer;
	znaki: string;
begin
	assign(f, 'data\blocks\'+bname);
	reset(f);
	for i_y := 0 to 39 do
		for i_x := 0 to 39 do
		begin
			ReadLn(f, znaki);
			znaki := usun(znaki);
			_1 := Pos('|', znaki);
			_2 := PosEx('|', znaki, _1+1);
			_3 := PosEx('|', znaki, _2+1);
			_4 := PosEx('|', znaki, _3+1);
			_5 := PosEx('|', znaki, _4+1);
			koniec := length(znaki);
			bloczek[LB_licznik, i_x, i_y].X := StrToInt(Copy(znaki, 0, _1-1));
			bloczek[LB_licznik, i_x, i_y].Y := StrToInt(Copy(znaki, _1+1, _2-_1-1));
			bloczek[LB_licznik, i_x, i_y].R := StrToInt(Copy(znaki, _2+1, _3-_2-1));
			bloczek[LB_licznik, i_x, i_y].G := StrToInt(Copy(znaki, _3+1, _4-_3-1));
			bloczek[LB_licznik, i_x, i_y].B := StrToInt(Copy(znaki, _4+1, _5-_4-1));
			bloczek[LB_licznik, i_x, i_y].A := StrToFloat(Copy(znaki, _5+1, koniec-_5));
		end;
	inc(LB_licznik);
end;


procedure DrawBox(x, y, LB_licznik: integer);
var	bgR: integer = 54;
	bgG: integer = 54;
	bgB: integer = 54;
	R_alpha, G_alpha, B_alpha: real;
begin
	for i_y := 0 to 39 do
		for i_x := 0 to 39 do
		begin
			if (bloczek[LB_licznik, i_x, i_y].A = 1.0) then
				SetRGBPalette(0, bloczek[LB_licznik, i_x, i_y].R, bloczek[LB_licznik, i_x, i_y].G, bloczek[LB_licznik, i_x, i_y].B)
			else if (bloczek[LB_licznik, i_x, i_y].A = 0.0) then
				SetRGBPalette(0, bgR, bgG, bgB)
			else
			begin
				R_alpha := (bloczek[LB_licznik, i_x, i_y].R*bloczek[LB_licznik, i_x, i_y].A)+(bgR*(1-bloczek[LB_licznik, i_x, i_y].A));
				G_alpha := (bloczek[LB_licznik, i_x, i_y].G*bloczek[LB_licznik, i_x, i_y].A)+(bgG*(1-bloczek[LB_licznik, i_x, i_y].A));
				B_alpha := (bloczek[LB_licznik, i_x, i_y].B*bloczek[LB_licznik, i_x, i_y].A)+(bgB*(1-bloczek[LB_licznik, i_x, i_y].A));
				SetRGBPalette(0, Round(R_alpha), Round(G_alpha), Round(B_alpha));
			end;
			PutPixel(bloczek[LB_licznik, i_x, i_y].X+x*40, bloczek[LB_licznik, i_x, i_y].Y+y*40, 0);
		end;
end;

procedure drawMap();
begin
	for licz_y := 0 to 20 do
		for licz_x := 0 to 20 do
		begin
			if mapa[licz_x][licz_y] = 0 then
				// ...
			else if mapa[licz_x][licz_y] = 1 then
				drawBox(licz_x, licz_y, 1)
			else if mapa[licz_x][licz_y] = 2 then
				drawBox(licz_x, licz_y, 2)
			else if mapa[licz_x][licz_y] = 3 then
				drawBox(licz_x, licz_y, 3)
			else if mapa[licz_x][licz_y] = 4 then
				drawBox(licz_x, licz_y, 4)
			else if mapa[licz_x][licz_y] = 5 then
				drawBox(licz_x, licz_y, 5)
			else if mapa[licz_x][licz_y] = 6 then
				drawBox(licz_x, licz_y, 6)
			else
				WriteLn('[', licz_x, ',', licz_y, '] Wystapil problem z narysowaniem skrzynki.');
		end;
end; //#a00033

procedure drawNONE();
begin
	SetRGBPalette(0, 54, 54, 54);
	SetFillStyle(1, 0);
	Bar(gracz_x*40, gracz_y*40, gracz_x*40+39, gracz_y*40+39);
end;

procedure sprawdz_status_MX();
begin
	for licz_y := 0 to 20 do
		for licz_x := 0 to 20 do
			if (mapa[licz_x, licz_y] = 2) then
				inc(max_status);
end;

procedure move(kierunek: string);
var x_1, x_2, y_1, y_2: integer;
begin
	x_1 := 0;
	x_2 := 0;
	y_1 := 0;
	y_2 := 0;
	if (kierunek = 'up') then
	begin
		y_1 := -1;
		y_2 := -2;
	end
	else if (kierunek = 'left') then
	begin
		x_1 := -1;
		x_2 := -2;
	end
	else if (kierunek = 'right') then
	begin
		x_1 := 1;
		x_2 := 2;
	end
	else if (kierunek = 'down') then
	begin
		y_1 := 1;
		y_2 := 2;
	end;
	if (mapa[gracz_x+x_1, gracz_y+y_1] = 0) AND (mapa[gracz_x, gracz_y] = 6) then
	begin
		drawBox(gracz_x, gracz_y, 4);
		mapa[gracz_x, gracz_y] := 4;
		drawBox(gracz_x+x_1, gracz_y+y_1, 3);
		mapa[gracz_x+x_1, gracz_y+y_1] := 3;
	end
	else if (mapa[gracz_x, gracz_y] = 3) AND (mapa[gracz_x+x_1, gracz_y+y_1] = 5) AND (mapa[gracz_x+x_2, gracz_y+y_2] = 0) then
	begin
		drawNONE();
		mapa[gracz_x, gracz_y] := 0;
		drawBox(gracz_x+x_1, gracz_y+y_1, 6);
		mapa[gracz_x+x_1, gracz_y+y_1] := 6;
		drawBox(gracz_x+x_2, gracz_y+y_2, 2);
		mapa[gracz_x+x_2, gracz_y+y_2] := 2;
		dec(status_gry);
		WriteLn(status_gry, '/', max_status);
	end
	else if (mapa[gracz_x, gracz_y] = 6) AND (mapa[gracz_x+x_1, gracz_y+y_1] = 2) AND (mapa[gracz_x+x_2, gracz_y+y_2] = 0) then
	begin
		drawBox(gracz_x, gracz_y, 4);
		mapa[gracz_x, gracz_y] := 4;
		drawBox(gracz_x+x_1, gracz_y+y_1, 3);
		mapa[gracz_x+x_1, gracz_y+y_1] := 3;
		drawBox(gracz_x+x_2, gracz_y+y_2, 2);
		mapa[gracz_x+x_2, gracz_y+y_2] := 2;
	end
	else if (mapa[gracz_x, gracz_y] = 6) AND (mapa[gracz_x+x_1, gracz_y+y_1] = 5) AND (mapa[gracz_x+x_2, gracz_y+y_2] = 0) then
	begin
		drawBox(gracz_x, gracz_y, 4);
		mapa[gracz_x, gracz_y] := 4;
		drawBox(gracz_x+x_1, gracz_y+y_1, 6);
		mapa[gracz_x+x_1, gracz_y+y_1] := 6;
		drawBox(gracz_x+x_2, gracz_y+y_2, 2);
		mapa[gracz_x+x_2, gracz_y+y_2] := 2;
		dec(status_gry);
		WriteLn(status_gry, '/', max_status);
	end
	else if (mapa[gracz_x, gracz_y] = 6) AND (mapa[gracz_x+x_1, gracz_y+y_1] = 5) AND (mapa[gracz_x+x_2, gracz_y+y_2] = 4) then
	begin
		drawBox(gracz_x, gracz_y, 4);
		mapa[gracz_x, gracz_y] := 4;
		drawBox(gracz_x+x_1, gracz_y+y_1, 6);
		mapa[gracz_x+x_1, gracz_y+y_1] := 6;
		drawBox(gracz_x+x_2, gracz_y+y_2, 5);
		mapa[gracz_x+x_2, gracz_y+y_2] := 5;
	end
	else if (mapa[gracz_x+x_1, gracz_y+y_1] = 4) AND (mapa[gracz_x, gracz_y] = 6) then
	begin
		drawBox(gracz_x, gracz_y, 4);
		mapa[gracz_x, gracz_y] := 4;
		drawBox(gracz_x+x_1, gracz_y+y_1, 6);
		mapa[gracz_x+x_1, gracz_y+y_1] := 6;
	end
	else if (mapa[gracz_x, gracz_y] = 3) AND (mapa[gracz_x+x_1, gracz_y+y_1] = 5) AND (mapa[gracz_x+x_2, gracz_y+y_2] = 4) then
	begin
		drawNONE();
		mapa[gracz_x, gracz_y] := 0;
		drawBox(gracz_x+x_1, gracz_y+y_1, 6);
		mapa[gracz_x+x_1, gracz_y+y_1] := 6;
		drawBox(gracz_x+x_2, gracz_y+y_2, 5);
		mapa[gracz_x+x_2, gracz_y+y_2] := 5;
	end
	else if (mapa[gracz_x+x_1, gracz_y+y_1] = 0) then
	begin
		drawNONE();
		mapa[gracz_x, gracz_y] := 0;
		drawBox(gracz_x+x_1, gracz_y+y_1, 3);
		mapa[gracz_x+x_1, gracz_y+y_1] := 3;
	end
	else if (mapa[gracz_x, gracz_y] = 3) AND (mapa[gracz_x+x_1, gracz_y+y_1] = 2) AND (mapa[gracz_x+x_2, gracz_y+y_2] = 0) then
	begin
		drawNONE();
		mapa[gracz_x, gracz_y] := 0;
		drawBox(gracz_x+x_1, gracz_y+y_1, 3);
		mapa[gracz_x+x_1, gracz_y+y_1] := 3;
		drawBox(gracz_x+x_2, gracz_y+y_2, 2);
		mapa[gracz_x+x_2, gracz_y+y_2] := 2;
		inc(ruchy);
	end
	else if (mapa[gracz_x+x_1, gracz_y+y_1] = 2) AND (mapa[gracz_x+x_2, gracz_y+y_2] = 4) then
	begin
		drawNONE();
		mapa[gracz_x, gracz_y] := 0;
		drawBox(gracz_x+x_1, gracz_y+y_1, 3);
		mapa[gracz_x+x_1, gracz_y+y_1] := 3;
		drawBox(gracz_x+x_2, gracz_y+y_2, 5);
		mapa[gracz_x+x_2, gracz_y+y_2] := 5;
		inc(status_gry);
		WriteLn(status_gry, '/', max_status);
		inc(ruchy);
	end
	else if (mapa[gracz_x+x_1, gracz_y+y_1] = 4) AND (mapa[gracz_x, gracz_y] = 3) then
	begin
		drawNONE();
		mapa[gracz_x, gracz_y] := 0;
		drawBox(gracz_x+x_1, gracz_y+y_1, 6);
		mapa[gracz_x+x_1, gracz_y+y_1] := 6;
	end;
end;

BEGIN
	iG_1 := VGA;
	iG_2 := VGAHi;
	initGraph(iG_1, iG_2, '');
	LB_licznik := 1;
	status_gry := 0;
	ruchy := 0;
	poziom := 1;
	drawBG();
	LoadBlock('wall.dat');
	LoadBlock('box.dat');
	LoadBlock('player.dat');
	LoadBlock('end_1.dat');
	LoadBlock('end_2.dat');
	LoadBlock('pe.dat');
	loadMap('1.dat');
	drawMap();
	sprawdz_status_MX();
	repeat
		klawisz := ReadKey();
		checkPlayer();
		case klawisz of
			#72: move('up');
			#75: move('left');
			#77: move('right');
			#80: move('down');
		end;
		if status_gry = max_status then
		begin
			inc(poziom);
			WriteLn('Wygrales! Przesunales skrzynie ', ruchy, ' razy. Przeszedles poziom ', poziom-1, '.');
			resetMap();
			drawBG();
			loadMap(IntToStr(poziom)+'.dat');
			drawMap();
			max_status := 0;
			sprawdz_status_MX();
			status_gry := 0;
			ruchy := 0;
		end;
	until false;
	Halt();
END.
