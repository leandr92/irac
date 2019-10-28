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
Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера    - ссылка на родительский объект агента кластера
//   Кластер            - Кластер        - ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.СчетчикиРесурсов);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список счетчиков потребления ресурсов от утилиты администрирования кластера 1С
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
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка счетчиков ресурсов, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивСчетчиков = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивСчетчиков.Добавить(Новый СчетчикРесурсов(Кластер_Агент, Кластер_Владелец, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивСчетчиков);

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

// Функция возвращает список счетчиков потребления ресурсов кластера 1С
//   
// Параметры:
//   Отбор                    - Структура    - Структура отбора счетчиков потребления ресурсов (<поле>:<значение>)
//   ОбновитьПринудительно    - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список счетчиков потребления ресурсов кластера 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	СписокСчетчиков = Элементы.Список(Отбор, ОбновитьПринудительно, ЭлементыКакСоответствия);
	
	Возврат СписокСчетчиков;

КонецФункции // Список()

// Функция возвращает счетчиков потребления ресурсов кластера 1С
//   
// Параметры:
//   ПоляИерархии             - Строка        - Поля для построения иерархии списка счетчиков потребления ресурсов,
//                                              разделенные ","
//   ОбновитьПринудительно    - Булево        - Истина - обновить список (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список счетчиков потребления ресурсов кластера 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список счетчиков потребления ресурсов
//                                                                        или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	СписокСчетчиков = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно, ЭлементыКакСоответствия);
	
	Возврат СписокСчетчиков;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество счетчиков потребления ресурсов в списке
//   
// Возвращаемое значение:
//    Число - количество счетчиков потребления ресурсов
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание счетчика потребления ресурсов кластера 1С
//   
// Параметры:
//   Имя                    - Строка    - Имя счетчика потребления ресурсов
//   ОбновитьПринудительно  - Булево    - Истина - принудительно обновить данные (вызов RAC)
//   КакСоответствие        - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание счетчика потребления ресурсов кластера 1С
//
Функция Получить(Знач Имя, Знач ОбновитьПринудительно = Ложь, КакСоответствие = Ложь) Экспорт

	ОбновитьДанные(ОбновитьПринудительно);

	Отбор = Новый Соответствие();
	Отбор.Вставить("name", Имя);

	СписокСчетчиков = Элементы.Список(Отбор, ОбновитьПринудительно, КакСоответствие);
	
	Если СписокСчетчиков.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат СписокСчетчиков[0];

КонецФункции // Получить()

// Процедура добавляет новый счетчик потребления ресурсов в кластер 1С
//   
// Параметры:
//   Имя                 - Строка        - имя счетчика потребления ресурсов 1С
//   ПараметрыСчетчика   - Структура     - параметры счетчика потребления ресурсов 1С
//
Процедура Добавить(Имя, ПараметрыСчетчика = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыСчетчика) = Тип("Структура") Тогда
		ПараметрыСчетчика = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИмяСчетчика"              , Имя);

	Для Каждого ТекЭлемент Из ПараметрыСчетчика Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	Если ПараметрыКоманды["ДлительностьСбора"] = Неопределено Тогда
		ПараметрыКоманды.Вставить("ДлительностьСбора", Перечисления.ВремяНакопленияСчетчиковРесурсов.ТекущийВызов);
	КонецЕсли;

	Если ПараметрыКоманды["Группировка"] = Неопределено Тогда
		ПараметрыКоманды.Вставить("Группировка", Перечисления.ТипыГруппировкиСчетчиковРесурсов.Пользователи);
	КонецЕсли;

	Если ПараметрыКоманды["ТипОтбора"] = Неопределено Тогда
		ПараметрыКоманды.Вставить("ТипОтбора", Перечисления.ТипыОтбораСчетчиковРесурсов.Все);
	КонецЕсли;

	Если ПараметрыКоманды["Отбор"] = Неопределено Тогда
		ПараметрыКоманды.Вставить("Отбор", "");
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Изменить");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка добавления счетчика потребления ресурсов ""%1"": %2",
	                                Имя,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Добавить()

// Процедура удаляет счетчик потребления ресурсов
//   
// Параметры:
//   Имя     - Строка   - Имя счетчика потребления ресурсов
//
Процедура Удалить(Знач Имя) Экспорт
	
	Если ТипЗнч(Имя) = Тип("Строка") Тогда
		Счетчик = Получить(Имя);
	КонецЕсли;

	Счетчик.Удалить();

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()
