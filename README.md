Compilar Molden en Linux
========================

Instrucciones para compilar `molden` en Linux (Fedora 44). Estas instrucciones también deberían funcionar en otras distribuciones (Ubuntu, etc).

- Instala las dependencias

En Fedora:
```
$ sudo dnf install gcc-gfortran libX11 libX11-devel mesa-libGL mesa-libGL-devel mesa-libGLU-devel libXmu-devel wget
```
En Ubuntu:
```
$ sudo apt-get install gfortran libX11-6 libX11-dev libgl1-mesa-glx libgl1-mesa-dev build-essential mesa-common-dev libglu1-mesa-dev libxmu-dev makedepend xutils-dev wget
```
- Descarga `molden` y extrae el archivo
```
$ wget https://ftp.science.ru.nl/Molden/molden7.3.tar.gz
$ tar -xf molden7.3.tar.gz
$ cd molden7.3
```
- Edita el archivo `makefile` y añade `-w -fallow-argument-mismatch` en cada variable `FFLAGS`
- Alternativamente, clona el repositorio y reemplaza el archivo `makefile`
```
$ git clone https://github.com/ferant2406/Molden-Fedora-Linux-PCF.git
```
- Compila el programa
```
$ make CC="gcc -std=gnu17"
```
- Después de terminar el proceso, convierte los archivos a ejecutables y pruebalos
```
$ chmod u+x bin/molden
$ chmod u+x bin/gmolden
$ ./bin/molden
$ ./bin/gmolden
```
- Además, puedes copiar los archivos a un directorio de `PATH` para ejecutar `molden` en cualquier momento
```
$ sudo cp -v bin/molden /usr/local/bin/
$ sudo cp -v bin/gmolden /usr/local/bin/
```
- También puedes crear un directorio nuevo y añadirlo a `PATH`
```
$ mkdir -pv ~/.local/bin/
$ cp -v bin/molden ~/.local/bin/
$ cp -v bin/gmolden ~/.local/bin/
$ echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```
