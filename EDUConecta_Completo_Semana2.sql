-- =====================================================================
-- EDUConecta - Base de Datos III - Modelo Objeto-Relacional en Oracle
-- Semana 1 y Semana 2 - Script SQL completo (Anexos A + B + C)
-- =====================================================================


-- #########################################################################
-- ## ANEXO A. Script_Educonecta.sql
-- ## Tipos de objeto y tablas (Semana 1 y Semana 2)
-- #########################################################################

-- =====================================================================
-- SEMANA 1 Y SEMANA 2 - EDUConecta
-- Base de Datos III
-- Modelo Objeto-Relacional - Oracle
-- =====================================================================
 
-- =====================================================================
-- 1. TIPO DE OBJETO ANIDADO: TIPO_DIRECCION
-- =====================================================================
 
CREATE OR REPLACE TYPE TIPO_DIRECCION AS OBJECT
(
    calle       VARCHAR2(100),
    ciudad      VARCHAR2(50),
    referencia  VARCHAR2(200),
    latitud     NUMBER(9,6),
    longitud    NUMBER(9,6),
 
    CONSTRUCTOR FUNCTION TIPO_DIRECCION(
        p_calle  VARCHAR2,
        p_ciudad VARCHAR2,
        p_lat    NUMBER,
        p_lon    NUMBER
    ) RETURN SELF AS RESULT,
 
    MEMBER FUNCTION distancia_a(
        otra TIPO_DIRECCION
    ) RETURN NUMBER
);
/
 
-- =====================================================================
-- 2. CUERPO DEL TIPO TIPO_DIRECCION
-- =====================================================================
 
CREATE OR REPLACE TYPE BODY TIPO_DIRECCION AS
 
    CONSTRUCTOR FUNCTION TIPO_DIRECCION(
        p_calle  VARCHAR2,
        p_ciudad VARCHAR2,
        p_lat    NUMBER,
        p_lon    NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
 
        -- Validación de negocio:
        -- la ubicación geográfica es obligatoria.
 
        IF p_lat IS NULL OR p_lon IS NULL THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Latitud y longitud son obligatorias'
            );
        END IF;
 
        SELF.calle      := p_calle;
        SELF.ciudad     := p_ciudad;
        SELF.referencia := NULL;
        SELF.latitud    := p_lat;
        SELF.longitud   := p_lon;
 
        RETURN;
    END;
 
 
    MEMBER FUNCTION distancia_a(
        otra TIPO_DIRECCION
    ) RETURN NUMBER IS
 
        v_radio CONSTANT NUMBER := 6371;
        v_dlat  NUMBER;
        v_dlon  NUMBER;
        v_a     NUMBER;
        v_c     NUMBER;
 
    BEGIN
 
        IF otra IS NULL THEN
            RETURN NULL;
        END IF;
 
        v_dlat :=
            (otra.latitud - SELF.latitud)
            * ACOS(-1) / 180;
 
        v_dlon :=
            (otra.longitud - SELF.longitud)
            * ACOS(-1) / 180;
 
        v_a :=
              SIN(v_dlat / 2) * SIN(v_dlat / 2)
            + COS(SELF.latitud * ACOS(-1) / 180)
            * COS(otra.latitud * ACOS(-1) / 180)
            * SIN(v_dlon / 2) * SIN(v_dlon / 2);
 
        v_c :=
            2 * ATAN2(
                SQRT(v_a),
                SQRT(1 - v_a)
            );
 
        RETURN v_radio * v_c;
 
    END;
 
END;
/
 
-- =====================================================================
-- 3. TIPO DE OBJETO PRINCIPAL: TIPO_ESTUDIANTE
-- =====================================================================
 
CREATE OR REPLACE TYPE TIPO_ESTUDIANTE AS OBJECT
(
    id_estudiante NUMBER,
    nombre        VARCHAR2(100),
    email         VARCHAR2(100),
    direccion     TIPO_DIRECCION,
 
    MAP MEMBER FUNCTION obtener_id RETURN NUMBER
);
/
 
-- =====================================================================
-- 4. CUERPO DEL TIPO TIPO_ESTUDIANTE
-- =====================================================================
 
CREATE OR REPLACE TYPE BODY TIPO_ESTUDIANTE AS
 
    MAP MEMBER FUNCTION obtener_id
    RETURN NUMBER IS
    BEGIN
        RETURN SELF.id_estudiante;
    END;
 
END;
/
 
-- =====================================================================
-- 5. TABLA DE OBJETOS: TABLA_ESTUDIANTES
-- =====================================================================
 
