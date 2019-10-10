// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем РежимыАдминистрирования Экспорт;
Перем ВариантыИспользованияРабочегоСервера Экспорт;
Перем ВариантыИспользованияМенеджераКластера Экспорт;
Перем ВариантыРазмещенияСервисов Экспорт;
Перем СостоянияВыключателя Экспорт;
Перем ДаНет Экспорт;
Перем ПраваДоступа Экспорт;
Перем РежимыРаспределенияНагрузки Экспорт;
Перем СпособыАвторизации Экспорт;
Перем ТипыСУБД Экспорт;
Перем Использование Экспорт;
Перем ТипыНазначенияФункциональности Экспорт;
Перем ОбъектыНазначенияФункциональности Экспорт;
Перем РежимыДоступа Экспорт;
Перем ВидыОбъектовПрофиляБезопасности Экспорт;
Перем ДействияСБазойСУБДПриУдалении Экспорт;
Перем Приложения Экспорт;
Перем ТипыГруппировкиСчетчиковРесурсов Экспорт;
Перем ТипыОтбораСчетчиковРесурсов Экспорт;
Перем ВремяНакопленияСчетчиковРесурсов Экспорт;
Перем СостоянияСчетчиковРесурсов Экспорт;
Перем ПоляОтбораСчетчиковРесурсов Экспорт;
Перем ДействияОграниченияРесурсов Экспорт;
Перем СпособыПодключения Экспорт;

Функция Значение(Знач ПутьКЗначению) Экспорт

	МассивПеречисления = СтрРазделить(ПутьКЗначению, ".");

	Попытка
		Возврат ЭтотОбъект[МассивПеречисления[0]][МассивПеречисления[1]];
	Исключение
		ВызватьИсключение СтрШаблон("Не найдено значение ""%1"" перечисления ""%2"":%3",
									МассивПеречисления[1],
									МассивПеречисления[0],
									ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;

КонецФункции // Значение()

// Процедура инициализирует значения перечисления "РежимыАдминистрирования"
// из данных макета "ТипыОбъектовКластера.json"
//   
Процедура ЗаполнитьРежимыАдминистрирования()

	ДанныеМакета = Служебный.ПрочитатьДанныеИзМакетаJSON("ТипыОбъектовКластера");

	РежимыАдминистрирования = Новый Структура();

	Для Каждого ТекТип Из ДанныеМакета Цикл

		Если НЕ ТекТип.Значение.Свойство("РежимАдминистрирования") Тогда
			Продолжить;
		КонецЕсли;

		РежимыАдминистрирования.Вставить(ТекТип.Ключ, ТекТип.Значение.РежимАдминистрирования);

		Если НЕ (ТипЗнч(ТекТип.Значение) = Тип("Структура") И ТекТип.Значение.Свойство("Свойства")) Тогда
			Продолжить;
		КонецЕсли;

		Для Каждого ТекСвойство Из ТекТип.Значение.Свойства Цикл
			Если НЕ ТекСвойство.Значение.Свойство("РежимАдминистрирования") Тогда
				Продолжить;
			КонецЕсли;
			РежимыАдминистрирования.Вставить(ТекСвойство.Ключ,
			                                 СтрШаблон("%1.%2",
			                                           ТекТип.Значение.РежимАдминистрирования,
			                                           ТекСвойство.Значение.РежимАдминистрирования));
		КонецЦикла;

	КонецЦикла;

КонецПроцедуры // ЗаполнитьРежимыАдминистрирования()

// Процедура инициализирует значения перечислений
// из данных макета "Перечисления.json"
//   
Процедура Инициализация()

	ДанныеМакета = Служебный.ПрочитатьДанныеИзМакетаJSON("Перечисления");

	Для Каждого ТекПеречисление Из ДанныеМакета Цикл
		Попытка
			ЭтотОбъект[ТекПеречисление.Ключ] = Новый Структура();
		Исключение
			ВызватьИсключение СтрШаблон("Не найдено перечисление ""%1"":%2",
			                            ТекПеречисление.Ключ,
			                            ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецПопытки;
		Для Каждого ТекЗначение Из ТекПеречисление.Значение Цикл
			Попытка
				ЭтотОбъект[ТекПеречисление.Ключ].Вставить(ТекЗначение.Ключ, ТекЗначение.Значение);
			Исключение
				ВызватьИсключение СтрШаблон("Не найдено значение ""%1"" перечисления ""%2"":%3",
				                            ТекЗначение.Ключ,
				                            ТекПеречисление.Ключ,
				                            ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			КонецПопытки;
		КонецЦикла;
	КонецЦикла;

	ЗаполнитьРежимыАдминистрирования();

КонецПроцедуры // Инициализация()

Инициализация();