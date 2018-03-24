Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем ИБ_Владелец;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера	- АгентКластера			- ссылка на родительский объект агента кластера
//   Кластер		- Кластер				- ссылка на родительский объект кластера
//   ИБ				- ИнформационнаяБаза	- ссылка на родительский объект информационной базы
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ИБ = Неопределено)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	ИБ_Владелец = ИБ;

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт
	
	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	// TODO: Добавить просмотр лицензий

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("session");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Если НЕ ИБ_Владелец = Неопределено Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--infobase=%1", ИБ_Владелец.Ид()));
	КонецЕсли;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Элементы.Заполнить(Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды()));

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает список сеансов
//   
// Параметры:
//   Отбор					 	- Структура	- Структура отбора сеансов (<поле>:<значение>)
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Массив - список сеансов
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	Сеансы = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат Сеансы;

КонецФункции // Список()

// Функция возвращает список сеансов
//   
// Параметры:
//   ПоляИерархии			- Строка		- Поля для построения иерархии списка сеансов, разделенные ","
//   ОбновитьПринудительно	- Булево		- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список сеансов
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	Сеансы = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно);

	Возврат Сеансы;

КонецФункции // ИерархическийСписок()

// Функция возвращает описание сеанса кластера 1С
//   
// Параметры:
//   Сеанс				 	- Структура	- Номер сеанса в виде <имя информационной базы>:<номер сеанса>
//   ОбновитьПринудительно 	- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание сеанса 1С
//
Функция Получить(Знач Сеанс, Знач ОбновитьПринудительно = Ложь) Экспорт

	Сеанс = СтрРазделить(Сеанс, ":");

	Если Сеанс.Количество() = 1 Тогда
		Если ТипЗнч(Сеанс[0]) = Тип("Строка") Тогда
			Сеанс.Добавить(1);
		ИначеЕсли ТипЗнч(Сеанс[0]) = Тип("Число") Тогда
			Если ИБ_Владелец = Неопределено Тогда
				Возврат Неопределено;
			КонецЕсли;
			Сеанс.Вставить(0, ИБ_Владелец.Получить("name"));
		Иначе
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;

	ИБ = Кластер_Владелец.ИнформационныеБазы().Получить(Сеанс[0]);

	Отбор = Новый Структура("infobase, session-id", ИБ.Получить("infobase"), Сеанс[1]);

	Сеансы = Элементы.Список(Отбор, ОбновитьПринудительно);

	Возврат Сеансы[0];

КонецФункции // Получить()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПолучитьСтруктуруПараметровОбъекта(ИмяПоляКлюча = "ИмяПараметра") Экспорт
	
	СтруктураПараметров = Новый Соответствие();

	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"Ид"							, "session", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"НомерСеанса"					, "session-id", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ИнформационнаяБаза_Ид"			, "infobase", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"Соединение_Ид"					, "connection", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"Процесс_Ид"					, "process", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"Пользователь"					, "user-name", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"Компьютер"						, "host", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"Приложение"					, "app-id", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"Язык"							, "locale", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ВремяНачала"					, "started-at", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ПоследняяАктивность"			, "last-active-at", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"Спящий"						, "hibernate", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ЗаснутьЧерез"					, "passive-session-hibernate-time", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ЗавершитьЧерез"				, "hibernate-session-terminate-time", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ЗаблокированоСУБД"				, "blocked-by-dbms", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ЗаблокированоУпр"				, "blocked-by-ls", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ДанныхВсего"					, "bytes-all", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"Данных5мин"					, "bytes-last-5min", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"КоличествоВызововВсего"		, "calls-all", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"КоличествоВызовов5мин"			, "calls-last-5min", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ДанныхСУБДВсего"				, "dbms-bytes-all", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ДанныхСУБД5мин"				, "dbms-bytes-last-5min", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"СоединениеССУБД"				, "db-proc-info", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ЗахваченоСУБД"					, "db-proc-took", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ВремяЗахватаСУБД"				, "db-proc-took-at", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ВремяВызововВсего"				, "duration-all", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ВремяВызововСУБДВсего"			, "duration-all-dbms", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ВремяВызововТекущее"			, "duration-current", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ВремяВызововСУБДТекущее"		, "duration-current-dbms", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ВремяВызовов5мин"				, "duration-last-5min", , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
	 		"ВремяВызововСУБД5мин"			, "duration-last-5min-dbms", , "-");
		 
	Возврат СтруктураПараметров;

КонецФункции // ПолучитьСтруктуруПараметровОбъекта()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
