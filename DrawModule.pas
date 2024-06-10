unit DrawModule;
interface 
  uses ShipModule;
  uses GraphABC;
  const
    wW=1000; //ширина окна игры
    wH=800;  //высота окна игры
  
  //ПОДГОТОВКА ОКНА ИГРЫ
  procedure Beginning;
  
  //ПРОЦЕДУРА, РИСУЮЩАЯ ПРЯМОУГОЛЬНИК С РАМКОЙ ДЛЯ ЗАДАННЫХ КООРДИНАТ
  //a,b,c,d - границы рамочки
  //W=0 - простая рамка в одну линию, W=1 - двойная рамка
  procedure Frame(a,b,c,d,W:integer);

  //ПРОЦЕДУРА, РИСУЮЩАЯ КНОПКУ
  //a,b,c,d - границы кнопки, Z - размер шрифта, S - текст на кнопке 
  procedure Button(a,b,c,d,Z:integer;S:string); 

  //РИСУЕТ ГЛАВНОЕ МЕНЮ 
  procedure GlMenu;
  
  //РИСУЕТ СТРАНИЦУ РЕКОРДОВ
  //W=1 - страница рекордов запущенная из главного меню, W=0 - страница запущенная из самой игры
  procedure Records(W:integer);

  //РИСУЕТ СТРАНИЦУ ПРАВИЛ
  //W=0 - страница правил из главного меню, W=1 - страница из самой игры
  procedure Pravila(W: integer);

  //ПРОЦЕДУРА, РУСУЮЩАЯ ВСЁ ПОЛЕ
  //x,y - начальные координаты, s - сторона квадрата, 
  //r - отступ между клеточками, D - рисуемое поле
  procedure DrawField(x,y,s,r:integer; var D:Field);
  
  //РИСУЕТ СТРАНИЦУ ПОДГОТОВКИ К ИГРОВОМУ ПРОЦЕССУ (РАССТАНОВКА КОРАБЛЕЙ)
  procedure Preparation;
  
  //ПРОЦЕДУРА, РИСУЮЩАЯ ДВА ПОЛЯ
  procedure DrawFields(A,B:Field);

  //РИСУЕТ РАМОЧКУ С СООБЩЕНИЕМ (ДЛЯ СООБЩЕНИЙ, ЧЕЙ СЕЙЧАС ХОД И ПОПАЛ ЛИ ИГРОК)
  procedure MessageFrame(S:string);
  
  //РИСУЕТ СТРАНИЦУ ИГРОВОГО ПРОЦЕССА (ХОД СРАЖЕНИЯ)
  procedure Fight(B,A:Field);
  
  //РИСУЕТ СТРАНИЦУ ПРЕДУПРЕЖДЕНИЯ (ПОДТВЕРЖДЕНИЕ ДЕЙСТВИЯ)
  //K определяет один из вариантов текста предупреждения
  procedure Warning(K:integer);
  
  //РИСУЕТ РАМОЧКУ С СООБЩЕНИЕМ (ДЛЯ СООБЩЕНИЙ О ТЕКУЩЕМ СОСТОЯНИИ ВЫСТРАИВАЕМОГО ПОЛЯ)
  procedure BuiltWarning(k:integer);
  
  //РИСУЕТ ТАБЛИЦУ ТЕКУЩЕГО СОСТАВА КОРАБЛЕЙ С ПРЕДУПРЕЖДЕНИЕМ О ПЕРЕСЕЧЕНИЯХ
  procedure NumberFrame(G: Field);
  
  //РИСУЕТ СТРАНИЦУ ВВОДА ИМЕНИ ПОБЕДИТЕЛЯ
  procedure Winner;
  
  
