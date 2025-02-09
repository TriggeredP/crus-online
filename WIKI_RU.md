# Cruelty Squad Online: Development Wiki

<div align="center">

<img src="crus_online_logo.png" width="600" alt="Cruelty Squad Online logo">

[English](WIKI.md) | Русский

</div>

[TOC]

## Структура модификации

```
Multiplayer: Главная нода мода
├── NetworkBridge: Используется для работы с функциями LAN и Steam мултиплеера
├── SteamInit: Инициализирует Steam
│   ├── SteamNetwork: Используется для обмена пакетами
│   └── SteamLobby: Используется для взаимодествия с лобби
├── Players: Создает, удаляет и обновляет игроков
└── UDPLagger: Эмулирует пинг и потерю пакетов для отладки LAN мултиплеера
```

## Импорт функций мултиплеера
Для использования функций мултиплеера нужно импортировать главные ноды мода
``` python
onready var Multiplayer = Global.get_node("Multiplayer")

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

onready var SteamInit = Global.get_node("SteamInit")
onready var SteamLobby = Global.get_node("SteamInit/SteamLobby")
onready var SteamNetwork = Global.get_node("SteamInit/SteamNetwork")
```

## Регистрация RPC функций
Для регистрации RPC функций Steam мултиплеера используются функция register_rpcs ноды NetworkBridge

``` python
func _ready():
	NetworkBridge.register_rpcs(self,[
		["function_a", NetworkBridge.PERMISSION.ALL], # Сервер <-> Клиент
		["function_b", NetworkBridge.PERMISSION.SERVER] # Сервер -> Клиент
	])
```

Для регистрации RPC функций LAN мултиплеера используются стандартные кейворды Godot (remote, puppet и master)

``` python
# Сервер -> Клиент
puppet func function_a(id):
	pass

# Сервер <- Клиент
master func function_b(id):
	pass

# Сервер <-> Клиент
remote func function_с(id):
	pass
```

## Основные функции NetworkBridge

|Возращение|Функции|
|--------|--------|
|void    |n_rpc(caller : Node, method = null, args = [])|
|void    |n_rpc_unreliable(caller : Node, method = null, args = [])|
|void    |n_rpc_id(caller : Node, id = 0, method = null, args = [])|
|void    |n_rpc_unreliable_id(caller : Node, id = 0, method = null, args = [])|
|void    |set_mode(mode : int)|
|bool    |is_lan()|
|bool    |is_steam()|
|bool    |check_connection()|
|array   |get_peers()|
|int     |get_id()|
|int     |get_host_id()|

### void n\_rpc(caller : Node, method = null, args = [])
Отправляет RPC пакет
### void n\_rpc\_unreliable(caller : Node, method = null, args = [])
### void n\_rpc\_id(caller : Node, id = 0, method = null, args = [])
### void n\_rpc\_unreliable\_id(caller : Node, id = 0, method = null, args = [])
### void set\_mode(mode : int)
Устанавливает режим работы мултиплеера:
0 - LAN
1 - Steam
### bool is\_lan()
Возращает **True** если выбран режим LAN мултиплеера
### bool is\_steam()
Возращает **True** если выбран режим Steam мултиплеера
### bool check\_connection()
Возращает **True** если игрок подключён к серверу или лобби
### array get\_peers()
Возращает массив подключённых пиров
### int get\_id()
Возращает ID игрока в мултиплеере
### int get\_host\_id()
Возращает ID хоста сервера или лобби