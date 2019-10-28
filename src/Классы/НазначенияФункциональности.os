// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Сервер_Владелец;
Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера  - ссылка на родительский объект агента кластера
//   Кластер            - Кластер        - ссылка на родительский объект кластера
//   Сервер             - Сервер         - ссылка на родительский объект сервера кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Сервер)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	Сервер_Владелец = Сервер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.НазначенияФункциональности);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список требований назначения функциональности от утилиты администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСервера", Сервер_Владелец.Ид());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения требований назначения функциональности, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивНазначений = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивНазначений.Добавить(Новый НазначениеФункциональности(Кластер_Агент,
		                                                           Кластер_Владелец,
		                                                           Сервер_Владелец,
		                                                           ТекОписание));
	КонецЦикла;
	
	Элементы.Заполнить(МассивНазначений);

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//    Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "Имя") Экспорт

	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает список требований назначения функциональности сервера 1С
//   
// Параметры:
//   Отбор                    - Структура    - Структура отбора требований
//                                             назначения функциональности (<поле>:<значение>)
//   ОбновитьПринудительно    - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список требований назначения функциональности сервера 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	СписокНазначений = Элементы.Список(Отбор, ОбновитьПринудительно, ЭлементыКакСоответствия);
	
	Возврат СписокНазначений;

КонецФункции // Список()

// Функция возвращает список требований назначения функциональности сервера 1С
//   
// Параметры:
//   ПоляИерархии             - Строка       - Поля для построения иерархии списка требований
//                                             назначения функциональности, разделенные ","
//   ОбновитьПринудительно    - Булево       - Истина - обновить список (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список требований назначения функциональности сервера 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список требований назначения функциональности
//                                                                      или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	СписокКластеров = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно, ЭлементыКакСоответствия);
	
	Возврат СписокКластеров;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество требований назначения функциональности в списке
//   
// Возвращаемое значение:
//    Число - количество требований назначения функциональности
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание требования назначения функциональности сервера 1С
//   
// Параметры:
//   Ид                      - Строка    - Идентификатор требований назначения функциональности
//   ОбновитьПринудительно   - Булево    - Истина - принудительно обновить данные (вызов RAC)
//   КакСоответствие         - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание требования назначения функциональности сервера 1С
//
Функция Получить(Знач Ид, Знач ОбновитьПринудительно = Ложь, КакСоответствие = Ложь) Экспорт

	Отбор = Новый Соответствие();
	Отбор.Вставить("rule", Ид);

	СписокТребований = Элементы.Список(Отбор, ОбновитьПринудительно, КакСоответствие);
	
	Если СписокТребований.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат СписокТребований[0];

КонецФункции // Получить()

// Процедура добавляет новое требование назначения функциональности для сервера 1С
//   
// Параметры:
//   Позиция                 - Число            - позиция требования назначения функциональности в списке (начиная с 0)
//   ПараметрыТребования     - Структура        - параметры сервера 1С
//
Процедура Добавить(Позиция, ПараметрыТребования = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыТребования) = Тип("Структура") Тогда
		ПараметрыТребования = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСервера"     , Сервер_Владелец.Ид());

	ПараметрыКоманды.Вставить("Позиция"        , Позиция);

	Для Каждого ТекЭлемент Из ПараметрыТребования Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Добавить");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка добавления требования назначения функциональности ""%1"": %2",
		                            Позиция,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Добавить()

// Процедура удаляет требование назначения функциональности для сервера 1С
//   
// Параметры:
//   Ид            - Строка    - Идентификатор требования назначения функциональности 
//
Процедура Удалить(Ид) Экспорт
	
	Требование = Получить(Ид, Истина);

	Если Требование = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Требование.Удалить();

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()

// Процедура применяет измененные требования назначения функциональности для сервера 1С
//   
// Параметры:
//   ПрименитьЧастично    - Булево     - Истина - требования будут применены частично;
//                                       Ложь - требования будут применены полностью
//
Процедура Применить(Знач ПрименитьЧастично = Ложь) Экспорт

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	Если ПрименитьЧастично Тогда
		ПараметрыКоманды.Вставить("ПрименитьЧастично", Истина);
	Иначе
		ПараметрыКоманды.Вставить("ПрименитьПолностью", Истина);
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Применить");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка применения требований назначения функциональности: %1",
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Применить()