CREATE TABLE TABLA_ESTUDIANTES OF TIPO_ESTUDIANTE
(
    id_estudiante PRIMARY KEY
);
 
-- =====================================================================
-- 6. TIPO DE OBJETO: TIPO_MODULO
-- =====================================================================
--
-- Cada módulo puede tener un prerrequisito que apunta a otro
-- objeto TIPO_MODULO mediante REF.
--
-- Se almacena en TABLA_MODULOS para que los REF tengan identidad
-- de objeto (OID).
-- =====================================================================
 
CREATE OR REPLACE TYPE TIPO_MODULO AS OBJECT
(
    id_modulo          NUMBER,
    nombre             VARCHAR2(100),
    descripcion        VARCHAR2(300),
    ref_prerrequisito  REF TIPO_MODULO
);
/
 
-- =====================================================================
-- 7. TABLA DE OBJETOS: TABLA_MODULOS
-- =====================================================================
 
CREATE TABLE TABLA_MODULOS OF TIPO_MODULO
(
    id_modulo PRIMARY KEY
);
 
-- =====================================================================
-- 8. COLECCIÓN DE REFERENCIAS A MÓDULOS
-- =====================================================================
 
CREATE OR REPLACE TYPE TIPO_MODULO_REF_TAB
AS TABLE OF REF TIPO_MODULO;
/
 
-- =====================================================================
-- 9. TIPO DE OBJETO: TIPO_CURSO
-- =====================================================================
 
CREATE OR REPLACE TYPE TIPO_CURSO AS OBJECT
(
    id_curso     NUMBER,
    nombre       VARCHAR2(100),
    descripcion  VARCHAR2(300),
    modulos      TIPO_MODULO_REF_TAB
);
/
 
-- =====================================================================
-- 10. TABLA DE OBJETOS: TABLA_CURSOS
-- =====================================================================
 
CREATE TABLE TABLA_CURSOS OF TIPO_CURSO
(
    id_curso PRIMARY KEY
)
NESTED TABLE modulos
STORE AS curso_modulos_ref_tab;
 
-- =====================================================================
-- 11. TIPO DE OBJETO: TIPO_MATRICULA
-- =====================================================================
--
-- La matrícula utiliza dos REF:
--    REF -> estudiante
--    REF -> curso
-- =====================================================================
 
CREATE OR REPLACE TYPE TIPO_MATRICULA AS OBJECT
(
    id_matricula    NUMBER,
    fecha           DATE,
    pensum          VARCHAR2(100),
 
    ref_estudiante  REF TIPO_ESTUDIANTE,
    ref_curso       REF TIPO_CURSO
);
/
 
-- =====================================================================
-- 12. TABLA DE OBJETOS: TABLA_MATRICULAS
-- =====================================================================
 
CREATE TABLE TABLA_MATRICULAS OF TIPO_MATRICULA
(
    id_matricula PRIMARY KEY
);
 
-- =====================================================================
-- 13. VERIFICACIÓN DE TIPOS
-- =====================================================================
 
DESCRIBE TIPO_DIRECCION;
 
DESCRIBE TIPO_ESTUDIANTE;
 
DESCRIBE TIPO_MODULO;
 
DESCRIBE TIPO_CURSO;
 
DESCRIBE TIPO_MATRICULA;


-- #########################################################################
-- ## ANEXO B. Inserts_Educonecta.sql
-- ## Datos de prueba (export)
-- #########################################################################

/*
1. Inserts de TABLA_ESTUDIANTES
*/
 
INSERT INTO TABLA_ESTUDIANTES
VALUES
(
    TIPO_ESTUDIANTE
    (
        1,
        'Matias Ruiz',
        'matias.ruiz@educonecta.com',
        TIPO_DIRECCION
        (
            'Avenida Busch',
            'Santa Cruz de la Sierra',
            -17.769000,
            -63.182100
        )
    )
);
 
 
INSERT INTO TABLA_ESTUDIANTES
VALUES
(
    TIPO_ESTUDIANTE
    (
        2,
        'Franco Salas',
        'franco.salas@educonecta.com',
        TIPO_DIRECCION
        (
            'Avenida Santos Dumont',
            'Santa Cruz de la Sierra',
            -17.752500,
            -63.175800
        )
    )
);
 
 
INSERT INTO TABLA_ESTUDIANTES
VALUES
(
    TIPO_ESTUDIANTE
    (
        3,
        'Josep Rodriguez',
        'josep.rodriguez@educonecta.com',
        TIPO_DIRECCION
        (
            'Avenida Busch',
            'Santa Cruz de la Sierra',
            -17.805000,
            -63.179000
        )
    )
);
 
 
/*
2. Inserts de TABLA_MODULOS
*/
 
