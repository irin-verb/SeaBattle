unit WindowsModule;
interface
uses GraphABC;
uses ShipModule;
uses DrawModule;
uses ButtonsModule;

//ОКНО ГЛАВНОГО МЕНЮ
procedure MainWindow;

//ОКНО - ПРЕДУПРЕЖДЕНИЕ ДЛЯ ПОДТВЕРЖДЕНИЯ ДЕЙСТВИЙ
//w определяет тип предупреждения и действия, следующие за нажатием "да" или "нет"
procedure WarningWindow(w:integer);

//ОКНО РЕКОРДОВ
//k определяет запуск непосредственно из игры (k=0) или нет (k=1)
procedure RecordsWindow(k:integer);

//ОКНО ПРАВИЛ
//k определяет запуск непосредственно из игры (k=1) или нет (k=0)
procedure RulesWindow(k:integer);

//ОКНО ПОДГОТОВКИ К ИГРЕ
procedure PreparationWindow;

//ОКНО ХОДА ИГРЫ
procedure GameWindow;

//ОКНО ВВОДА ИМЕНИ ПОБЕДИТЕЛЯ
procedure GetMyNameWindow;


implementation 

procedure WarningWindow;
Begin
  Warning(W); //рисует окно с соответствующим текстом предупреждения
  OnMouseDown:=WarningButtons; //привязывает клик мышкой к группе кнопок этого окна
  repeat
    if YesB then   //все возможные варианты при нажатии "да"
    begin
      YesB:=false;
      case w of
        0,1,2,3,4,8,12: halt;
        5: Begin 
           ClearRecords; 
           RecordsWindow(1)
           end;
        6: Begin
           ClearRecords; 
           RecordsWindow(0);        
           end;
        7,9,10,11,16: MainWindow;
        13,15,17: begin
            Sbros;
            PreparationWindow;
            end;
        14: GetMyNameWindow;
      end;
    end;
    if NoB then   //все возможные варианты при нажатии "нет"
    begin
      NoB:=false;
      case w of
        0,13,15,17: MainWindow;
        1,6,9: RecordsWindow(0);
        2,5: RecordsWindow(1);
        3: RulesWindow(0);
        4,10: RulesWindow(1);  
        7,8: PreparationWindow;
        11,12: GameWindow;
        14: WarningWindow(15);
        16: GetMyNameWindow;
      end;
    end;
  until false;;
End;

procedure MainWindow;
Begin
  Sbros;  //новая игра, сброс старых результатов
  GlMenu; //рисуем страницу
  OnMouseDown:=GlMenuButtons; //привязка кнопок
  repeat
    if PlayB then //нажатие "Играть"
    begin
      PlayB:=false;
      PreparationWindow;
    end;
    if RecB then //"Рекорды"
    begin
      RecB:=false;
      RecordsWindow(1);
    end;
    if RulB then //"Правила"
    begin
      RulB:=false;
      RulesWindow(0);
    end;
    if ExitB then //"Выход"
    begin
      ExitB:=false;
      WarningWindow(0);      
    end;
  until false;
end;

procedure RecordsWindow(k:integer);
Begin
  Records(k); //рисуем страницу
  case k of //два варианта кнопок, с кнопкой "к игре" и без
    1: OnMouseDown:=RecordButtons;
    0: OnMouseDown:=RecordButtonsGame;
  end;
  repeat //аналогично прописаны действия для каждой кнопки
    if MenuB then //нажатие "Главное меню"
    begin
      MenuB:=false;
      if k=0 then WarningWindow(9) else MainWindow;
    end;
    if RulB then
    begin
      RulB:=false;
      case k of
        1: RulesWindow(0);
        0: RulesWindow(1);
      end;
    end;
    if ExitB then
    begin
      ExitB:=false;
      case k of
        1:WarningWindow(2);
        0:WarningWindow(1);
      end;
    end;
    if ClearRecB then //сброс рекордов
    begin
      ClearRecB:=false;
      if k=1 then WarningWindow(5);
      if k=0 then WarningWindow(6);
    end;
    if PlayB then
    begin
      PlayB:=false;
      if Start then GameWindow else PreparationWindow; //если игра (сражение) уже началось, кнопка "к игре" возвращает к сражению
    end;                                               //если нет - к странице расстановки кораблей
  until false; 
end;

procedure RulesWindow(k:integer);
Begin
  Pravila(k);  
  case k of    
    0:OnMouseDown:=RulesButtons;
    1:OnMouseDown:=RulesButtonsGame;
  end;
  repeat
    if RecB then 
    begin
      RecB:=false;
      case k of
        0:RecordsWindow(1);
        1:RecordsWindow(0);  
      end;
    end;
    if MenuB then
    begin
      MenuB:=false;
      if k=1 then WarningWindow(10) else MainWindow;
    end;
    if ExitB then
    begin
      ExitB:=false;
      case k of
        0:WarningWindow(3);
        1:WarningWindow(4);
      end;
    end;
    if PlayB then
    begin
      PlayB:=false;
      if Start then GameWindow else PreparationWindow;
    end;
  until false;
