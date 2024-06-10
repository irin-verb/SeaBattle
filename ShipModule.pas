unit ShipModule;
interface
  //игровое поле 10*10, представленное в виде поля 12*12, где границы заполнены нулями
  type Field = array[0..11,0..11] of integer; 
  var 
    A,B,C,D:Field; //A - исходное поле игрока; B - исходное поле компьютера; 
    //С - поле для выстрелов по полю противника; D - для выстрелов по полю игрока
    Start,Enemy:boolean; //флаг начала сражения и флаг хода врага (enemy - ходит компьютер, not enemy - игрок)
    MovesNumber:integer; //количество ходов игрока
    WinnerName:string;   //имя игрока
    
  //заполняет поле G нулями - т.е. поле без кораблей + границы (0 и 11-ый столбик и столбец) так же заполнены нулями
  procedure Nulls (var G: Field); 
  
  //расставляет корабли по полю случайным образом
  procedure Ships (var G: Field);
  
  //определяет, есть в точке (x;y) корабль длины s направления v
  function ShipStay(x,y,v,s:integer; var G: field):boolean; 
  
  //определяет, присутствует ли на поле полный необходимый набор кораблей
  function FieldRight(G:Field):boolean;
  
  //делает выстрел по полю для выстрелов DOP в точку (x;y) основываясь на данных исходного поля OSN
  procedure Boom(x,y:integer;var Osn,Dop:Field);

  //определяет выстрел компьютера по полю DOP на основе поля OSN
  procedure EnemyBooms(var Osn,Dop:Field);
  
  //возвращает количество мертвых клеточек поля G
  function DeadCells(G:Field):integer;
  
  //сбрасывает все данные о рекордах
  procedure ClearRecords;
  
  //подготовка к новому раунду - опускание флагов enemy и start, 
  //очищение и/или перестраивание полей, обнуление счетчика ходов
  procedure Sbros;
  
  //записывает текущие имя игрока (WinnerName) и число ходов (MovesNumber) в соответствующие им файлы
  procedure SaveResult;

  //возвращает 10-ый по счёту рекорд (без имени игрока) текущей таблицы рекордов
  function MinRecord:integer;
  
