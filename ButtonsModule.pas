unit ButtonsModule;
interface 
var 
  RecB, RulB,   // кнопки "рекорды" и "правила"
  ExitB, MenuB, // "выход" и "главное меню"
  YesB, NoB,    // "да" и "нет"
  PlayB,        // "играть"/"начать игру"/"к игре"
  ClearRecB,    // "сброс рекордов"
  ResetB, RandomB, // "случайно" и "сброс" (для этапа подготовки поля)
  ChangeNameB, NameB:boolean; //строка ввода имени и "сохранить результат"
  Cell:array[0..10,0..10] of boolean; //матрица кнопок, соответствующих ячейкам игрового поля

procedure GlMenuButtons(x,y,dop:integer);      //определяет действующие кнопки главного меню
procedure WarningButtons(x,y,dop:integer);     //окна предупреждения
procedure RecordButtons(x,y,dop:integer);      //страницы рекордов (запущенной не из начатой игры)
procedure RecordButtonsGame(x,y,dop:integer); //страницы рекордов (запущенной из начатой игры)
procedure RulesButtons(x,y,dop:integer);       //страницы правил (запущенной не из начатой игры)
procedure RulesButtonsGame(x,y,dop:integer);  //страницы правил (запущенной из начатой игры)
procedure PreparationButtons(x,y,dop:integer); //страницы подготовки к игре (расстановка кораблей по полю)
procedure GameButtons(x,y,dop:integer);        //страницы хода игры (сражение с компьютером)
procedure WinnerButtons(x,y,dop:integer);      //страницы ввода имени игрока
  
implementation 

procedure GlMenuButtons;
begin
  PlayB:=false; RecB:=false;
  RulB:=false; ExitB:=false;
  if (x>=370) and (x<=630) then
  begin
    if (y>=300) and (y<=360) then PlayB:=true;
    if (y>=370) and (y<=430) then RecB:=true;
    if (y>=440) and (y<=500) then RulB:=true;
    if (y>=510) and (y<=570) then ExitB:=true;
  end;
end;

procedure WarningButtons(x,y,dop:integer);
Begin
  NoB:=false; YesB:=false;
  if (y>=495) and (y<=535) then
  begin
    if (x>=240) and (x<=340) then NoB:=true;
    if (x>=660) and (x<=760) then YesB:=true;
  end;
end;

procedure RecordButtons(x,y,dop:integer);
Begin
  MenuB:=false; RulB:=false;
  ExitB:=false; ClearRecB:=false;
  if (x>=660) and (x<=950) then
  begin
    if (y>=200) and (y<=245) then MenuB:=true;
    if (y>=255) and (y<=300) then RulB:=true;
    if (y>=310) and (y<=355) then ExitB:=true;
    if (y>=705) and (y<=750) then ClearRecB:=true;
  end;
end;

procedure RecordButtonsGame(x,y,dop:integer);
Begin
  PlayB:=false; MenuB:=false;
  ExitB:=false; ClearRecB:=false;
  if (x>=660) and (x<=950) then
  begin
    if (y>=200) and (y<=245) then PlayB:=true;
    if (y>=255) and (y<=300) then MenuB:=true;
    if (y>=310) and (y<=355) then RulB:=true;
    if (y>=365) and (y<=410) then ExitB:=true;
    if (y>=705) and (y<=750) then ClearRecB:=true;
  end;
end;

procedure RulesButtons(x,y,dop:integer);
Begin
  RecB:=false; MenuB:=false; ExitB:=false;
  if (y>=720) and (y<=770) then begin
    if (x>=30) and (x<=330) then RecB:=true;
    if (x>=350) and (x<=650) then MenuB:=true;
    if (x>=670) and (x<=970) then ExitB:=true;
  end;
end;

procedure RulesButtonsGame(x,y,dop:integer);
Begin
  RecB:=false; MenuB:=false;
  ExitB:=false; PlayB:=false;
  if (y>=720) and (y<=770) then begin
    if (x>=30) and (x<=330) then RecB:=true;
    if (x>=350) and (x<=650) then MenuB:=true;
    if (x>=670) and (x<=970) then ExitB:=true;
  end;
  if (x>=670) and (x<=970) and (y>=65) and (y<=115)
  then PlayB:=true;
end;

procedure PreparationButtons;
Begin
  MenuB:=false; RulB:=False;
  RecB:=false; ExitB:=false;
  RandomB:=false; Resetb:=false; 
  PlayB:=false;
  for var i:=1 to 10 do
    for var j:=1 to 10 do
      Cell[i,j]:=false;
  if (x>=50) and (x<=260) then
  begin
    if (y>=650) and (y<=690) then MenuB:=true;
    if (y>=710) and (y<=750) then RulB:=true;
  end;
  if (x>=280) and (x<=490) then
  begin
    if (y>=650) and (y<=690) then RecB:=true;
    if (y>=710) and (y<=750) then ExitB:=true;
  end;
  if (x>=550) and (x<=760) then
  begin
    if (y>=650) and (y<=690) then RandomB:=true;
    if (y>=710) and (y<=750) then ResetB:=true;
  end;
  if (x>=780) and (x<=980) and (y>=620) and (y<=780) then PlayB:=true;
  for var i:=1 to 10 do
    for var j:=1 to 10 do
      if (x>=20+50*(i-1)) and (x<=20+50*(i-1)+48) and (y>=90+50*(j-1)) and (y<=90+50*(j-1)+48) 
      then Cell[i,j]:=true;
End;

procedure GameButtons;
Begin
  MenuB:=false; RulB:=False;
  RecB:=false; ExitB:=false;
  for var i:=1 to 10 do
    for var j:=1 to 10 do
      Cell[i,j]:=false;
  if (x>=525) and (x<=739) then
  begin
    if (y>=625) and (y<=665) then MenuB:=true;
    if (y>=685) and (y<=725) then RecB:=true;
  end;
  if (x>=759) and (x<=973) then
  begin
    if (y>=625) and (y<=665) then RulB:=true;
    if (y>=685) and (y<=725) then ExitB:=true;
  end;
  for var i:=1 to 10 do
    for var j:=1 to 10 do
      if (x>=33+45*(i-1)) and (x<=33+45*(i-1)+43) and (y>=130+45*(j-1)) and (y<=130+45*(j-1)+43) 
      then Cell[i,j]:=true;
End;

procedure WinnerButtons;
Begin
  MenuB:=False; 
  NameB:=false; 
  ChangeNameB:=false;
  if (x>=640) and (x<=950) then
  begin
    if (y>=50) and (y<=150) then MenuB:=true;
    if (y>=650) and (y<=750) then NameB:=true;
  end;
  if (x>=50) and (x<=950) and (y>=420) and (y<=520) then ChangeNameB:=true;
End;

End.