CREATE TABLE empleado(
	dni decimal(8),
	nombre varchar(30) NOT NULL,
	apellidos varchar(60) NOT NULL,
	direccion varchar(80) NOT NULL,
	telefono decimal(9) NOT NULL,
	poblacion varchar(40) NOT NULl,
	CONSTRAINT pk_empleado PRIMARY KEY(dni)
);

CREATE TABLE camion(
	matricula varchar(7),
	tipo varchar(80) NOT NULL,
	modelo varchar(9) NOT NULL,
	CONSTRAINT pk_camion PRIMARY KEY(matricula)
);

CREATE TABLE pedido(
	codigo decimal(8),
	origen varchar(20) NOT NULL,
	descripcion varchar(50) NOT NULL,
	destinatario varchar(30) NOT NULL,
	direccion varchar(50) DEFAULT NULL,	
	CONSTRAINT pk_pedido PRIMARY KEY(codigo)
);

CREATE TABLE provincia(
	codigoProvincia decimal(8),	
	nombre varchar(50), 	
	CONSTRAINT pk_codigoProvincia PRIMARY KEY(codigoProvincia)
);

CREATE TABLE conduce(
	dni decimal(8),
	matricula varchar(7),
	CONSTRAINT pk_conducir PRIMARY KEY(dni, matricula),
	CONSTRAINT fk_empleado FOREIGN KEY (dni) REFERENCES empleado(dni),
	CONSTRAINT fk_camion FOREIGN KEY (matricula) REFERENCES camion(matricula)
);

CREATE TABLE transporta(
	dni decimal(8),
	codigo decimal(8),
	CONSTRAINT pk_transporta PRIMARY KEY(dni, codigo),
	CONSTRAINT fk_empleado FOREIGN KEY (dni) REFERENCES empleado(dni),
	CONSTRAINT fk_pedido FOREIGN KEY (codigo) REFERENCES pedido(codigo)
);


CREATE TABLE destinado(	
	codigo decimal(8),
	codigoProvincia decimal(4),
	CONSTRAINT pk_destinado PRIMARY KEY(codigo, codigoProvincia),
	CONSTRAINT fk_pedido FOREIGN KEY (codigo) REFERENCES pedido(codigo),
	CONSTRAINT fk_provincia FOREIGN KEY (codigoProvincia) REFERENCES provincia(codigoProvincia)
	
);