INSERT INTO TABLA_MODULOS
VALUES
(
    TIPO_MODULO
    (
        1,
        'Fundamentos de Programacion',
        'Conceptos iniciales de algoritmos y programacion.',
        NULL
    )
);
 
 
INSERT INTO TABLA_MODULOS
SELECT TIPO_MODULO
(
    2,
    'Programacion Orientada a Objetos',
    'Clases, objetos, encapsulamiento y herencia.',
    REF(m)
)
FROM TABLA_MODULOS m
WHERE m.id_modulo = 1;
 
 
INSERT INTO TABLA_MODULOS
VALUES
(
    TIPO_MODULO
    (
        3,
        'Fundamentos de Bases de Datos',
        'Conceptos de modelado y administracion de datos.',
        NULL
    )
);
 
 
INSERT INTO TABLA_MODULOS
SELECT TIPO_MODULO
(
    4,
    'Oracle Objeto-Relacional',
    'Tipos de objetos, referencias y colecciones en Oracle.',
    REF(m)
)
FROM TABLA_MODULOS m
WHERE m.id_modulo = 3;
 
 
INSERT INTO TABLA_MODULOS
SELECT TIPO_MODULO
(
    5,
    'Proyecto Integrador',
    'Aplicacion practica del modelo objeto-relacional.',
    REF(m)
)
FROM TABLA_MODULOS m
WHERE m.id_modulo = 4;
 
 
/*
3. Inserts de TABLA_CURSOS
*/
 
INSERT INTO TABLA_CURSOS
SELECT TIPO_CURSO
(
    1,
    'Programacion Orientada a Objetos',
    'Curso sobre desarrollo de aplicaciones orientadas a objetos.',
    TIPO_MODULO_REF_TAB
    (
        REF(m1),
        REF(m2)
    )
)
FROM TABLA_MODULOS m1,
     TABLA_MODULOS m2
WHERE m1.id_modulo = 1
AND m2.id_modulo = 2;
 
 
INSERT INTO TABLA_CURSOS
SELECT TIPO_CURSO
(
    2,
    'Bases de Datos III',
    'Curso de bases de datos objeto-relacionales con Oracle.',
    TIPO_MODULO_REF_TAB
    (
        REF(m1),
        REF(m2),
        REF(m3)
    )
)
FROM TABLA_MODULOS m1,
     TABLA_MODULOS m2,
     TABLA_MODULOS m3
WHERE m1.id_modulo = 3
AND m2.id_modulo = 4
AND m3.id_modulo = 5;
 
 
INSERT INTO TABLA_CURSOS
SELECT TIPO_CURSO
(
    3,
    'Desarrollo de Aplicaciones con Oracle',
    'Curso para integrar aplicaciones con bases de datos Oracle.',
    TIPO_MODULO_REF_TAB
    (
        REF(m1),
        REF(m2),
        REF(m3)
    )
)
FROM TABLA_MODULOS m1,
     TABLA_MODULOS m2,
     TABLA_MODULOS m3
WHERE m1.id_modulo = 2
AND m2.id_modulo = 3
AND m3.id_modulo = 4;
 
 
/*
4. Inserts de TABLA_MATRICULAS
*/
 
INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA
(
    1,
    DATE '2026-08-03',
    'Ingenieria de Sistemas - Plan 2026',
    REF(e),
    REF(c)
)
FROM TABLA_ESTUDIANTES e,
     TABLA_CURSOS c
WHERE e.id_estudiante = 1
AND c.id_curso = 2;
 
 
INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA
(
    2,
    DATE '2026-08-05',
    'Ingenieria de Sistemas - Plan 2026',
    REF(e),
    REF(c)
)
FROM TABLA_ESTUDIANTES e,
     TABLA_CURSOS c
WHERE e.id_estudiante = 2
AND c.id_curso = 1;
 
 
INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA
(
    3,
    DATE '2026-08-07',
    'Ingenieria de Sistemas - Plan 2026',
    REF(e),
    REF(c)
)
FROM TABLA_ESTUDIANTES e,
     TABLA_CURSOS c
WHERE e.id_estudiante = 3
AND c.id_curso = 3;
 
 
COMMIT;


-- #########################################################################
-- ## ANEXO C. CRUD_Educonecta.sql
-- ## Operaciones CRUD, DEREF y TABLE()
-- #########################################################################

