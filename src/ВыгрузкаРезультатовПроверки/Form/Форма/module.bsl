﻿
#Область ОбработчикиСобытийФормы

Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	
	//РежимОтладки = Истина;
	
	УстановитьЗаголовокФормы();
	
	ОбработатьПараметрыЗапуска();
	ПостОбработкаВывестиПараметрыВСообщения();
	ПараметрыЗаполненыКорректно = ПроверитьЗаполнениеПараметровОбработки();
	
	Если ПараметрыЗаполненыКорректно И Не РежимОтладки Тогда
		
		ЗапускПроверки();
		ИнициализироватьПервичныеДанные();
		ЭкспортироватьОшибкиАПК();
		
	КонецЕсли;
	
	Если Не РежимОтладки Тогда
		ЗавершитьРаботуСистемы(Ложь, Ложь);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриОткрытии()
	
	Если ПустаяСтрока(ФорматЭкспорта) Тогда
		ФорматЭкспорта = ФорматЭкспортаReportJSON;
		УстановитьЗначениеФорматаЭкспортаНаФорме(ФорматЭкспорта);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

Процедура КнопкаВыполнитьНажатие(Кнопка)
	
	ЗапускПроверки();
	ИнициализироватьПервичныеДанные();
	ЭкспортироватьОшибкиАПК();
	
КонецПроцедуры

