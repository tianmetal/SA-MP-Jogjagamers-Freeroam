# Jogjagamers Freeroam

### About

Jogjagamers Freeroam adalah gamemode SA:MP, fitur utama yang ditawarkan oleh gamemode ini adalah:

  - Gamemode yang terpisah berdasarkan module
  - Player Registration and Login system using MySQL plugin R41+
  - Per player vehicle spawning and ownership
  - Other fun commands

### Modules

Gamemode ini menyediakan 3 module yaitu:

  - Player (Registration and Login)
  - PlayerVehicle (Per player vehicle spawning and ownership)
  - PlayerWorld (Per player virtual world)

Tiap module memiliki beberapa file yang dipisah sesuai fungsi:
  - Header.inc (bersisi constants dan variables)
  - Function.inc (berisi functions yang berkaitan dengan module)
  - Callback.inc (berisi hooks untuk callback default SA:MP)
  - QueryCallback.inc (berisi callback plugin MySQL)
  - Timer.inc (berisi timers yang berkaitan dengan module)
  - Dialog.inc (berisi callback dialog menggunakan easyDialog)
  - Command.inc (berisi command menggunakan YCMD)

### Dependencies

| Name | Version | URL |
| ------ | ------ | ------ |
| SA:MP MySQL Plugin | R41+ | https://github.com/pBlueG/SA-MP-MySQL/releases |
| Sscanf2 | 2.8.2 | https://github.com/maddinat0r/sscanf/releases |
| Whirlpool | 1.0 | https://github.com/Southclaws/samp-whirlpool |
| YSI | 4+ | https://github.com/Misiur/YSI-Includes/releases |
| easyDialog | 2.0 | https://github.com/Awsomedude/easyDialog/releases |

### Installation

1. Compile script dengan semua dependencies yang dibutuhkan menggunakan SA:MP versi 0.3.7 R2
2. Ubah file mysql.ini sesuai konfigurasi server MySQL / MariaDB kamu
3. Buat table baru dengan query berikut:

```sql
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL DEFAULT '',
  `password` varchar(130) NOT NULL DEFAULT '',
  `register_date` int(11) NOT NULL DEFAULT 0,
  `last_login_date` int(11) NOT NULL DEFAULT 0,
  `playtime` int(11) NOT NULL DEFAULT 0,
  `skin` int(11) NOT NULL DEFAULT 299,
  `pos_x` float(12,4) NOT NULL DEFAULT 0.0000,
  `pos_y` float(12,4) NOT NULL DEFAULT 0.0000,
  `pos_z` float(12,4) NOT NULL DEFAULT 3.0000,
  `pos_a` float(12,4) NOT NULL DEFAULT 0.0000,
  `kills` int(11) NOT NULL DEFAULT 0,
  `deaths` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
```
4. Setelah itu jalankan SA:MP server kamu
