# RSA - Remote Shadow Administrator

Программа для подключения к текущим RDP-сессиям по средствам **Shadow-подключения**, а так же содержит сборник скриптов по **автоматизации удаленного администрирования**.

Можно использовать как альтернативное средство удаленного подключения (например, Radmin или VNC, которые требуют установки программного обеспечения и имеют некоторые уязвимости безопасности). Используется 100% кода на powershell и Windows Forms (написан без использования Visual Studio).

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Users.jpg)

При выборе сервера и нажатии на кнопку "Проверить" отображается список текущих пользователей в виде таблицы (с версии 1.3.1). **При выборе ID пользователя можно произвести три действия: Shadow-подключение с возможностью запроса на подключение и без (последнее настраивается через GPO), отключение пользователя (выход из системы) и отправки набранного сообщения всем пользователям на сервере или выбранному в таблице.** Создание таблицы происходит в 3 этапа, вначале проверяется доступность сервера, о чем сообщается в статус-баре и дополнительно проверяется uptime (если не доступен WinRM, программа об этом сообщит), если сервер не доступен, во избежание долгой задержки проверка пользователей не производится. На втором этапе парсится вывод команды query по средствам Regex, на последнем происходит создание Custom Object с выводом в DGV. 
> Для поиска пользователей в сети можно воспользоваться [этим скриптом](https://github.com/Lifailon/Find-Users).

Для подключение к серверу через rdp используется mstsc с ключем /admin, что позволяет подключаться к RDSH-серверу минуя Broker. **Для аутентификации используется cmdkey**, после прохождения единоразовой аутентификации (в меню Файл - Аутентификация), в последствии происходит предварительная аутентификация на все сервера в списке и действует до закрытия программы, **что позволяет не хранить пароль администратора в коде, а так же хранилище ключей ОС (которые можно скомпрометировать)**. 

> Необходимо предварительно создать список серверов, который хранится в файле "%USERPROFILE%\Documents\RSA.conf.txt" (находится в репозитории с файлом exe). Список можно вызвать из программы нажатием правой кнопки мыши в списке серверов или комбинацией клавиш Ctrl+S.

## Обновление 1.3.2
* После внесения изменений в список серверов, для обновления списка из самой программы добавлена кнопка Обновить (Файл - Обновить, при нажатии правой кнопки мыши в списке, или сочетанием клавиш Ctrl+R).
* Добавлена возможность заполнить список серверов всеми компьютерами в домене (Ctrl+D).
* Таблица списка серверов домена с возможность поиска зарегестрированных на них пользователях (ManagedBy) а так же сортировки по статусу (Активный/Заблокирован), версии ОС и времени создания (Ctrl+T) с возможностью выбора для вывода списка пользователей и взаимодействия.
* Добавлена возможность выбора внешнего источника синхронизации компьютерных часов (Время - Изменить источник), например: ru.pool.ntp.org
* В меню Питание добавлены скрипты по удаленному отключению/включению спящего режима и блокировки экрана.
### Скрипты по активации корпоративных лицензий в сети (KMS).
* Узнать редакцию и версию ОС, канал получения лицензии, тип ключа, статус активации и сервер лицензирования.
* Узнать адрес KMS-сервера в сети по srv-записи.
* GVLK-активатор. Содержит публичные ключи GVLK (Generic Volume License Key) с возможностью удаленной активации.
* Указать в ручную KMS-сервер (например, если KMS-сервер не опубликован в DNS).
* Получить лицензию в ручную.

## Версия 1.3.1. Скрипты по автоматизации удаленного администрирования.
**Типовые:** перезагрузка и выключение (shutdown) с задержкой 30 секунд и возможностью отмены. Управление компьютером (Computer Management), gpupdate на удаленной машине, gpresult с выводом в XML-файл и указанием пользователя. Проверка служб с возможностью удобной фильтрации поиска и повторной проверки статуса после остановки/перезапуска. Список запущенных процессов пользователей с возможностью их завершения. Список открытых SMB-сессий с возможностью их закрытия для освобождения файла. Просмотр всех сетевых ресурсов с возможностью открытия (в т.ч. c$). Просмотр и фильтрация логов (используется 3 журнала).

**Заимствованные:** TCP Viewer (источник: [winitpro](https://winitpro.ru/index.php/2021/01/25/get-nettcpconnection-powershell-nestat)) - производит resolve FQDN для всех удаленных адресов и через Get-Process по ID определяет path исполняемого процесса. Подключение к Connection Broker (требуется установленный модуль RemoteDesktop) с возможностью Shadow-подключения к пользователю. Wake on Lan (источник: [coolcode](https://coolcode.ru/wake-on-lan-and-powershell)) - формирование Magic Packet c отправкой broadcast (MAC-адрес берется из формы ввода сообщения). Проверка свободного места на разделах дисков (источник: [fixmypc](https://fixmypc.ru/post/kak-uznat-v-powershell-svobodnoe-mesto-na-diske)) и по аналогии ОЗУ.

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Disk.jpg)

## **Собственные реализации:**

### **Поиск MAC-адреса компьютера**.
Используется в случае, если нужно узнать MAC-адрес компьютера, который уже не доступен. Производится по средствам просмотра ARP-таблиц на других серверах в качестве proxy. 2-й вариант, просмотр всех клиентов на сервере с ролью DHCP (установка модуля не требуется) в виде таблицы с сортировкой вывода. Используется для последующей отправки Magic Packet.

### **Скрипты по синхронизации компьютерных часов (w32tm):**
* Отображает текущее время на сервере и разницу с сервером источника (localhost). 
* Узнать источник времени, а так же частоту и время последней синхронизации (последнее отображается в зависимости от языкового пакета на удаленной машине). 
* Проверка сервера как источника времени. 
* Незамедлительно синхронизировать время на удаленном сервере с источником. 
* Изменить на удаленном сервере источник времени на ближайший DC в подсети.

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Times.jpg)

### **WMI:** 
* Просмотр списка обновлений (при нажатии кнопки ок, номер обновления копируется в буфер обмена). В связи с тем, что более не поддерживается удаление обновлений через WUSA в тихом режиме, используется в связке с DISM online (специально оставил отдельной вкладкой, можно автоматизировать сразу процесс удаления и/или отпарсить вывод dism для реализации полноценной таблицы).
* Список установленных драйверов.
* Удаленная проверка, а так же включение/отключение rdp и nla. 
* Список установленных программ с возможностью удаления. Используется два метода: get-packet и gwmi. Пример:

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Programs.jpg)

* **Инвентаризация комплектующих** - модель процессора, мат. платы, видеокарты, оперативной памяти, модель дисков, с конвертацией в HTML-файл:

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Report.jpg)

* **Установка программ**. Через install-package (сейчас используется этот вариант в меню: WMI - Установка) и 2 метода gwmi (function wmi-installer). В первом случае установка происходит не на всех серверах (не зависимо от использования версии TLS), в случае с wmi установка происходит из unc-пути только на тот же сервер, где лежит msi-пакет (в т.ч. через invoke session и предварительной аутентификацией на удаленной машине, директория через icm доступна по пути).

По вопросам и предложениям **Telegram: @kup57**
