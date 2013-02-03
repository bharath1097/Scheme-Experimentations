
make : compile link

compile : infrastructure application

infrastructure : fastcgi jansson validation sql

fastcgi : sources/infrastructure/fastcgi/fastcgi.o

sources/infrastructure/fastcgi/fastcgi.o : sources/infrastructure/fastcgi/fastcgi.c
	csc -c -I/usr/local/include -lfcgi \
	sources/infrastructure/fastcgi/fastcgi.c -o \
	sources/infrastructure/fastcgi/fastcgi.o

jansson : sources/infrastructure/json/jansson-ffi.o \
          sources/infrastructure/json/json.o \
          sources/infrastructure/json/json-format.o \
          sources/infrastructure/json/json-parse.o

sources/infrastructure/json/jansson-ffi.o : sources/infrastructure/json/jansson-ffi.scm
	csc -c -I/usr/local/include \
	sources/infrastructure/json/jansson-ffi.scm -o \
	sources/infrastructure/json/jansson-ffi.o

sources/infrastructure/json/json.o : sources/infrastructure/json/json.scm
	csc -c \
	sources/infrastructure/json/json.scm -o \
	sources/infrastructure/json/json.o

sources/infrastructure/json/json-format.o : sources/infrastructure/json/json-format.scm
	csc -c \
	sources/infrastructure/json/json-format.scm -o \
	sources/infrastructure/json/json-format.o

sources/infrastructure/json/json-parse.o : sources/infrastructure/json/json-parse.scm
	csc -c \
	sources/infrastructure/json/json-parse.scm -o \
	sources/infrastructure/json/json-parse.o

validation : sources/infrastructure/validation/validation.o

sources/infrastructure/validation/validation.o : sources/infrastructure/validation/validation.scm
	csc -c \
	sources/infrastructure/validation/validation.scm -o \
	sources/infrastructure/validation/validation.o

sql : sources/infrastructure/sql/sqlite-ffi.o \
      sources/infrastructure/sql/sql-intern.o \
      sources/infrastructure/sql/sql.o

sources/infrastructure/sql/sqlite-ffi.o : sources/infrastructure/sql/sqlite-ffi.scm
	csc -c -I/usr/local/include \
	sources/infrastructure/sql/sqlite-ffi.scm -o \
	sources/infrastructure/sql/sqlite-ffi.o

sources/infrastructure/sql/sql-intern.o : sources/infrastructure/sql/sql-intern.scm
	csc -c \
	sources/infrastructure/sql/sql-intern.scm -o \
	sources/infrastructure/sql/sql-intern.o

sources/infrastructure/sql/sql.o : sources/infrastructure/sql/sql.scm
	csc -c \
	sources/infrastructure/sql/sql.scm -o \
	sources/infrastructure/sql/sql.o

application : services tables

services : sources/application/services/new-customer-service.o

sources/application/services/new-customer-service.o : sources/application/services/new-customer-service.scm
	csc -c \
	sources/application/services/new-customer-service.scm -o \
	sources/application/services/new-customer-service.o

tables : sources/application/tables/customer-addresses-table.o \
         sources/application/tables/customers-table.o

sources/application/tables/customer-addresses-table.o : sources/application/tables/customer-addresses-table.scm
	csc -c \
	sources/application/tables/customer-addresses-table.scm -o \
	sources/application/tables/customer-addresses-table.o

sources/application/tables/customers-table.o : sources/application/tables/customers-table.scm
	csc -c \
	sources/application/tables/customers-table.scm -o \
	sources/application/tables/customers-table.o

link : compile
	csc \
	-lfcgi \
	-ljansson \
	-lsqlite3 \
	sources/infrastructure/fastcgi/fastcgi.o \
	sources/infrastructure/json/jansson-ffi.o \
	sources/infrastructure/json/json.o \
	sources/infrastructure/json/json-format.o \
	sources/infrastructure/json/json-parse.o \
	sources/infrastructure/sql/sqlite-ffi.o \
	sources/infrastructure/sql/sql-intern.o \
	sources/infrastructure/sql/sql.o \
	sources/infrastructure/validation/validation.o \
	sources/application/services/new-customer-service.o \
	sources/application/tables/customer-addresses-table.o \
	sources/application/tables/customers-table.o \
	-o scheme

install :
	cp scheme /usr/local/apache2/fcgi-bin/