implementation  

  //ПРОЦЕДУРА, РИСУЮЩАЯ ФОН ИГРЫ С ЗАГОЛОВКОМ
  //X,Y - точка, с которой начинается вывод заголовка, S - текст заголовка, Z - размер шрифта
  procedure BackgroundWithTitle(X,Y,Z:integer;S:string);
  Begin
    SetBrushColor(clMoneyGreen);   
    FillRect(0,0,wW,wH);
    SetPenColor(clTeal);  
    SetPenWidth(5); 
    SetPenStyle(psDashDot);
    Rectangle(0,0,wW, wH);
    SetFontSize(Z);
    SetFontColor(clTeal);
    SetFontStyle(fsBoldItalic);
    TextOut(X,Y,S);
  end;

  procedure Beginning;
  Begin
    ClearWindow;
    SetWindowSize(wW, wH); 
    CenterWindow;
    SetWindowCaption('МОРСКОЙ БОЙ - ВЕРБИЦКАЯ ИРИНА - 143 ГРУППА');
    BackgroundWithTitle(200,280,60,'МОРСКОЙ БОЙ');
    SetFontStyle(fsItalic);
    SetFontSize(20);
    TextOut(40,640,'Курсовая работа'+#10+'РГРТУ им.В.Ф.Уткина'+#10+'143 группа'#10+'Вербицкая Ирина');
    Sleep(3500);
  end; 

  procedure Frame;
  Begin
    SetBrushColor(clSilver); 
    FillRect(a,b,c,d);   
    SetPenColor(clTeal);  
    SetPenWidth(2);      
    SetPenStyle(psSolid);
    Rectangle(a,b,c,d);
    if W=1 then
    begin
      SetPenColor(clMoneyGreen);
      SetPenWidth(6);
      Rectangle(a+14,b+14,c-14,d-14); 
    end;
  end;

  procedure Button; 
  Begin
    Frame(a,b,c,d,0);
    SetFontSize(Z);
    SetFontStyle(fsNormal);
    SetFontColor(clTeal);
    DrawTextCentered(a,b,c,d,S);
  end;

  procedure GlMenu;
  const 
    k=370; //отступ кнопок от правого и левого края экрана
    h=60;  //высота кнопки
    r=10;  //расстояние между кнопками
    d=300; //высота, откуда начинается вывод кнопок
    S: array[1..4] of string = ('Играть','Рекорды','Правила','Выход'); //названия кнопок
  Begin
    BackgroundWithTitle(245,130,60,'Морской бой');
    for var i:=1 to 4 do
      Button(k,d+(h+r)*(i-1),wW-k,d+h+(h+r)*(i-1),35,S[i]);
  end;  

  //ПРОЦЕДУРА ВЫВОДА НА ЭКРАН 10 НАИЛУЧШИХ РЕКОРДОВ ИЗ ФАЙЛОВ
  //X,Y - точка, откуда начинается вывод рекордов
  procedure RecordOutput(X,Y:integer);
  var 
    S,err:integer; //S - текущий считываемый рекорд
    F,G: textfile;
    A: array[0..10] of integer; //массив рекордов (значения)
    B:array[0..10] of string;   //массив рекордов (имена)
    n,m:string; //вспомогательные строки
  Begin
    assignfile(F,'Rec.text'); 
    assignfile(G,'Names.text');
    reset(F); reset(G);
    for var i:=0 to 10 do A[i]:=101;
    repeat
      readln(F,n);  //построчно считываем рекорд n строкового типа 
      readln(G,m);
      val(n,S,err); //переводим строковый тип в числовой
      //упорядоченное заполнение массива в порядке убывания ркордов
      for var i:=1 to 10 do
        if (S<A[i]) and (S<>0)
        then begin
          for var j:=10 downto i+1 do
            begin //сдвигаем оба массива на 1 элемент вправо
            A[j]:=A[j-1];
            B[j]:=B[j-1];
            end;
          A[i]:=S;
          B[i]:=m;
          break;
        end;
    until (eof(F)) or (eof(G));  
    close(F);
    close(G);
    //вывод массива
    SetFontSize(16);
    SetFontStyle(fsNormal); 
    SetFontColor(clTeal);
    for var i:=1 to 10 do
    begin
      Str(i,n);
      Str(A[i],m);
      n:='№'+n+' - '+B[i]+' - ';
      if A[i]<>101 then n:=n+m;
      TextOut(X,Y+50*(i-1),n); 
    end;
  end; 

  procedure Records;
  const
    a=660; //отступ от левого края экрана
    b=50;  //от правого
    h=45;  //высота кнопок
    r=10;  //расстояние между кнопками
    d=200; //высота, откуда начинается вывод кнопок
    S:array[1..5] of string = ('К игре','Главное меню','Правила','Выход','Сброс рекордов'); //названия кнопок
  Begin
    BackgroundWithTitle(320,30,60,'Рекорды');
    SetFontSize(26);
    SetFontStyle(fsItalic);
    TextOut(120,125,'Топ 10 побед в наименьшее количество ходов');
    for var i:=1+W to 4 do
      Button(a,d+(h+r)*(i-1-W),wW-b,d+(h+r)*(i-1-W)+h,26,S[i]);
    Button(a,705,wW-b,705+h,26,S[5]);
    Frame(50,200,610,wH-50,1);
    RecordOutput(80,236);
  End;

  //ПРОЦЕДУРА ВЫВОДА ПРАВИЛ ИЗ ФАЙЛА НА ЭКРАН
  //X,Y - точка, откуда начинается вывод рекордов, Z - размер текста
  procedure PravilaOutput(X,Y,Z:integer);
  const n=100; //максимальное количество строк в массиве
  var
    F: textfile;
    S: array[1..n] of string; //массив выводимых строк
    k:integer;   //считанное из файла количество строк
  Begin
    assignfile(F,'Rul.text');
    reset(F);
    k:=1;
    //читаем строки в массив
    repeat
      readln(F,S[k]);
      inc(k); 
    until eof(F);  
    close(F);
    //выводим получившееся количество строк
    SetFontSize(Z);
    for var i:=1 to k do
    begin
      if (S[i]='Подготовка к игре') or (S[i]='Ход игры') or (S[i]='Победа в игре')
      then SetFontStyle(fsBold);
      TextOut(X,Y+(i-1)*30,S[i]);
      SetFontStyle(fsNormal);
    end;  
  end;

  procedure Pravila;
  const
    a=30;  //отступ от края экрана
    h=50;  //высота кнопки
    t=300; //ширина кнопки
    r=20;  // расстояние между кнопками
    d=200; //высота, где начинаются кнопки
    S:array[1..4] of string = ('Рекорды','Главное меню','Выход','К игре');
  Begin
    if W=0 
    then BackgroundWithTitle(320,30,60,'Правила')
    else begin
     BackgroundWithTitle(180,30,60,'Правила');
      Button(wW-a-t,65,wW-a,65+h,22,S[4]);
    end;
    for var i:=1 to 3 do
      Button(a+(i-1)*(t+r),wH-a-h,a+t+(i-1)*(t+r),wH-a,22,S[i]);
    Frame(a,140,wW-a,wH-3*a,0); 
    PravilaOutput(a+10,150,15);
  End;
 
  //РИСУЕТ ОДНУ КЛЕТОЧКУ
  //Через значение W (состояние клеточки) определяется её цвет
  //S - сторона клетки, x,y - начальные координаты
  procedure OneCell(x,y,s,W:integer);
  Begin
    case W of
    -2:SetBrushColor(clMoneyGreen); //мимо
    -1:SetBrushColor(clBrown);  //ранен
      0:SetBrushColor(clSilver);//нетронутое поле
      1:SetBrushColor(clTeal);  //корабль
      2:SetBrushColor(clGray);  //убит
      3:SetBrushColor(clRed); 
    end;
    FillRect(x,y,x+s,y+s); 
    SetPenColor(clTeal);   
    SetPenWidth(2);        
    SetPenStyle(psSolid);  
    Rectangle(x,y,x+s,y+s);
  end;  

  procedure DrawField;
  Begin
    for var i:=1 to 10 do
      for var j:=1 to 10 do
        OneCell(x+(s+r)*(i-1),y+(s+r)*(j-1),s,D[i,j]);
  end;

  //ПРОЦЕДУРА, ВЫВОДЯЩАЯ ПОДСКАЗКУ ИЗ ФАЙЛА НА ЭКРАН
  //X,Y - точка, откуда начинается вывод подсказки, Z - размер текста
  procedure PodskazkaOutput(X,Y,Z:integer);
  const n=100; //максимальное количество строк в массиве
  var
    F: textfile;
    S: array[1..n] of string; //массив выводимых строк
    k:integer;   //считанное из файла количество строк
  Begin
    assignfile(F,'Podsk.text');
    reset(F);
    k:=1;
    //читаем строки в массив
    repeat
      readln(F,S[k]);
      inc(k); 
    until eof(F);  
    close(F);
    //выводим получившееся количество строк
    SetFontSize(Z);
    SetFontStyle(fsNormal);
    for var i:=1 to k do
      TextOut(X,Y+(i-1)*30,S[i]);
  end;  

  procedure Preparation;
  var X: field; //начальное пустое поле
  m: string; //вспомогательная строка
  const 
    S:array[1..4] of string = ('Главное меню','Рекорды','Правила','Выход');
    L:array[1..2] of string = ('Случайно','Сброс');
    a=48; //сторона квадрата
    ar=2; //расстояние между квадратами
    r=20; //отступ
    w=210;//ширина кнопки
    h=40; //высота кнопки
  Begin
    BackgroundWithTitle(60,24,28,'Расстановка кораблей');
    PodskazkaOutput(540,20,12);
    Frame(16,86,522,592,0);
    Nulls(X);
    DrawField(r,90,a,ar,X);
    Frame(r-3,620,524,wH-r,1);
    for var j:=1 to 2 do begin
      Button(50,650+(h+r)*(j-1), 50+w, 650+h+(h+r)*(j-1), 20, S[2*j-1]);
      Button(50+w+r, 650+(h+r)*(j-1), 50+2*w+r, 650+h+(h+r)*(j-1), 20, S[2*j]);
    end;
    for var i:=1 to 2 do
      Button(550,650+(h+r)*(i-1),550+w,650+h+(h+r)*(i-1),20,L[i]);
    Button(550+w+r,620,wW-r,wH-r,30,'Начать игру');
    SetFontStyle(fsBold);
    SetBrushColor(clMoneyGreen);   
    SetFontSize(12);
    TextOut(760,340,'Таблица числа кораблей,'+#10+'   стоящих по правилам'+#10+'       <-------------------------');
    TextOut(540,330,'Количество палуб'+#10+#10+#10+#10+'Количество кораблей');
    for var i:=1 to 4 do
    begin
      str(i,m);
      OneCell(540+(i-1)*(a+ar),425,a,-2);
      DrawTextCentered(540+(i-1)*(a+ar),425,540+(i-1)*(a+ar)+a,425+a,m);
      str(5-i,m);
      OneCell(540+(i-1)*(a+ar),350,a,-2);
      DrawTextCentered(540+(i-1)*(a+ar),350,540+(i-1)*(a+ar)+a,350+a,m);
    end;
    SetBrushColor(clMoneyGreen); 
    FillRect(760,410,970,480);   
    SetPenColor(clTeal);  
    SetPenWidth(2);      
    SetPenStyle(psSolid);
    Rectangle(760,410,970,480);
  end;
  
  procedure NumberFrame;
  const a=48;ar=2;
  var Sh: array[1..4] of integer; //номер ячейки массива - длина корабля, значение - количество кораблей данной длины
  m:string; //вспомогательная строка
  k:integer; //режим покраса клеточки и количество закрашенных клеточек поля
  Begin
    for var l:=1 to 4 do SH[l]:=0;
    for var i:=1 to 10 do   
      for var j:=1 to 10 do   // для каждой клеточки поля перебираются 4 возможных длины корабля и 2 возможных направления
        for var l:=1 to 4 do  // и если один из вариантов подтверждается - в массив SH вносится еще один по счету по корабль заданной длины
          if ShipStay(i,j,0,l,G) or ShipStay(i,j,1,l,G) 
          then inc(Sh[l]);
    //рисуем клеточки
    for var i:=1 to 4 do
    begin
      str(Sh[5-i],m);
      if Sh[5-i]=i
      then k:=-2
      else if Sh[5-i]<i
           then k:=0
           else k:=3;
      OneCell(540+(i-1)*(a+ar),425,a,k);
      SetFontColor(clTeal);
      DrawTextCentered(540+(i-1)*(a+ar),425,540+(i-1)*(a+ar)+a,425+a,m);
    end;
    //рисуем рамочку
    SetBrushColor(clMoneyGreen); 
    FillRect(760,410,970,480);   
    SetPenColor(clTeal);  
    SetPenWidth(2);      
    SetPenStyle(psSolid);
    Rectangle(760,410,970,480);
    //считаем заполненные клетки
    k:=0;
    for var i:=1 to 10 do
      for var j:=1 to 10 do
        if G[i,j]=1 then inc(k);
    //сверяем с посчитанным количеством кораблей  
    if k<>Sh[1]*1+Sh[2]*2+Sh[3]*3+Sh[4]*4 //при несовпадении - предупреждение в рамочке
    then begin
      SetFontColor(clBrown);
      SetFontSize(11);
      SetFontStyle(fsBold);
      DrawTextCentered(760,410,970,480,'На поле есть корабли, пересекающиеся с другими');
    end;
  end;
  
  
  procedure DrawFields;
  Begin 
    DrawField(33,130,43,2,B);
    DrawField(525,130,43,2,A);
  end;  

  procedure MessageFrame;
  Begin
    SetBrushColor(clSilver); 
    FillRect(33,600,480,wH-40);   
    SetPenColor(clTeal);  
    SetPenWidth(3); 
    SetPenStyle(psDashDot);
    Rectangle(33,600,480,wH-40);
    //SetFontSize(15);
    //SetFontStyle(fsNormal);
    SetFontColor(clTeal);
    if S='Ход противника' then SetFontColor(clBrown);
    DrawTextCentered(33,600,480,wH-49,S);
  end;

  procedure Fight;
  const 
    S:array[1..4] of string = ('Главное меню','Правила','Рекорды','Выход');
    h=40; w=214; r=20; //высота, ширина кнопок и расстояние между ними
    x=525; y=625; //точка, откуда начинается вывод кнопок
  Begin
    BackgroundWithTitle(375,25,40,'Ход игры');
    SetFontSize(18);
    SetFontStyle(fsNormal);
    TextOut(685,95,'Ваше поле');
    TextOut(160,95,'Поле противника');
    DrawFields(B,A);
    for var j:=1 to 2 do begin
      Button(x,y+(h+r)*(j-1), x+w, y+h+(h+r)*(j-1), 20, S[2*j-1]);
      Button(x+w+r, y+(h+r)*(j-1), x+2*w+r, y+h+(h+r)*(j-1), 20, S[2*j]);
    end;
    SetFontSize(15);
    SetPenColor(clTeal);  
    SetPenWidth(3); 
    SetPenStyle(psDashDot);
    Rectangle(33,600,480,wH-40);
  end; 

  procedure Warning;
  const a=200; //отступ границ окна от границ основного по горизонтали
        b=250; //по вертикали
        h=40; w=100; //высота и ширина кнопок
        r=40; d=65;  //отступы
  var S,m:string;//текст предупреждения и количество ходов игрока (переведенное в формат string)
  Begin
    case K of
      0,2,3: S:='Вы действительно хотите покинуть игру?';
      1,4,8,12: S:='Вы действительно хотите покинуть игру?'+#10+'Прогресс игры будет утерян.';
      5,6: S:='Вы действительно хотите сбросить текущие рекорды?'+#10+'Отменить это действие будет невозможно.';
      7,9,10,11: S:='Вы действительно хотите выйти в главное меню?'+#10+'Прогресс игры будет утерян.';
      13: S:='К сожалению, вы проиграли. Хотите сыграть ещё раз?';
      14: begin
          str(MovesNumber+1,m);
          S:='Поздравляем, Вы победили!'+#10+'Количество ходов: '+ m +#10+'Ваш результат входит в топ 10 рекордов.'+#10+'Хотите внести его в таблицу рекордов?';
          end;
      15: S:='Хотите сыграть ещё раз?';
      16: S:='Вы действительно хотите выйти в главное меню?'+#10+'Ваш результат не будет сохранен.';
      17: begin
          str(MovesNumber+1,m);
          S:='Поздравляем, Вы победили!'+#10+'Количество ходов: '+ m +#10 +'Хотите сыграть ещё раз?';
          end;
    end;
    SetBrushColor(clTeal);
    FillRect(a,b,wW-a,wH-b);   
    SetPenColor(clRed);  
    SetPenWidth(5);      
    SetPenStyle(psSolid);
    Rectangle(a,b,wW-a,wH-b);
    Frame(a+r,b+d,wW-a-r,wH-b-d,1);
    SetFontSize(16);
    SetFontStyle(fsBold);
    SetFontColor(clTeal);
    DrawTextCentered(a+r,b+d,wW-a-r,wH-b-d,S);
    Button(a+r,wH-b-d+10,a+r+w,wH-b-d+10+h,14,'Нет');
    Button(wW-a-r-w,wH-b-d+10,wW-a-r,wH-b-d+10+h,14,'Да');
  end;

procedure BuiltWarning(k:integer);
var S:string; //выводимый текст
Begin
  Frame(540,500,980,600,1);
  case k of
    0: Begin
      SetFontStyle(fsBold);
      SetFontColor(clGreen);
      S:='Поле соотвествует правилам, можно начинать игру!';
    end;
    1: begin
      SetFontColor(clBrown);
      S:='На данный момент поле не соотвествует правилам'
    end;
  end;
  SetFontSize(14);
  DrawTextCentered(540,500,980,600,S);
End;
//
procedure Winner;
const w=310;h=100;r=50; //ширина кнопки, высота, отступ
Begin
   BackgroundWithTitle(r,60,35,'Сохранение рекорда');
   SetFontSize(16);
   SetFontStyle(fsNormal);
   TextOut(r,190,'Обратите внимание, что рекорды, не входящие в десятку лучших в таблице');
   TextOut(r,240,'рекордов отображаться не будут. Вы можете попробовать сыграть ещё раз');
   TextOut(r,290,'или очистить таблицу рекордорв, чтобы попасть туда в дальнейшем.');
   SetFontSize(25);
   TextOut(r,360,'Ваше имя:');
   Button(wW-r-w,r,wW-r,r+h,20,'Главное меню');
   Button(r,420,wW-r,420+h,1,'');
   Button(wW-r-w,wH-r-h,wW-r,wH-r,20,'Сохранить результат');
End;

End.