implementation  

  procedure Nulls;
  Begin
    for var i:= 0 to 11 do
      for var j:= 0 to 11 do
        G[i,j] := 0;
  end;

  //проверка свободности клеточек, окружающих данную (проверяет, заняты ли клетки вокруг)
  function Free (x,y: integer; var G: Field): boolean; 
  Begin
    if (x>0) and (x<11) and (y>0) and (y<11) and (G[x,y]=0)
    then if     (G[x+1,y]=0)   //клетка сверху пустая
            and (G[x-1,y]=0)   //клетка снизу пустая
            and (G[x,y+1]=0)   //клетка справа
            and (G[x,y-1]=0)   //клетка слева
            and (G[x+1,y+1]=0) //правый верхний угол
            and (G[x+1,y-1]=0) //левый верхний угол
            and (G[x-1,y+1]=0) //правый нижний угол
            and (G[x-1,y-1]=0) //левый нижний угол
         then Free:=true
         else Free:=false
    else Free:=false;
  end;

  //проверка, можно ли ставить начиная с точки (x;y) корабль длины s 
  //направления v (v=1 - горизонтальное - слева направо, v=0 - вертикальное - сверху вниз)
  //(проверяет, не будет ли такой корабль пересекаться с другими)
  function ShipFree (x,y,v,s:integer; var G: field): boolean;
  Begin
    ShipFree:=false;
    if (v=0) and (x<=11-s) and (x>0) and (y>0) and (y<=10) //проверка, не выходит ли вертикальный корабль за границы поля
    then for var i:=1 to s do begin //последовательная проверка каждой клеточки корабля
                       ShipFree:=Free(x+i-1,y,G); 
                       if not Free(x+i-1,y,G) then break;
                       end;                     
    if (v=1) and (y<=11-s) and (y>0) and (x>0) and (x<=10) //аналогично для горизонтального корабля
    then for var i:=1 to s do begin
                       ShipFree:=Free(x,y+i-1,G);
                       if not Free(x+i-1,y,G) then break;
                       end;   
  end;

  //начиная с точки (x;y) ставит корабль длины s направления v
  procedure Ship (x,y,v,s:integer; var G: field); 
  Begin
    if v=0 then for var i:=1 to s do G[x+i-1,y]:=1;
    if v=1 then for var i:=1 to s do G[x,y+i-1]:=1;
  end;

  procedure Ships;
  var x,y,v: integer;
  Begin
    Nulls(G);
    for var i:=4 downto 1 do        
    //i - длина корабля, сначала расставляем самые длинные во избежание невозможности ситуации уместить все корабли на поле
      for var j:=1 to 5-i do //количество кораблей заданной длины i (меняется в зависимости от i)
        begin
        repeat
          v:=random(0,1); //случайное направление
          if v=0 
          then begin
            x:=random(1,11-i); //случайная точка, но такая, чтобы корабль не выходил за границы поля
            y:=random(1,10);
          end
          else begin
            y:=random(1,11-i);
            x:=random(1,10);
          end; 
        until ShipFree(x,y,v,i,G); //варианты перебираются до тех пор пока нельзя поставить корабль
        Ship(x,y,v,i,G); //если корабль можно поставить - он ставится
        end;
    if not FieldRight(G) then Ships(G); //дополнительная проверка - если состав поля неправильный - расстановка делается еще раз
  end;
  
  //определяет, есть в точке (x;y) корабль длины s направления v
  function ShipStay(x,y,v,s:integer; var G: field):boolean; 
  begin
    ShipStay:=false;
    if v=0 then
    begin
      if (x<1) or (x+s>11) or (y>10) or (y<1) 
         or (G[x-1,y]=1) or (G[x-1,y+1]=1) or (G[x-1,y-1]=1)
         or (G[x+s,y]=1) or (G[x+s-1,y+1]=1) or (G[x+s,y-1]=1)
      then exit;
      for var j:=1 to s do
        if (G[x+j-1,y+1]=1) or (G[x+j-1,y-1]=1) or (G[x+j-1,y]=0) then exit;
    end;
    if v=1 then
    begin
      if (y+s>11) or (x>10) or (x<1) or (y<1)
         or (G[x,y-1]=1) or (G[x-1,y-1]=1) or (G[x+1,y-1]=1)
         or (G[x,y+s]=1) or (G[x-1,y+s]=1) or (G[x+1,y+s]=1) 
      then exit;
      for var i:=1 to s do
        if (G[x-1,y+i-1]=1) or (G[x+1,y+i-1]=1) or (G[x,y+i-1]=0) then exit;
    end;  
    //если до этого момента не произошел выход из подпрограммы, значит клетки вокруг корабля пустые и такой корабль есть
    ShipStay:=true;         
  end;
  
  function FieldRight:boolean;
  var Sh: array[1..4] of integer; //номер ячейки массива - длина корабля, значение - количество кораблей данной длины
      k:integer; //счетчик заполненных клеточек
  begin
    FieldRight:=false;
    for var l:=1 to 4 do SH[l]:=0;
    for var i:=1 to 10 do   
      for var j:=1 to 10 do   // для каждой клеточки поля перебираются 4 возможных длины корабля и 2 возможных направления
        for var l:=1 to 4 do  // и если один из вариантов подтверждается - в массив SH вносится еще один по счету по корабль заданной длины
          if ShipStay(i,j,0,l,G) or ShipStay(i,j,1,l,G) 
          then inc(Sh[l]);
    for var l:=1 to 4 do
      if Sh[l]<>5-l then exit;
    //считаем заполненные клеточки
    k:=0;
    for var i:=1 to 10 do
      for var j:=1 to 10 do
        if G[i,j]=1 then inc(k);
    //сверяем с посчитанным количеством кораблей  
    if k<>Sh[1]*1+Sh[2]*2+Sh[3]*3+Sh[4]*4 then exit;
    //если до этого момента не произошел выход - значит состав поля верный
    FieldRight:=true;;
  end;
  
  //определяет, есть ли полностью раненый (заполненный "-1") корабль длины s направления v в точке (x;y) 
  //OSN - основное (исходное) поле, DOP - дополнительное (поле для выстрелов)
  function DeadShip(x,y,s,v:integer; var Osn,Dop:field):boolean;
  begin
    DeadShip:=false;
    if not ShipStay(x,y,v,S,Osn) 
    then exit 
    else 
      case v of
      0: for var i:=x to x+S-1 do
        if Dop[i,y]<>-1 then exit;
      1: for var j:=y to y+S-1 do
        if Dop[x,j]<>-1 then exit;
      end;
    //если до этого момента не произошел выход - значит действительно есть такой полностью раненый корабль 
    DeadShip:=true;
  end;
  
  procedure Boom;
  Begin
    if (x<1) or (x>10) or (y<1) or (y>10) then exit; //защита от выхода за границы поля
    if (Dop[x,y]<>0) and (Dop[x,y]<>1) then exit; //если в точку уже стреляли - выстрела не будет
    if Osn[x,y]=1 
    then Dop[x,y]:=-1 //попадание
    else 
    begin
      if not Enemy then inc(MovesNumber); //конец хода игрока - число ходов увеличивается на 1
      Enemy:=not(Enemy); //ход сменяется на другого игрока
      Dop[x,y]:=-2 //промах
    end;
    
    for var l:=4 downto 1 do //перебор всех возможных длин корабля
    begin                    //для каждой точки столбика, где совершается выстрел
      for var i:=1 to 10 do  //соответсвенно, раположение корабля вертикальное
        if DeadShip(i,y,l,0,Osn,Dop) //если находится такой мёртвый (полностью раненый) корабль,
        then                         //его клетки заменяются с раненых на убитые, а область вокруг заполняется "мимо"
        begin
          Dop[i-1,y]:=-2;
          Dop[i-1,y+1]:=-2;
          Dop[i-1,y-1]:=-2;
          Dop[i+l,y]:=-2;
          Dop[i+l,y+1]:=-2;
          Dop[i+l,y-1]:=-2;
        for var n:=i to i+l-1 do
          begin
            Dop[n,y]:=2;//убит
            Dop[n,y-1]:=-2;DOP[n,y+1]:=-2;
          end;   
        end;  
      for var j:=1 to 10 do //то же, что и для столбика, только для строчки и с горизонтальным расположением корабля
        if DeadShip(x,j,l,1,Osn,Dop)
        then
        begin
         Dop[x,j-1]:=-2;
         Dop[x+1,j-1]:=-2;
         Dop[x-1,j-1]:=-2;
         Dop[x,j+l]:=-2;
         Dop[x+1,j+l]:=-2;
         Dop[x-1,j+l]:=-2;
        for var m:=j to j+l-1 do
          begin
          Dop[x,m]:=2;
          Dop[x-1,m]:=-2;Dop[x+1,m]:=-2;
          end;   
        end;   
    end;
 End; 
 //для рененой клеточки
 //случайным образом определяет, как компьютер будет "добивать" раненый корабль - т.е. какие клеточки вокруг обстреливать
 procedure BadBoom(x,y:integer;var Osn,Dop:field);
 var v:integer; 
 begin
   if (x<1) or (x>10) or (y<1) or (y>10) then exit;
   if (Dop[x+1,y]<>-1) and (Dop[x-1,y]<>-1) and (Dop[x,y+1]<>-1) and (Dop[x,y-1]<>-1) //если вокруг нет других раненых клеток
   then begin                                                    //то направление v дальнейшего обстела определяется случайно
     v:=random(4);
     case v of
          0:boom(x-1,y,Osn,Dop);
          1:boom(x+1,y,Osn,Dop);
          2:boom(x,y-1,Osn,Dop);
          3:boom(x,y+1,Osn,Dop);
     end
   end
   else   //обстрел соседних точек, если точка оказывается уже раненой
   begin  //то обстрел продолжается для неё, сохраняя направление обсрела (по горизонтали, либо по вертикали)
     v:=random(2);
     if Dop[x+1,y]=-1 then  
       case v of   
         0: if Dop[x+2,y]=-1 then BadBoom(x+2,y,Osn,Dop) else boom(x+2,y,Osn,Dop);
         1: if Dop[x-1,y]=-1 then BadBoom(x-1,y,Osn,Dop) else boom(x-1,y,Osn,Dop);
       end;
     if Dop[x-1,y]=-1 then
       case v of
         0: if Dop[x-2,y]=-1 then BadBoom(x-2,y,Osn,Dop) else boom(x-2,y,Osn,Dop);
         1: if Dop[x+1,y]=-1 then BadBoom(x+1,y,Osn,Dop) else boom(x+1,y,Osn,Dop);
       end;
     if Dop[x,y-1]=-1 then
       case v of
         0: if Dop[x,y-2]=-1 then BadBoom(x,y-2,Osn,Dop) else boom(x,y-2,Osn,Dop);
         1: if DOP[x,y+1]=-1 then BadBoom(x,y+1,Osn,Dop) else boom(x,y+1,Osn,Dop);
       end;
     if Dop[x,y+1]=-1 then
       case v of
         0: if Dop[x,y+2]=-1 then BadBoom(x,y+2,Osn,Dop) else boom(x,y+2,Osn,Dop);
         1: if Dop[x,y-1]=-1 then BadBoom(x,y-1,Osn,Dop) else boom(x,y-1,Osn,Dop);
       end;
   end;
 end;
 
