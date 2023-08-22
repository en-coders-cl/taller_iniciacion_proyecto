# Taller: Iniciación en Proyectos de Analítica Avanzada

Bienvenidos al repositorio del taller sobre la iniciación en proyectos de analítica avanzada.

**Objetivo del Taller:**

Nuestro propósito es guiar a los participantes en el arranque exitoso de un proyecto. En este taller, enfatizaremos la importancia de definir con claridad:

* Las metodologías óptimas.
* La infraestructura necesaria.
* Las herramientas recomendadas.

Al final, los participantes contarán con una comprensión sólida sobre cómo desarrollar proyectos de analítica avanzada de manera eficiente y efectiva.

## Aprendizaje a desarrollar

1. **Metodologia**: Documentar correctamente el proyecto.
2. **Infraestructura**: Almacenamiento en base de datos relacional y columnar.
3. **Infraestructura**: Entender el poder de computo del computador a ocupar
4. **Infraestructura**: Control de versiones de código.
5. **Metodologia**: Interfaz de interracion.
6. **Herramientas**: Herramienta de apoyo de desarrollo de código.
7. **Herramientas**: Herramienta de apoyo de ejecucion de código.
8. **Herramientas**: Herramienta de apoyo de disponibilizar de código.   
9. **Metodologia**: Servicios de apoyo de desarrollo de código.
10. **Metodologia**: Tipo de estructura de ejecucion.
11. **Metodologia**: Tipo de paradigma de programación.
12. **Metodologia**: Estructura de carpeta.
11. **Metodologia**: Estructura de codigo.

## Recursos Relevantes

