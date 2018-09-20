---
layout: default
title: Docker para ambientes PHP
date: 2018-09-18 09:48:09
style: /assets/vendor/css/pygments-css/native.css

---
# Docker para ambientes PHP

Eu venho usando Vagrant há algum tempo para criar ambientes de desenvolvimento isolados em máquinas locais. Basicamente o que Vagrant faz é gerenciar máquinas virtuais permitindo a definição de configurações para cada uma dessas máquinas de forma bem simples.
O motivo principal que me levou a usar a Vagrant, foi a possibilidade de isolar as configurações não só de sofware, mas também as de hardware em cada ambiente criado.
O problema identificado logo de cara, foi a falta de recursos existentes na máquina local para servir a cada máquina virtual dessas criadas, pois cada máquina criada é uma instalação completa de um sistema operacional, com suas necessidades de espaço em disco, memória etc. Com isso, geralmente o que eu fazia era usar uma máquina por vez, economizando recursos da máquina hospedeira, entretanto, o tempo, por exemplo, para iniciação e desligamento de cada máquina já era uma coisa chata, o que acabava me levando a juntar várias aplicações em uma mesma máquina, virando meio que um “sururu”.

A primeira vez que ouvi falar em Docker, achei a coisa tão “complicada” (leia preguiça de encarar mudanças), que fui empurrando com a barriga até os dias atuais e após encarar a verdade e tentar entender melhor o que é conteinerização, descobri que de fato o medo de mudanças deve ser encarado com mais coragem.

Basicamente, o que Docker me oferece hoje é a criação de serviços isolados com a possibilidade de relacionamento entre os mesmos. Vamos a um exemplo prático do dia a dia:

Uma aplicação básica criada em PHP, necessita de no mínimo três serviços distintos, um servidor web, um interpretador PHP e um servidor de banco de dados, por exemplo Nginx, PHP-FPM e MySQL. Normalmente, o que eu vinha fazendo era instalar o Nginx e o PHP-FPM em uma máquina com Vagrant e tinha uma segunda máquina com todos os bancos de dados servindo para outras aplicações.
Com Docker, eu tenho um serviço em cada container, sendo o relacionamento desses serviços muito mais fácil de configurar e mantendo isolado um conjunto de serviços para cada aplicação.

Você pode estar se perguntando, mas antes ele criava duas máquinas para uma aplicação, agora ele criará três?
Negativo. A diferença entre um container e uma máquina, é que o container usa apenas recursos básicos necessários para tal serviço funcionar, fazendo uso de recursos nativos do kernel do linux.

Mãos a obra!

Eu uso Ubuntu e instalei Docker seguindo esta [documentação](https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository){:target="_blank"}