-- =====================================================================
-- CRUD_Educonecta.sql
-- EDUConecta - Operaciones CRUD (Tema 1.6) sobre el modelo objeto-relacional
-- Complementa a Script_Educonecta.sql e Inserts_Educonecta.sql
-- =====================================================================
 
 
-- =====================================================================
-- C - CREATE (ya cubierto en Inserts_Educonecta.sql)
-- =====================================================================
-- Los INSERT de TABLA_ESTUDIANTES, TABLA_MODULOS, TABLA_CURSOS y
-- TABLA_MATRICULAS ya constituyen la operacion CREATE del CRUD.
-- Se referencian aqui solo como recordatorio; no se repiten.
 
 
-- =====================================================================
-- R - READ
-- =====================================================================
 
-- R1. Listado simple de estudiantes con su direccion (objeto anidado)
SELECT
    e.id_estudiante,
    e.nombre,
    e.email,
    e.direccion.calle      AS calle,
    e.direccion.ciudad     AS ciudad
FROM TABLA_ESTUDIANTES e
ORDER BY e.id_estudiante;
 
 
-- R2. Cursos y sus modulos, usando TABLE() para recorrer la coleccion
--     anidada (TIPO_MODULO_REF_TAB) y DEREF() para resolver cada REF
--     y obtener el objeto TIPO_MODULO completo.
SELECT
    c.id_curso,
    c.nombre                          AS curso,
    DEREF(t.COLUMN_VALUE).id_modulo   AS id_modulo,
    DEREF(t.COLUMN_VALUE).nombre      AS modulo
FROM TABLA_CURSOS c,
     TABLE(c.modulos) t
ORDER BY c.id_curso, id_modulo;
 
 
-- R3. Matriculas con DEREF de sus dos REF (estudiante y curso)
SELECT
    m.id_matricula,
    m.fecha,
    m.pensum,
    DEREF(m.ref_estudiante).nombre    AS estudiante,
    DEREF(m.ref_curso).nombre         AS curso
FROM TABLA_MATRICULAS m
ORDER BY m.id_matricula;
 
 
-- R4. Cadena de prerrequisitos de un modulo, usando DEREF sobre el
--     REF recursivo ref_prerrequisito de TIPO_MODULO
SELECT
    m.id_modulo,
    m.nombre                              AS modulo,
    DEREF(m.ref_prerrequisito).nombre     AS prerrequisito
FROM TABLA_MODULOS m
ORDER BY m.id_modulo;
 
 
-- R5. Uso de la funcion propia distancia_a() del objeto anidado
--     TIPO_DIRECCION: distancia (km) entre cada estudiante y el
--     estudiante con id_estudiante = 1
SELECT
    e.id_estudiante,
    e.nombre,
    ROUND(
        e.direccion.distancia_a(
            (SELECT e2.direccion
             FROM TABLA_ESTUDIANTES e2
             WHERE e2.id_estudiante = 1)
        ), 2
    ) AS distancia_km
FROM TABLA_ESTUDIANTES e
WHERE e.id_estudiante <> 1;
 
 
-- =====================================================================
-- U - UPDATE
-- =====================================================================
 
-- U1. Actualizar un atributo simple del objeto principal
UPDATE TABLA_ESTUDIANTES e
SET e.email = 'matias.ruiz2@educonecta.com'
WHERE e.id_estudiante = 1;
 
 
-- U2. Actualizar un atributo del objeto anidado (TIPO_DIRECCION)
--     usando notacion de punto
UPDATE TABLA_ESTUDIANTES e
SET e.direccion.referencia = 'Frente a la plaza principal'
WHERE e.id_estudiante = 1;
 
 
-- U3. Actualizar un elemento dentro de la coleccion anidada de un
--     curso (agregar un modulo mas al curso 1, que solo tenia 2)
INSERT INTO TABLE(
    SELECT c.modulos
    FROM TABLA_CURSOS c
    WHERE c.id_curso = 1
)
SELECT REF(m)
FROM TABLA_MODULOS m
WHERE m.id_modulo = 3;
 
 
-- =====================================================================
-- D - DELETE
-- =====================================================================
 
-- D1. Eliminar una matricula (tabla transaccional)
DELETE FROM TABLA_MATRICULAS
WHERE id_matricula = 3;
 
 
-- D2. Eliminar un modulo especifico dentro de la coleccion anidada
--     de un curso (quitar el modulo agregado en U3, id_modulo = 3,
--     del curso 1), sin borrar la fila del curso
DELETE FROM TABLE(
    SELECT c.modulos
    FROM TABLA_CURSOS c
    WHERE c.id_curso = 1
) t
WHERE DEREF(t.COLUMN_VALUE).id_modulo = 3;
 
 
COMMIT;
