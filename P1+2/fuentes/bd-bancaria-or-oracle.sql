DROP TABLE poseer;
DROP TRIGGER operacion_autoseq; 
DROP SEQUENCE operacion_seq; 
DROP TABLE operacion;
DROP TABLE cuenta;
DROP TABLE oficina;
DROP TABLE cliente;


CREATE OR REPLACE TYPE cliente_udt AS OBJECT(
    dni number(8),
    nombre varchar(30),
    apellidos varchar(60),
    direccion varchar(80),
    email varchar(80),
    telefono number(9),
    fechNacimiento date);

CREATE TABLE cliente OF cliente_udt(
    CONSTRAINT pk_cliente PRIMARY KEY(dni),
	CONSTRAINT nombre_check CHECK(nombre IS NOT NULL),
	CONSTRAINT apellidos_check CHECK(apellidos IS NOT NULL),
	CONSTRAINT direccion_check CHECK(direccion IS NOT NULL),
	CONSTRAINT telefono_check CHECK(telefono IS NOT NULL),
	CONSTRAINT fechNacimiento_check CHECK(fechNacimiento IS NOT 		NULL));


CREATE OR REPLACE TYPE oficina_udt AS OBJECT(
    codigo number(4),
    direccion varchar(80),
    telefono number(9));

CREATE TABLE oficina OF oficina_udt(
    CONSTRAINT pk_oficina PRIMARY KEY(codigo),
	CONSTRAINT direccionOf_check CHECK(direccion IS NOT NULL),
	CONSTRAINT telefonoOf_check CHECK(telefono IS NOT NULL));


CREATE OR REPLACE TYPE cuenta_udt AS OBJECT(
    nCuenta number(20),
    fecha date,
    saldo real,
    tipo number(1),
	interes number(3,3),
	codigo number(4));

CREATE TABLE cuenta OF cuenta_udt(
    CONSTRAINT pk_cuenta PRIMARY KEY(nCuenta),
	saldo DEFAULT 0,
	fecha DEFAULT SYSDATE,
	CONSTRAINT fk_cc_oficina FOREIGN KEY (codigo) REFERENCES oficina(codigo),
	CONSTRAINT fechCuenta_check CHECK(fecha IS NOT NULL),
	CONSTRAINT interes_check CHECK(interes IS NULL OR interes>0 OR interes <=100),
	CONSTRAINT tipoCuenta_check CHECK(tipo IS NOT NULL AND ((tipo=0 AND codigo IS NOT NULL AND interes IS NULL) OR (tipo=1 AND interes IS NOT NULL AND codigo IS NULL))));


CREATE OR REPLACE TYPE operacion_udt AS OBJECT(
	nCuenta_origen number(20),
	num_operacion number(6),
	fecha date,
	descripcion varchar(250),
	cantidad real,
	tipo number(1),
	nCuenta_dst number(20),
	codigo number(4));

CREATE TABLE operacion OF operacion_udt(
	CONSTRAINT pk_operacion PRIMARY KEY(nCuenta_origen, num_operacion),
	CONSTRAINT fk_nCuenta_origen FOREIGN KEY(nCuenta_origen) REFERENCES cuenta(nCuenta),
	CONSTRAINT fk_codigo_op FOREIGN KEY(codigo) REFERENCES oficina(codigo),
	CONSTRAINT fk_nCuenta_dst FOREIGN KEY(nCuenta_dst) REFERENCES cuenta(nCuenta),
	fecha DEFAULT SYSDATE,
	CONSTRAINT fecha_op_check CHECK(fecha IS NOT NULL),
	CONSTRAINT cantidad_check CHECK(cantidad IS NOT NULL AND cantidad>0),
	CONSTRAINT tipo_op_check CHECK(tipo IS NOT NULL AND ((tipo=0 AND codigo IS NOT NULL AND nCuenta_dst IS NULL) OR (tipo=1 AND nCuenta_dst IS NOT NULL AND codigo IS NULL))));

CREATE SEQUENCE operacion_seq START WITH 1 INCREMENT BY 1 NOMAXVALUE;

CREATE TRIGGER operacion_autoseq 
	BEFORE INSERT ON operacion 
	FOR EACH ROW 
BEGIN 
	SELECT operacion_seq.nextval INTO :new.num_operacion from dual; 
END;

CREATE OR REPLACE TYPE poseer_udt AS OBJECT(
	cliente number(8),
	nCuenta number(20));

CREATE TABLE poseer OF poseer_udt(
	CONSTRAINT pk_poseer PRIMARY KEY(cliente,nCuenta),
	CONSTRAINT fk_cliente_poseer FOREIGN KEY(cliente) REFERENCES cliente(dni),
	CONSTRAINT fk_cuenta_poseer FOREIGN KEY(nCuenta) REFERENCES cuenta(nCuenta));