Процедура КаталогПроектаНачалоВыбора(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	// перевести в немодальное
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	Диалог.Заголовок = "Выбор каталога проекта";
	Если Диалог.Выбрать() Тогда
		КаталогПроекта = Диалог.Каталог + "\";	
	КонецЕсли;
	
КонецПроцедуры

Процедура ФорматЭкспортаОчистка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОбработатьПараметрыЗапуска()
	
	// Порядок чтения параметров
	// Файл параметров берется из аргумента, если не указан, то ищется рядом с обработкой
	// Параметры читаются из аргументов, если не указаны, то из файла параметров

	ПутьКФайлуПараметров = "";
	
	ФайлОбработки = Новый Файл(ИспользуемоеИмяФайла);
	ПутьКФайлуОбработки = ФайлОбработки.Путь;
	
	мПараметрЗапуска = ?(
		Не РежимОтладки, 
		ПараметрЗапуска, 
		"acc.propertiesPaths=F:\DATA\Develop\Sonar\project\mobile-sk\acc.properties;"); 
	
	Аргументы = СтрРазделить(мПараметрЗапуска, ";", Ложь);
	ФайлОбработки = Новый Файл(ИспользуемоеИмяФайла);
	ПутьКФайлуОбработки = ФайлОбработки.Путь;
	
	Для каждого цАргумент Из Аргументы Цикл
		
		ЗаполнитьПараметр(цАргумент, "acc.propertiesPaths", ПутьКФайлуПараметров);
		Если вРег(цАргумент) = "/DEBUG" Тогда  // за счет параметра открываем для отладки в клиенте
			РежимОтладки = Истина;	
		КонецЕсли;
		
	КонецЦикла;
				
	Если Не ЗначениеЗаполнено(ПутьКФайлуПараметров) Тогда
		
		ПутьКФайлуПараметров = ПутьКФайлуОбработки + "acc.properties";
		
	КонецЕсли;
	
	ПрочитатьФайлПараметров(ПутьКФайлуПараметров);
	
	Для каждого цАргумент Из Аргументы Цикл
		
		ПрочитатьПараметрыВСтроке(цАргумент);
		
	КонецЦикла;
	
	ОбеспечитьАбсолютныйПутьККаталогу(ПутьКФайлуОбработки);
	
	ПостОбработкаПараметров();

	ОбеспечитьАбсолютныйПутьККаталогуИсходныхКодов(ПутьКФайлуОбработки);
	
КонецПроцедуры

Функция ПроверитьЗаполнениеПараметровОбработки()
	
	Результат = Истина;
	
	Если Конфигурация.Пустая() Тогда
		Результат = Ложь;		
	КонецЕсли;
	
	Файл = Новый Файл(КаталогПроекта);
	Если Не (Файл.Существует() И Файл.ЭтоКаталог()) Тогда
		Результат = Ложь;		
	КонецЕсли;
	
	Файл = Новый Файл(КаталогИсходныхКодов);
	Если Не (Файл.Существует() И Файл.ЭтоКаталог()) Тогда
		Результат = Ложь;		
	КонецЕсли;
	
	Если ПустаяСтрока(ФорматЭкспорта) Тогда
		Результат = Ложь;	
	КонецЕсли;
	
	Если ПустаяСтрока(ФорматПредставленияОшибки) Тогда
		Результат = Ложь;	
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Процедура ПрочитатьФайлПараметров(Знач ПутьКФайлуПараметров)
	
	Сообщить( СтрШаблон( "Читаю файл параметров %1", ПутьКФайлуПараметров ) );
	
	файлПараметров = Новый Файл( ПутьКФайлуПараметров );
	
	Если Не файлПараметров.Существует() Тогда
		Сообщить( СтрШаблон( "Файл параметров %1 не найден.", ПутьКФайлуПараметров ) );
		Возврат;
	КонецЕсли;
	
	чтениеФайлаПараметров = Новый ТекстовыйДокумент;
	чтениеФайлаПараметров.Прочитать( файлПараметров.ПолноеИмя, КодировкаТекста.UTF8 );
	
	Для ц = 0 По чтениеФайлаПараметров.КоличествоСтрок() Цикл
		
		текСтрока = чтениеФайлаПараметров.ПолучитьСтроку( ц );
		
		ПрочитатьПараметрыВСтроке( текСтрока );
		
	КонецЦикла;
	
	чтениеФайлаПараметров = Неопределено;
	
	ОбеспечитьАбсолютныйПутьККаталогу(файлПараметров.Путь);
	
КонецПроцедуры

Процедура ОбеспечитьАбсолютныйПутьККаталогу(Знач КаталогРодитель)
	
	Если Не ЗначениеЗаполнено(КаталогПроекта) Тогда
		Возврат;
	КонецЕсли;
	
	Сообщить(СтрШаблон("Вычисление пути к каталогу проекта. Текущий путь = %1, каталог-родитель = %2", КаталогПроекта, КаталогРодитель));
	
	Если Не СтрНачинаетсяС(КаталогПроекта, ".") Тогда
		
		каталог = Новый Файл(КаталогПроекта);
		
		Если каталог.ЭтоКаталог()
			И каталог.Существует() Тогда
			
			// каталог найден и существует
			
			Сообщить(СтрШаблон("Текущий путь = %1", КаталогПроекта));
			Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(КаталогРодитель) Тогда
		Возврат;
	КонецЕсли;
		
	каталог = Новый Файл(КаталогРодитель + ПолучитьРазделительПути() + КаталогПроекта);
	
	Сообщить(СтрШаблон("Вычисление по родителю = %1", каталог.ПолноеИмя));
	
	Если каталог.ЭтоКаталог()
		И каталог.Существует() Тогда
		
		// каталог найден и существует
		
		КаталогПроекта = каталог.ПолноеИмя;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбеспечитьАбсолютныйПутьККаталогуИсходныхКодов(Знач КаталогРодитель)

	Если ПустаяСтрока(КаталогИсходныхКодов) Тогда
		КаталогИсходныхКодов = "src";		
	КонецЕсли;
	
	Сообщить("Вычисление пути к исходникам");	

	ЭтоПолныйПуть = СтрНайти(КаталогИсходныхКодов, ":") > 0;
	
	Файл = Новый Файл(КаталогИсходныхКодов);
	Если Не (Файл.Существует() И Файл.ЭтоКаталог() И ЭтоПолныйПуть)Тогда
		
		Сообщить("Тест: Нет каталога 1");
		
		Каталог = КаталогПроекта + ПолучитьРазделительПути() + СтрЗаменить(КаталогИсходныхКодов, "/", ПолучитьРазделительПути());
		Файл = Новый Файл(Каталог);
		Если Не (Файл.Существует() И Файл.ЭтоКаталог()) Тогда
			Сообщить("Не удалось определить каталог исходных кодов: " + Каталог);
			КаталогИсходныхКодов = "";
			Возврат;
			
		Иначе
			
			Сообщить("Тест: Нет каталога 2");
			
		КонецЕсли;
		
		ОтносительныйКаталогИсходныхКодов = КаталогИсходныхКодов;
		
	Иначе
		
		// если каталог исходных был задан не относительный - запрещаем выводить относительные
		ВыводитьОтносительныеПути = Ложь;
		
		Сообщить("Тест: Нет каталога 3: " + Файл.Путь);
		
	КонецЕсли;
	
	КаталогИсходныхКодов = Файл.ПолноеИмя + ПолучитьРазделительПути();
	
КонецПроцедуры

Процедура ПрочитатьПараметрыВСтроке(Знач СтрокаСПараметром)
	
	ЗаполнитьПараметр(СтрокаСПараметром, "acc.projectKey", ИмяПроекта);
	ЗаполнитьПараметр(СтрокаСПараметром, "acc.catalog", КаталогПроекта);
	ЗаполнитьПараметр(СтрокаСПараметром, "acc.sources", КаталогИсходныхКодов);
	ЗаполнитьПараметр(СтрокаСПараметром, "acc.check", ЗначениеПараметра_ВыполнятьПроверку);
	ЗаполнитьПараметр(СтрокаСПараметром, "acc.format", ФорматЭкспорта);
	ЗаполнитьПараметр(СтрокаСПараметром, "acc.titleError", ФорматПредставленияОшибки);
	ЗаполнитьПараметр(СтрокаСПараметром, "acc.relativePathToFiles", ЗначениеПараметра_ОтносительныеПутиКФайлам);

КонецПроцедуры

Процедура ЗаполнитьПараметр(Знач СтрокаПараметра, Знач ИмяПараметра, ЗначениеПараметра)
	
	текСтрокаВРег = ВРег(СтрокаПараметра);
	
	Если Не СтрНачинаетсяС(текСтрокаВРег, ВРег(ИмяПараметра)) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	позРавно = СтрНайти( СтрокаПараметра, "=" );
	
	Если позРавно = 0 Тогда
		
		Возврат;
		
	КонецЕсли;
	
	ЗначениеПараметра = СокрЛП( Сред( СтрокаПараметра, позРавно + 1 ) );
	
	Сообщить( "Найден параметр " + ИмяПараметра + " = " + ЗначениеПараметра );
	
КонецПроцедуры

Процедура ПостОбработкаПараметров()
	
	Если ЗначениеЗаполнено(ИмяПроекта) Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	Конфигурации.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Конфигурации КАК Конфигурации
		|ГДЕ
		|	Конфигурации.Наименование = &Наименование";
		Запрос.УстановитьПараметр("Наименование", ИмяПроекта);
		
		выборка = Запрос.Выполнить().Выбрать();
		
		Если выборка.Следующий() Тогда
			
			Конфигурация = выборка.Ссылка;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КаталогПроекта)
		И Не СтрЗаканчиваетсяНа(КаталогПроекта, ПолучитьРазделительПути()) Тогда
		
		КаталогПроекта = КаталогПроекта + ПолучитьРазделительПути();
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ФорматПредставленияОшибки) Тогда
		ФорматПредставленияОшибки = ФорматОшибкиКодНаименование;	
	КонецЕсли;
	
	ЗначениеПараметра_ВыполнятьПроверку = ВРег(ЗначениеПараметра_ВыполнятьПроверку);	
	ВыполнятьПроверку = ЗначениеПараметра_ВыполнятьПроверку = "TRUE" ИЛИ ЗначениеПараметра_ВыполнятьПроверку = "1" ИЛИ ЗначениеПараметра_ВыполнятьПроверку = "ИСТИНА";
	
	ЗначениеПараметра_ОтносительныеПутиКФайлам = ВРег(ЗначениеПараметра_ОтносительныеПутиКФайлам);
	ВыводитьОтносительныеПути = ЗначениеПараметра_ОтносительныеПутиКФайлам = "TRUE" ИЛИ ЗначениеПараметра_ОтносительныеПутиКФайлам = "1" ИЛИ ЗначениеПараметра_ОтносительныеПутиКФайлам = "ИСТИНА";	
	