End;

procedure PreparationWindow;  
Begin
  Preparation; //рисуем страницу
  Frame(16,86,522,592,0); //вывод поля
  DrawField(20,90,48,2,A);
  //NumberFrame(A);
  OnMouseDown:=PreparationButtons; //привязка кнопок
  repeat
    if MenuB then
    begin
      MenuB:=false;
      WarningWindow(7);
    end;
    if RulB then
    begin
      RulB:=false;
      RulesWindow(1);
    end;
    if RecB then
    begin
      RecB:=false;
      RecordsWindow(0);
    end;
    if ExitB then
    begin
      ExitB:=false;
      WarningWindow(8);
    end;
    if RandomB then //случайное задание поля
    begin
      RandomB:=false;
      Ships(A);
      Frame(16,86,522,592,0);
      DrawField(20,90,48,2,A);
      NumberFrame(A);
    end;
    if ResetB then //сброс поля
    begin
      ResetB:=false;
      Nulls(A);
      Frame(16,86,522,592,0);
      DrawField(20,90,48,2,A);
      NumberFrame(A);
    end;
    for var i:=1 to 10 do //нажатие на клеточку поля
      for var j:=1 to 10 do
        if Cell[i,j] then
        begin
          Cell[i,j]:=false;
          if A[i,j]=0 then A[i,j]:=1 else A[i,j]:=0;
          Frame(16,86,522,592,0);
          DrawField(20,90,48,2,A);
          NumberFrame(A);
        end;
    if FieldRight(A) then //обновление сообщения о правильности поля
    begin
      BuiltWarning(0);
      Sleep(400);
    end
    else begin
      BuiltWarning(1);
      Sleep(400);
    end;   
    if (PlayB) and (FieldRight(A)) then  //"начать игру" (кнопка функционирует только если заполнение поля завершено)
    begin
      PlayB:=false;
      Start:=true;
      for var i:=1 to 10 do //изначально D выглядит как нетронутое поле игрока
        for var j:=1 to 10 do
          D[i,j]:=A[i,j]; 
      GameWindow;
    end;
  until false;
End;

procedure GameWindow;
Begin
  Fight(D,C); //рисуем страницу сражения с полями игроков (не исходные A и B, а именно поля для отображения выстрелов)
  OnMouseDown:=GameButtons;//привязываем кнопки
  repeat
    if MenuB then
    begin
      MenuB:=false;
      WarningWindow(11);
    end;
    if ExitB then
    begin
      ExitB:=false;
      WarningWindow(12);
    end;
    if RecB then
    begin
      RecB:=false;
      RecordsWindow(0);
    end;
    if RulB then
    begin
      RulB:=false;
      RulesWindow(1);
    end;
    
   if DeadCells(D)=20 then warningwindow(13); //окно поражения
   if DeadCells(C)=20  
   then if MovesNumber+1<MinRecord 
        then WarningWindow(14)  //окно победы с предложением сохранить рекорд
        else WarningWindow(17); //обычное окно победы
   
   //обновление сообщения о том, чей ход
   if Enemy 
   then begin
    MessageFrame('Ход противника');
    Sleep(150);
   end
   else begin
     MessageFrame('Ваш ход'+#10+'Нажмите на клеточку вражеского поля') ;
     Sleep(150);
   end;
   //ход противника
   if Enemy then
   begin
     EnemyBooms(A,D);
     Sleep(150);
     DrawFields(D,C);
   end;
   
   for var i:=1 to 10 do
     for var j:=1 to 10 do
       if (Cell[i,j]) and (not ENEMY) and (C[i,j]=0) then //нажатие на нетронутую клеточку поля игроком в свой ход
       begin
         Cell[i,j]:=false;
         Boom(i,j,B,C);  //выстрел игрока
         case C[i,j] of  //обновление сообщения информацией о характере попадания
           -1: MessageFrame('Попал!');
            2: MessageFrame('Убил!');
           -2: MessageFrame('Мимо!');
         end;
         DrawFields(D,C);
         Sleep(270);
       end;  
  until false;
end;

procedure GetMyNameWindow;
Begin
  Winner;
  OnMouseDown:=WinnerButtons;
  repeat
    if MenuB then
    begin
      MenuB:=false;
      WarningWindow(16);
    end;
    if ChangeNameB then //ввод имени
    begin
      ChangeNameB:=false;
      readln(WinnerName);
      trim(WinnerName);
      Button(50,420,950,520,20,WinnerName);
      sleep(500);
    end;
    if NameB then //сохранение имени и рекорда
    begin
      NameB:=false;
      if WinnerName<>'' then
      begin
        SaveResult;
        RecordsWindow(1);
      end;  
    end;
  until false ;
End;

End.