Eu vou usar neste post o [Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-14-04#step-2-—-installing-docker-compose){:target="_blank"}, que é uma ferramenta que minimiza bastante o trabalho

Se você não usa Linux, nem tudo está perdido, existe http://boot2docker.io/, que poderá lhe ajudar com a execução de Docker.

No [https://hub.docker.com/](https://hub.docker.com/){:target="_blank"}, encontramos diversas imagens já construídas que atendem inúmeras necessidades, incluindo imagens oficias como Apache, PHP, Nginx, MySQL dentre várias, contudo, acredito ser uma boa hora pra colocarmos em prática a possibilidade de construirmos a nossa própria imagem.

Crie um diretório e um subdiretório imagens/nginx, com dois arquivos: Dockerfile e start.sh

![My helpful screenshot](/assets/images/posts/2016-09-10-docker-para-ambientes-php.png){:class="img-fluid"}

No arquivo Dockerfile, vamos inserir o seguinte conteúdo:

```dockerfile

  FROM phusion/baseimage  
  MAINTAINER SEU NOME  
  CMD [“/sbin/my_init”]  
  RUN apt-get update && apt-get install -y python-software-properties  
  RUN add-apt-repository ppa:nginx/stable  
  RUN apt-get update && apt-get install -y nginx  
  RUN echo “daemon off;” >> /etc/nginx/nginx.conf  
  RUN ln -sf /dev/stdout /var/log/nginx/access.log  
  RUN ln -sf /dev/stderr /var/log/nginx/error.log  
  RUN mkdir -p /etc/service/nginx  
  ADD start.sh /etc/service/nginx/run  
  RUN chmod +x /etc/service/nginx/run  
  EXPOSE 80  
  RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  
```

Dockerfile é o arquivo que registra todos os comandos que serão usados para a criação de uma imagem Docker, sugiro que você dê uma olhada em sua [documentação](https://docs.docker.com/engine/reference/builder/){:target="_blank"}
Vamos dar uma olhada no que cada comando faz, linha por linha:

Linha 1 – O comando FROM especifica o nome da imagem que será usada como imagem mãe da imagem que estamos criando. No nosso caso estamos usando a phufion/baseimage, que é uma imagem com Ubuntu(atualmente 16.04) com algumas ferramentas que simplificam a criação de container Docker.

Linha 2 – MAINTAINER é um comando que você usará para registrar seu nome e e-mail que serão vistos por outros desenvolvedores caso você compartilhe sua imagem em [https://hub.docker.com/](https://hub.docker.com/){:target="_blank"}

Linha 3 – CMD Responsável por executar um comando embutido na imagem, nessa caso, ele executará /sbin/my_init, existente em phusion/baseimage

Linhas 4, 5 e 6 – Usa o comando RUM para instalar a ultima versão do Nginx

Linhas 7, 8 e 9 – Usar novamente o comando RUM para escrever no arquivo de configuração do Nginx e criar links simbólicos dos arquivos de logs.

Linhas 10, 11 e 12 – Copia o arquivo start.sh para o container, esse este é chamado por padrão pela imagem phusion/baseimage e, neste caso criamos um script para iniciar o Nginx.

Linha 13 – EXPOSE diz para o Docker as portas que devem ser escutadas em tempo de execução.

Linha 14 – Executa uma limpeza básica no apt e nos diretórios temporários.

Agora vamos inserir o conteúdo do arquivo start.sh

```bash
  #!/usr/bin/env bash
  service nginx start
```

Um script básico para executar o comando de iniciação do Nginx
Agora navegue até o diretório imagens/nginx e vamos executar o seguinte comando para a construção de nossa primeira imagem:

docker build -t tutorial/nginx .

Após diversas linhas geradas, o final deverá ser algo parecido com isso:

```bash

    Processing triggers for systemd (229-4ubuntu6) ...
    ---> 9f1eb5866cca
    Removing intermediate container b07bc3d4fbf4
    Step 7 : RUN echo "daemon off;" >> /etc/nginx/nginx.conf
    ---> Running in 2e9e17465bee
    ---> 67e12eae61e0
    Removing intermediate container 2e9e17465bee
    Step 8 : RUN ln -sf /dev/stdout /var/log/nginx/access.log
    ---> Running in f1bfef1165c2
    ---> 0f35d25f041e
    Removing intermediate container f1bfef1165c2
    Step 9 : RUN ln -sf /dev/stderr /var/log/nginx/error.log
    ---> Running in dc6afee21aa7
    ---> fdbc66f4fc29
    Removing intermediate container dc6afee21aa7
    Step 10 : RUN mkdir -p /etc/service/nginx
    ---> Running in f082de625414
    ---> da674bf1aa6e
    Removing intermediate container f082de625414
    Step 11 : ADD start.sh /etc/service/nginx/run
    ---> 46482f2f0b3e
    Removing intermediate container 5c187a026a07
    Step 12 : RUN chmod +x /etc/service/nginx/run
    ---> Running in acdbb294f40a
    ---> 8fb8863aa4db
    Removing intermediate container acdbb294f40a
    Step 13 : EXPOSE 80
    ---> Running in 8abae36fc844
    ---> e343f9262260
    Removing intermediate container 8abae36fc844
    Step 14 : RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    ---> Running in 154222c19d04
    ---> 599ea8dfdce7
    Removing intermediate container 154222c19d04
    Successfully built 599ea8dfdce7
```

Mas não se prenda a isso, docker nos fornece comandos para listar imagens e containers. Você deve ter observado que ao construir sua imagem, ele fez download não só da imagem base que usamos, mas também de qualquer dependência que esta imagem tenha.

Agora vamos ter a certeza de que temos as imagens necessárias, a serem criada por nós e phusion/baseimage

Execute para isso docker images

```bash

    jackson@jackson:~/docker_exemplo/imagens/nginx$ docker images
    REPOSITORY TAG IMAGE ID CREATED SIZE
    exemplo/nginx latest 599ea8dfdce7 10 minutes ago 344.8 MB
    phusion/baseimage latest c39664f3d4e5 9 weeks ago 225.6 MB

```

Parabéns, conseguimos criar nossa primeira imagem Docker, mas vamos lembrar que o que temos é apenas uma imagem, e nos será útil somente quando instanciarmos containers usando-as.

Antes de criar qualquer container, vamos baixar as imagens necessárias para a criação do ambiente proposto. A criação da Imagem exemplo/nginx, foi apenas para termos conhecimento da possibilidade da criação de imagens personalizadas, agora vamos baixar imagens já prontas e oficiais para mysql e para PHP-FPM, para isso, [Docker Hub](https://hub.docker.com/){:target="_blank"} é meu pastor e nada me faltará.

Vamos começar então por baixar o PHP-FPM

```bash

    jackson@jackson:~/docker_exemplo/imagens/nginx$ docker pull php:7.0-fpm
    7.0-fpm: Pulling from library/php

    8ad8b3f87b37: Already exists
    161c326a7a2d: Already exists
    4f37fe44e518: Already exists
    60f9ad70a554: Pull complete
    bd8ea9a43d6c: Pull complete
    111e9423ead8: Pull complete
    0bd11255d66a: Pull complete
    b207707c9544: Pull complete
    ef71188aa925: Pull complete
    Digest: sha256:f9147faf2ab25469f485ab70038aff0480f619d8ce53e0fe94a6606b86313794
    Status: Downloaded newer image for php:7.0-fpm
```

Você pode escolher entre as versões do PHP disponíveis em [https://hub.docker.com/\_/php/](https://hub.docker.com/\_/php/){:target="_blank"}

Agora vamos baixar a imagem do Mysql, eu estou optando pela versão 5.6, as versão podem ser consultadas em [https://hub.docker.com/\_/mysql/](https://hub.docker.com/\_/mysql/){:taget="_blank"}

```bash

    jackson@jackson:~/docker_exemplo/imagens/nginx$ docker pull mysql:5.6
    5.6: Pulling from library/mysql

    8ad8b3f87b37: Already exists
    9a2674eb51d8: Already exists
    b839515314a7: Already exists
    0b8e3100ab50: Already exists
    c9a6e2414f0a: Pull complete
    62605666ff10: Pull complete
    eef7cf502115: Pull complete
    2b84c0dd4ca9: Pull complete
    2668cb19e693: Pull complete
    c1ffa5c73c3b: Pull complete
    7b408f8be82c: Pull complete
    Digest: sha256:31ad2efd094a1336ef1f8efaf40b88a5019778e7d9b8a8579a4f95a6be88eaba
    Status: Downloaded newer image for mysql:5.6
```

Agora se executarmos docker images, veremos mais duas imagens na lista

```bash

    jackson@jackson:~/docker_exemplo/imagens/nginx$ docker images
    REPOSITORY TAG IMAGE ID CREATED SIZE
    exemplo/nginx latest 599ea8dfdce7 50 minutes ago 344.8 MB
    mysql 5.6 72bb9d97fb75 2 days ago 328.9 MB
    php 7.0-fpm 6a7d2279aafa 10 days ago 375.5 MB
    phusion/baseimage latest c39664f3d4e5 9 weeks ago 225.6 MB
```

Temos todas as imagens necessárias para a execução de nossa aplicação, agora vamos criar a estrutura para os arquivos da mesma.

Crie a estrutura de arquivos na raiz do diretório criado anteriormente, como na imagem:

![My helpful screenshot](/assets/images/posts/2016-09-10-docker-para-ambientes-php-2.png){:class="img-fluid"}

O diretório src, será onde colocaremos qualquer configuração para o ambiente no futuro e src/www/public onde ficarão os arquivos da aplicação.

No arquivo index.html, eu inseri o seguinte conteúdo:

```html

  <!DOCTYPE html>
  <html>
      <head>
          <title>Meu primeiro ambiente usando Docker</title>
      </head>
      <body>
          <h1>Meu primeiro ambiente usando Docker</h1>
      </body>
  </html>

```

Vamos disponibilizar nossa aplicação sob o domínio docker-exemplo.local, que vamos registrar em nossa máquina. Se você usa linux, aponte-o em seu /etc/hosts para o seu próprio IP.
Algo como:
192.168.0.11 docker-exemplo.local

Vamos criar um arquivo vhost para o Nginx responder para o domínio que escolhemos.

```apache

  server {
      listen 80;
      index index.html;
      server_name docker-exemplo.local;
      error_log /var/log/nginx/error.log;
      access_log /var/log/nginx/access.log;
      root /var/www/public;
  }
```

Eu não vou entrar no mérito da configuração do Nginx, mas tenha atenção na linha root /var/www/public. Aqui é preciso ter atenção, porque precisaremos mapear o diretório da máquina hospedeira para o container.

Agora vamos de fato criar o container usando a imagem Nginx que criamos. (exemplo/nginx).

Tenha a certeza de que está na raiz do projeto, e execute o seguinte código:

```default

  docker run \
  -d \
  -p 8080:80 \
  -v $(pwd)/src/vhost.conf:/etc/nginx/sites-enabled/vhost.conf \
  -v $(pwd)/src/www:/var/www \
  exemplo/nginx;
```

```bash

  jackson@jackson:~/docker_exemplo$ docker run \
  > -d \
  > -p 8080:80 \
  > -v $(pwd)/src/vhost.conf:/etc/nginx/sites-enabled/vhost.conf \
  > -v $(pwd)/src/www:/var/www \
  > exemplo/nginx;
  d50cb5c634a25804a4ad28f304e0bb0cdc143a576af2733a95879c8ba3de0b10

```

Usamos a flag -d para que tudo seja executado em background.

Usamos a flag -p para mapear uma porta da máquina hospedeira para o container. Neste caso dizemos para o que entrar pela 8080 seja direcionado para a porta 80 do container. Se você olhar mais acima, verá que configuramos o container para escutar a porta 80.

Usamo a flag -v para mapear nosso arquivo vhost do nginx local com o seu local necessário no container. E mais uma vez usamos a flag -v para mapear o nosso diretório local com o container, de forma que fique disponível como configurado no vhost em root /var/www/public.

Após todos os argumentos passados para o método run, informamos finalmente o nome da imagem que deve ser usada para a criação do container, no nosso caso exemplo/nginx.



Você pode ter certeza de que o Nginx está funcionando corretamente executando docker logs [ID DO CONTAINER]. Para obter o id do container lembre-se de docker ps.

```bash

    jackson@jackson:~/docker_exemplo$ docker ps
    CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
    d50cb5c634a2 exemplo/nginx "/sbin/my_init" 42 seconds ago Up 40 seconds 0.0.0.0:8080-&gt;80/tcp naughty_booth
    jackson@jackson:~/docker_exemplo$ docker logs d50cb5c634a2
    *** Running /etc/my_init.d/00_regen_ssh_host_keys.sh...
    *** Running /etc/rc.local...
    *** Booting runit daemon...
    *** Runit started as PID 9
    * Starting nginx nginx
    Sep 10 02:40:20 d50cb5c634a2 syslog-ng[17]: syslog-ng starting up; version='3.5.6'

```

Agora é a hora da verdade, acesse o endereço http://docker-exemplo.local:8080/

![My helpful screenshot](/assets/images/posts/2016-09-10-docker-para-ambientes-php.png){:class="img-fluid"}

Pimba!

## Docker Compose

Acredito que assim que você tenha visto as mais de cinco linhas para executar a criação do container, tenha pensado já na criação de arquivos .sh para centralizar isso. Esqueça. O [Docker Compose](https://docs.docker.com/compose/){:target="_blank"} fará todo esse trabalho para você.

Se você não pulou, provavelmente já instalou o docker compose, caso não o tenha feito, [faça agora](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-14-04#step-2-%E2%80%94-installing-docker-compose){:target="_blank"}.

Basicamente, o que vamos fazer daqui pra frente será registrar os comandos necessários em um arquivo [YAML](http://yaml.org/){:target="_blank"}.

Crie um arquivo docker-compose.yml na raiz de seu projeto
![My helpful screenshot](/assets/images/posts/2016-09-10-docker-para-ambientes-php-4.png){:class="img-fluid"}

Vamos parar o container e excluí-lo:

Use docker ps para pegar o id do container

e:

docker stop [ID DO CONTAINER]

docker rm [ID DO CONTAINER]

```bash

  jackson@jackson:~/docker_exemplo$ docker ps
  CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
  60b5573311c5 exemplo/nginx "/sbin/my_init" 7 minutes ago Up 7 minutes 0.0.0.0:8080-&gt;80/tcp jolly_shannon
  jackson@jackson:~/docker_exemplo$ docker stop 60b5573311c5
  60b5573311c5
  jackson@jackson:~/docker_exemplo$ docker rm 60b5573311c5
  60b5573311c5
  jackson@jackson:~/docker_exemplo$

```

Coloque o seguinte conteúdo no arquivo docker-compose.yml

```bash

  web:
  image: exemplo/nginx
  ports:
  - "8080:80"
  volumes:
  - ./src/www:/var/www
  - ./src/vhost.conf:/etc/nginx/sites-enabled/vhost.conf
```

  Agora execute docker-compose up -d

```bash

  jackson@jackson:~/docker_exemplo$ docker-compose up -d
  Creating dockerexemplo_web_1
```

Acesse o endereço http://docker-exemplo.local:8080/, acabamos com a problemática da quantidade de código toda vez que tive que iniciar um container.

## O Container Docker PHP-FPM

Vamos preparar agora o nosso container PHP-FPM, e para isso vamos inserir mais um bloco em nosso arquivo docker-composer.yml

php:
image: “php:7.0-fpm”
volumes:
– ./src/php-fpm.conf:/etc/php5/fpm/php-fpm.conf
– ./src/www:/var/www
working_dir: “/var/www/”

Além da inserção deste bloco, temos que dizer ao container do nginx (no bloco web), para conectar-se ao php, inserindo:

links:
– php

o Arquivo ficará assim:

```bash

  web:
  image: exemplo/nginx
  ports:
  - "8080:80"
  volumes:
  - ./src/www:/var/www
  - ./src/vhost.conf:/etc/nginx/sites-enabled/vhost.conf
  links:
  - php

  php:
  image: "php:7.0-fpm"
  volumes:
  - ./src/php-fpm.conf:/etc/php5/fpm/php-fpm.conf
  - ./src/www:/var/www
  working_dir: "/var/www/"
  Precisamos alterar o arquivo vhost.conf do nginx para que ele funcione com o PHP.
```

Deixe-o assim:

```bash
  server {
    listen 80;
    index index.php index.html;
    server_name docker-exemplo.local;
    error_log /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/public;

    location / {
      try_files $uri /index.php?$args;
    }

    location ~ \.php$ {
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      fastcgi_pass php:9000;
      fastcgi_index index.php;
      include fastcgi_params;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_param PATH_INFO $fastcgi_path_info;
    }
  }
```

agora você pode baixar este arquivo de exemplo de configuração do PHP-FPM e colocá-lo ao lado do aquivo vhost.conf em src.

Crie um arquivo em src/www/public nomeado de index.php e coloque o segundo conteúdo:

```php
  <?php
    phpinfo();
  ?>
```

Acesse o endereço http://docker-exemplo.local:8080/
![My helpful screenshot](/assets/images/posts/2016-09-10-docker-para-ambientes-php-5.png){:class="img-fluid"}

Pronto, agora nosso ambiente funciona corretamente com o PHP

## O Container Docker MySQL

Para completar o nosso ambiente, vamos criar agora um container para o MySQL inserindo o seguinte bloco no docker-compose.yml:

db:
image: “mysql:5.6”
volumes:
– /var/lib/mysql
environment:
– MYSQL_ROOT_PASSWORD=exemploUser
– MYSQL_DATABASE=exemploDb
– MYSQL_USER=exemploUser
– MYSQL_PASSWORD=exemploSenha

As variáveis de ambiente definidas em environment são fornecidas pela própria imagem. Você pode pesquisar as possibilidade sempre na página da imagem do Docker Hub, neste caso usamos a imagem oficial do MySQL.

Só que agora temos que ter uma atenção especial. Vamos precisar instalar duas extensões em nossa imagem usada para o PHP, então vamos excluir todas as imagens criadas, assim como todos os containers, para isso execute:

docker rm $(docker ps -a -q)

e:

docker rmi $(docker images -q)

Pra ser sincero à você, acredito ser possível instalar a extensão apenas no container, mas por hora, vamos fazer da forma que tenhamos a certeza do sucesso.

Para instalar as extensões pdo e pdo_mysql no container do php, a imagem oficial do PHP fornece o script docker-php-ext-install que deve ser usado em um arquivo Dockerfile e para isso vamos ter que fazer uma modificação na forma de criação do container do PHP.

No diretório src, crie um diretório nomeado de php e dentro dele um arquivo nomeado de Dockerfile com o seguinte conteúdo:

FROM php:7.0-fpm
RUN docker-php-ext-install pdo pdo_mysql

A estrutura final dos diretórios ficará assim:
![My helpful screenshot](/assets/images/posts/2016-09-10-docker-para-ambientes-php-6.png){:class="img-fluid"}

Agora temos que alterar no bloco php do arquivo docker-compose.yml o atributo que indica ao Docker para usar uma imagem, ao invés disso, vamos dizer a ele para construir um container com base no arquivo Dockerfile criado. Aproveitaremos também para inserir no bloco php um índice links como fizemos entre o Nginx e o php, vamos fazer entre o PHP e o MySQL

Agora o bloco PHP em docker-compose ficará assim:

php:
build: ./src/php
volumes:
– ./src/php-fpm.conf:/etc/php5/fpm/php-fpm.conf
– ./src/www:/var/www
working_dir: “/var/www/”
links:
– db

veja que a segunda linha do arquivo foi alterada para build: ./src/php

O estado final do arquivo docker-compose.yml ficará assim:

```bash
  web:
  image: exemplo/nginx
  ports:
  - "8080:80"
  volumes:
  - ./src/www:/var/www
  - ./src/vhost.conf:/etc/nginx/sites-enabled/vhost.conf
  links:
  - php

  php:
  build: ./src/php
  volumes:
  - ./src/php-fpm.conf:/etc/php5/fpm/php-fpm.conf
  - ./src/www:/var/www
  working_dir: "/var/www/"
  links:
  - db

  db:
  image: "mysql:5.6"
  volumes:
  - /var/lib/mysql
  environment:
  - MYSQL_ROOT_PASSWORD=exemploUser
  - MYSQL_DATABASE=exemploDb
  - MYSQL_USER=exemploUser
  - MYSQL_PASSWORD=exemploSenha
```

Execute novamente o comando docker-compose up -d

Para termos a certeza do funcionamento do PHP com o MySQL, vamos inserir um código básico de conexão com o banco de dados, que foi criado junto com o container, inserir dados e listá-los.
Deixe o arquivo index.php localizado em src/www/public com o seguinte conteúdo:

```php

  <?php
    $tabela = "mensagens";
    try {
      $db = new PDO("mysql:dbname=exemploDb;host=db", "exemploUser", "exemploSenha" );
      $db->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
      $sql="CREATE TABLE IF NOT EXISTS mensagens (
        id int(20) NOT NULL AUTO_INCREMENT,
        mensagem varchar(150) NOT NULL,
        PRIMARY KEY (id),
        UNIQUE KEY id (id)
      );";
      $data = date("Y-m-d H:i:s");
      $sql = "INSERT INTO mensagens (mensagem)
      VALUES (:mensagem)";
      $stmt = $db->prepare($sql);
      $data = array(
        ':mensagem' => "Mensagem inserida em {$data}",
      );
      $stmt->execute($data);
      $consulta = $db->query("SELECT mensagem FROM mensagens;");
      while ($linha = $consulta->fetch(PDO::FETCH_ASSOC)) {
        echo $linha['mensagem']."
        ";
      }
    } catch(PDOException $e) {
      echo $e->getMessage();
    }
  ?>
```

Acesse o endereço http://docker-exemplo.local:8080/ e boa sorte.

Considerações finais
Tenha bastante cautela com os dados, eu não estudei muito bem sobre o assunto, mas todos ressaltam a preocupação necessária com onde esses dados ficarão. Atualmente tenho montado o diretório /var/lib/mysql na minha máquina, algo como . /src/mysql/data:/var/lib/mysql

É possível fazer o mesmo com os diretórios de armazenamento dos logs e etc.