КонецПроцедуры

Процедура ПостОбработкаВывестиПараметрыВСообщения()
	
	Сообщить("Имя проекта = " + ИмяПроекта);
	Сообщить("Конфигурация = " + Конфигурация + ", код: " + Конфигурация.Код);
	Сообщить("Каталог исходников = " + КаталогПроекта);
	Сообщить("Выполнять проверку = " + ВыполнятьПроверку);
	Сообщить("Формат экспорта = " + ФорматЭкспорта);

КонецПроцедуры

Процедура ЗапускПроверки()
	
	Если Не ВыполнятьПроверку Или Не ЗначениеЗаполнено(Конфигурация) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Сообщить("Начало проверки конфигурации " + ТекущаяДата());
	
	ФормаЗапускаПроверки = ПолучитьФорму("Обработка.ЗапускПроверки.Форма");
	ФормаЗапускаПроверки.Конфигурация = Конфигурация;
	ФормаЗапускаПроверки.ФлагПроверкаПоРасписанию = Истина;
	ФормаЗапускаПроверки.ВариантПроверкиПоРасписанию = Конфигурация.ВариантПроверкиПоРасписанию;
	ФормаЗапускаПроверки.РегистрироватьВсеОшибкиКакОсобенности = Конфигурация.РегистрироватьВсеОшибкиКакОсобенностиПоРасписанию;
	
	ФормаЗапускаПроверки.Открыть();
	ФормаЗапускаПроверки.ВыполнитьПроверку();
	ФормаЗапускаПроверки.Закрыть();
	
	Сообщить("Окончание проверки конфигурации " + ТекущаяДата());

КонецПроцедуры

Процедура УстановитьЗначениеФорматаЭкспортаНаФорме(Знач ВходящееЗначение)
	
	Элемент = ЭтаФорма.ЭлементыФормы.ФорматЭкспорта; 
	СписокВыборка = Элемент.СписокВыбора;
	
	ВходящееЗначение = нРег(ВходящееЗначение);
	Значение = СписокВыборка.НайтиПоЗначению(ВходящееЗначение);	
	Элемент.Значение = Значение;
	
КонецПроцедуры

Процедура УстановитьЗаголовокФормы()
	
	Сообщить("Версия обработки " + ВерсияОбработки);	
	ЭтаФорма.Заголовок = ЭтаФорма.Заголовок + " v." + ВерсияОбработки;
	
КонецПроцедуры

#КонецОбласти