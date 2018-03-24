Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	Элементы = Новый ОбъектыКластера(Владелец);

КонецПроцедуры

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь)
	
	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	// TODO: Добавить просмотр лицензий
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("process");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Элементы.Заполнить(Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды()));

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает список рабочих процессов кластера 1С
//   
// Параметры:
//   ПоляУпорядочивания 	- Строка		- Список полей упорядочивания списка администратор, разделенные ","
//											  если не указаны, то имя администратора name
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список рабочих процессов кластера 1С
//
Функция ПолучитьСписок(Знач ПоляУпорядочивания = "", ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ ЗначениеЗаполнено(ПоляУпорядочивания) = 0 Тогда
		ПоляУпорядочивания = "pid";
	КонецЕсли;

	Возврат Элементы.ПолучитьСписок(ПоляУпорядочивания, ОбновитьПринудительно);

КонецФункции // ПолучитьСписок()

// Функция возвращает описание рабочего процесса кластера 1С
//   
// Параметры:
//   Отбор				 	- Структура	- Структура отбора менеджеров кластера (<поле>:<значение>)
//   ОбновитьПринудительно 	- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание рабочего процесса кластера 1С
//
Функция Получить(Отбор, ОбновитьПринудительно = Ложь) Экспорт

	Возврат Элементы.Получить(Отбор, ОбновитьПринудительно);

КонецФункции // Получить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
