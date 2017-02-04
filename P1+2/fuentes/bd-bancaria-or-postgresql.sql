DROP TABLE poseer;
DROP TYPE poseer_udt;
DROP TABLE operacion;
DROP SEQUENCE operacion_seq;
DROP TYPE operacion_udt;
DROP TABLE cuenta;
DROP TYPE cuenta_udt;
DROP TABLE oficina;
DROP TYPE oficina_udt;
DROP TABLE cliente;
DROP TYPE cliente_udt;



CREATE TYPE cliente_udt AS(
	dni decimal(8),
	nombre varchar(30),
	apellidos varchar(60),
	direccion varchar(60),
	email varchar(80),
	telefono decimal(9),
	fechNacimiento date);

CREATE TABLE cliente OF cliente_udt(
    CONSTRAINT pk_cliente PRIMARY KEY(dni),
	CONSTRAINT nombre_check CHECK(nombre IS NOT NULL),
	CONSTRAINT apellidos_check CHECK(apellidos IS NOT NULL),
	CONSTRAINT direccion_check CHECK(direccion IS NOT NULL),
	CONSTRAINT telefono_check CHECK(telefono IS NOT NULL),
	CONSTRAINT fechNacimiento_check CHECK(fechNacimiento IS NOT 		NULL));


CREATE TYPE oficina_udt AS(
    codigo decimal(4),
    direccion varchar(80),
    telefono decimal(9));

CREATE TABLE oficina OF oficina_udt(
    CONSTRAINT pk_oficina PRIMARY KEY(codigo),
	CONSTRAINT direccionOf_check CHECK(direccion IS NOT NULL),
	CONSTRAINT telefonoOf_check CHECK(telefono IS NOT NULL));


CREATE TYPE cuenta_udt AS(
    nCuenta decimal(20),
    fecha date,
    saldo real,
    tipo decimal(1),
	interes decimal(3,3),
	codigo decimal(4));

CREATE TABLE cuenta OF cuenta_udt(
    CONSTRAINT pk_cuenta PRIMARY KEY(nCuenta),
	CONSTRAINT fk_cc_oficina FOREIGN KEY (codigo) REFERENCES oficina(codigo),
	CONSTRAINT fechCuenta_check CHECK(fecha IS NOT NULL),
	CONSTRAINT interes_check CHECK(interes IS NULL OR interes>0 AND interes <=100),
	CONSTRAINT tipoCuenta_check CHECK(tipo IS NOT NULL AND ((tipo=0 AND codigo IS NOT NULL AND interes IS NULL) OR (tipo=1 AND interes IS NOT NULL AND codigo IS NULL))));

ALTER TABLE cuenta
ALTER COLUMN fecha SET DEFAULT CURRENT_DATE,
ALTER COLUMN saldo SET DEFAULT 0;


CREATE TYPE operacion_udt AS(
	nCuenta_origen decimal(20),
	num_operacion decimal(6),
	fecha date,
	descripcion varchar(250),
	cantidad real,
	tipo decimal(1),
	nCuenta_dst decimal(20),
	codigo decimal(4));

CREATE TABLE operacion OF operacion_udt(
	CONSTRAINT pk_operacion PRIMARY KEY(nCuenta_origen, num_operacion),
	CONSTRAINT fk_nCuenta_origen FOREIGN KEY(nCuenta_origen) REFERENCES cuenta(nCuenta),
	CONSTRAINT fk_codigo_op FOREIGN KEY(codigo) REFERENCES oficina(codigo),
	CONSTRAINT fk_nCuenta_dst FOREIGN KEY(nCuenta_dst) REFERENCES cuenta(nCuenta),
	CONSTRAINT fecha_op_check CHECK(fecha IS NOT NULL),
	CONSTRAINT cantidad_check CHECK(cantidad IS NOT NULL AND cantidad>0),
	CONSTRAINT tipo_op_check CHECK(tipo IS NOT NULL AND ((tipo=0 AND codigo IS NOT NULL AND nCuenta_dst IS NULL) OR (tipo=1 AND nCuenta_dst IS NOT NULL AND codigo IS NULL))));

CREATE SEQUENCE operacion_seq;

ALTER TABLE operacion
ALTER COLUMN fecha SET DEFAULT CURRENT_DATE,
ALTER COLUMN num_operacion SET DEFAULT NEXTVAL('operacion_seq');


CREATE TYPE poseer_udt AS(
	cliente decimal(8),
	nCuenta decimal(20));

CREATE TABLE poseer OF poseer_udt(
	CONSTRAINT pk_poseer PRIMARY KEY(cliente,nCuenta),
	CONSTRAINT fk_cliente_poseer FOREIGN KEY(cliente) REFERENCES cliente(dni),
	CONSTRAINT fk_cuenta_poseer FOREIGN KEY(nCuenta) REFERENCES cuenta(nCuenta));