* [Repaso de la Metodologia de Desarrollo](http://google.com)
* [Bitacora del Proyecto](http://google.com)
* [Presentacion](http://google.com)
* [Papers](http://google.com)

## Conocimientos previos.
* Conocimientos basicos de R
* Conocimientos basicos de Python
* Conocimientos basicos de SQL
* Conocimientos basicos de AWS
* Conocimientos basicos de Git
* Conocimientos basico de Linux y Bash
* Conocimientos basicos en Nano o Vim

## Herramientas ya instaladas.

Herramientas necesarias para ejecutar el proyecto:

* WSL
* Terminal
* Visual Studio Code
* Web Browser

## Contenido

* [Configuración Inicial](#configuración-inicial)


# Configuración Inicial

En esta sección se detalla la configuración inicial de la infraestructura para poder ejecutar el proyecto. Sigue los pasos en orden y al detalle.

Cuando aparece un comoando entre <>, significa que hay que reemplazarlo por el valor correspondiente segun el caso.

## Iniciar WSL

* Abrir la terminal WSL

## Clonar el proyecto
```
cd ~/Documents/
git clone <encoders>workshop_back2basic.git
```

## Revisar si existe carpeta "file"

* Con "file" nos referimos a la carpeta que tiene archivos o objetos del proyectos que estan en AWS S3.

* Una vez hecho el symlink, solo se tiene que hacer una vez

* Validar si la carpeta existe en el bucket.

```
ls -l /mnt/<bucket>/workshop_back2basic/
```

* Si no existe, crearla en el bucket
```
mkdir /mnt/<bucket>/workshop_back2basic/
```

* La carpeta "files" NO tiene que estar creada <- sola cuando recien clono el proyecto
* en la carpta del proyecto ejecuto
```
cd ~/Documents/workshop_back2basic/
ln -s /mnt/<bucket>/workshop_back2basic/ files
```

* Validar el contenido
```
ls -l files 
```
* Debe aparece que la carpeta "files" es un link simbolico, al mostrar que tiene una flecha "->" y el destino del link


![Archivos con variables secretas](_config_workshop/config_env.png)


* Nota: Estos archivos estan en el .gitignore, por lo que no se suben al repositorio.

## Ocupar renv para instalar librerias de R

Instalar librerias necesarias para ejecución de proyecto:

* Abrir el proyecto desde RStudio o ingresando a la carpeta del proyecto desde la consola  y iniciar la consolta de R:
* La primerae vez que se ingresa va a instalar la version renv correspondiente al proyecto
* Si existe un problema al instalar un paquete consultar a la comunidad a traves del canal de "Resolucion de Problemas"

```r
renv::restore(exclude = c('pipe','arrow'), prompt = F)
```

* Instalar arrow
```r	
Sys.setenv(ARROW_USE_PKG_CONFIG = "false")
install.packages("arrow") # Cuando finaliza de installar pregunta que hacer, elegir la opcion 1 que dice: Snapshot, just using the currently installed packages.
arrow::install_arrow() 
```

## Instalación de librerias internas: Pipe


```r
renv::install("devtools")
```

A continuación, instalar el toolkit utilizando la siguiente función en la misma consola de R:

```r
devtools::install_bitbucket("<>/pipe",
                            auth_user = Sys.getenv("bitbucket_app_user"),
                            password = Sys.getenv("bitbucket_app_pass"),
                            ref = "master") #choose not to update dependencies
```

## Ocupar virtualenv para instalar librerias de Python

Instalar librerias necesarias para ejecución de proyecto:

#codigo para instalar virtualenv
```bash
sudo apt-get install python3-venv
```

* Abrir el proyecto desde Visual Studio Code o en una terminal:

```bash
cd ~/Documents/encoders_back2basic
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
```
## Instalar paquete de python interno epipe

```bash
pip install git+<encoders>epipe.git
```


# Entender el proyecto

## Contexto

El repositorio tiene un psudo proyecto de ejemplo para entender como aplicar las metodlogias definidas por la comunidad

El psudo problema a resolver se trata de un problema de clasificación riesgo de fuga de clientes.




## Estructura de Carpetas

El proyecto esta compuesto por las siguientes carpetas:

* files: Contiene los datos del proyecto
* execution: Contiene los scripts de ejecución de la inferencia
* functions: Contiene las funciones utilizada en varios scripts
* insights: Contiene un EDA de los datos
* models: Contiene los modelos entrenados
* pipeline: Contiene los scripts de ejecución del pipeline
* reports: Contiene los reportes de los modelos
* tests: Contiene las unidades de test 
* prepocessing: Contiene los scripts de preprocesamiento de los datos
* etl: Contiene script para la extracción de los datos de fuentes externas, que no estan en el datalake

## Estructura de Archivos


* .Renviron: Contiene las credenciales de acceso al bitbucket
* .env: Contiene las credenciales de acceso al y bitbucket
* .gitignore: Contiene los archivos que no se deben subir al repositorio
* requirements.txt: Contiene las librerias de python necesarias para ejecutar el proyecto
* renv.lock: Contiene las librerias de R necesarias para ejecutar el proyecto
* config.yml: Contiene la configuración de snakemake




# Flujo de Ejecución

## DAG de Tablon Maestro

![DAG de Tablon Maestro](dag_tablon_master.png)

Poner el DAG de Modelamiento

Poner el DAG de Inferencia
 

# Ejecucion del pipeline via Script


* Ejecutar el script de tablon maestro. Genera el tablon maestro para entrenar el modelo y hacer analisis exploratorio de los datos.
```
Rscript pipeline/master_table.R
```

* Ejecutar el script de modelamiento. Genera el modelo y los reportes de performance.
```
Rscript pipeline/model.R
```

* Ejecutar el script de inferencia. Crear el tablon de inferencia y genera el el resultado de inferencia.
```
Rscript pipeline/inference.R
```



# Ejecución del pipeline via Snakemake

Los DataLab vienen con conda y snakemake ya installados.

## Instalar Snakemake

```
conda activate snakemake
snakemake --help
```

## Instalacion de Conda

* Valdiar si tiendes conda instalado (el datalab v2.2 ya viene conda instalado)
```
conda --version
```


* https://docs.conda.io/en/latest/miniconda.html#linux-installers

Revisa que version de python tienes instalada.

```
python --version
```

* python 3.11: https://repo.anaconda.com/miniconda/Miniconda3-py311_23.5.2-0-Linux-x86_64.sh
* python 3.10: https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.2-0-Linux-x86_64.sh
* python 3.9: https://repo.anaconda.com/miniconda/Miniconda3-py39_23.5.2-0-Linux-x86_64.sh
* python 3.8: https://repo.anaconda.com/miniconda/Miniconda3-py38_23.5.2-0-Linux-x86_64.sh


```
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.5.2-0-Linux-x86_64.sh
bash Miniconda3-py39_23.5.2-0-Linux-x86_64.sh
```

* Installar snakemake
```
conda install -n base -c conda-forge mamba
conda activate base
mamba create -c conda-forge -c bioconda -n snakemake snakemake
conda activate snakemake
snakemake --help
```


* Crear archivo .env para guardar el valor de una variable que ayuda a generar archivos unicos por ejecucion.
```
nano .env
```

```
version=<chris>
```



* Activar snakeMake
```
conda activate snakemake
```

* Ejectuar el pipeline tablon maestro. Genera el tablon maestro para entrenar el modelo y hacer analisis exploratorio de los datos.
```
snakemake --cores 1 --use-conda
```

* Ejecutar el pipeline de modelamiento. Genera el modelo y los reportes de performance.
```
snakemake --cores 1 --use-conda -s pipeline/model.snakefile
```

* Ejecutar el pipeline tablon de inferencia. Crear el tablon de inferencia y genera el el resultado de inferencia.
```
snakemake --cores 1 --use-conda -s pipeline/inference.snakefile
```

* Generar los DAG
```
snakemake -c1 -s pipeline/pipe_tablon_master.smk prep_tablon_maestro --forceall --rulegraph | dot -Tpng > dag_tablon_master.png
```


