//определяет, является ли выбранный столбец k поля G свободным для выстрела
//(имеются ли в нем клеточки, в которые ещё можно стрелять)
 function FreeRow(k:integer; G:field):boolean;
 begin
  FreeRow:=true;
  for var i:=1 to 10 do
    if (G[i,k]=0) or (G[i,k]=1) then 
       begin
        FreeRow:=false;
        exit;
       end;
 end;
 
 procedure EnemyBooms;
 var x,y:integer;
 begin
  for var i:=1 to 10 do    //последовательная проверка всех точек поля на наличие раненых кораблей
    for var j:=1 to 10 do  //если такая точка находится - запускается процедура "добивания" корабля
      if Dop[i,j]=-1 
      then begin
      BadBoom(i,j,Osn,Dop);
      exit;
      end;
  repeat    
    y:=random(1,10);
  until not FreeRow(y,Dop); //случайным образом выбирается свободный (доступный для выстрела) столбик
  repeat
     x:=random(1,10); 
  until (Dop[x,y]<>0) or (Dop[x,y]<>1); //случаныйм образом определяется доступная для выстрела точка столбика
  boom(x,y,Osn,Dop); //совершается выстрел в эту случайную точку
 end;
 
 function DeadCells(G:field):integer;
 var k:integer;
 begin
   k:=0;
   for var i:=1 to 10 do
     for var j:=1 to 10 do
       if G[i,j]=2 then inc(k);
   DeadCells:=k;
 end;
 
 procedure ClearRecords;
  var F:textfile;
  Begin
    assignfile(F,'Rec.text');
    rewrite(F);
    close(F);
    assignfile(F,'Names.text');
    rewrite(F);
    close(F);
  end;
  
  procedure Sbros;
  begin
    randomize;
    Ships(A); Ships(B); 
    Nulls(C); Nulls(D);
    Start:=false; Enemy:=false;
    MovesNumber:=0;
  end;
  
  procedure SaveResult;
  var F: textfile;
  begin
    assignfile(F,'Rec.text');
    append(F);
    writeln(F,MovesNumber+1);
    close(F);  
    assignfile(F,'Names.text');
    append(F);
    writeln(F,WinnerName);
    close(F);  
  end;

 function MinRecord:integer;
  var 
    S,err:integer; //вспомогательные переменные
    F: textfile;
    A: array[0..10] of integer; //массив рекордов
    n:string; //текущий считываемый рекорд
  Begin
    assignfile(F,'Rec.text');
    reset(F);
    for var i:=0 to 10 do A[i]:=101;
    repeat
      readln(F,n);  //построчно считываем рекорд n строкового типа 
      val(n,S,err); //переводим строковый тип в числовой
      //упорядоченное заполнение массива в порядке убывания рекордов
      for var i:=1 to 10 do
        if (S<A[i]) and (S<>0)
        then begin
          for var j:=10 downto i+1 do //сдвигаем элементы массива на 1 вправо
            A[j]:=A[j-1];
          A[i]:=S;
          break;
        end;
    until eof(F);  
    close(F);
    MinRecord:=A[10];
  end; 
  
End.