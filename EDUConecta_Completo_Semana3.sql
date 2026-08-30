-- EDUConecta - Base de Datos III
-- Modelo Objeto-Relacional en Oracle
-- Grupo A


-- ANEXO A: Tipos de objeto y tablas

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

CREATE OR REPLACE TYPE BODY TIPO_DIRECCION AS

    CONSTRUCTOR FUNCTION TIPO_DIRECCION(
        p_calle  VARCHAR2,
        p_ciudad VARCHAR2,
        p_lat    NUMBER,
        p_lon    NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN

        -- la ubicacion es obligatoria
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


CREATE OR REPLACE TYPE TIPO_ESTUDIANTE AS OBJECT
(
    id_estudiante NUMBER,
    nombre        VARCHAR2(100),
    email         VARCHAR2(100),
    direccion     TIPO_DIRECCION,

    MAP MEMBER FUNCTION obtener_id RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY TIPO_ESTUDIANTE AS

    MAP MEMBER FUNCTION obtener_id
    RETURN NUMBER IS
    BEGIN
        RETURN SELF.id_estudiante;
    END;

END;
/

CREATE TABLE TABLA_ESTUDIANTES OF TIPO_ESTUDIANTE
(
    id_estudiante PRIMARY KEY
);


-- cada modulo puede tener un prerrequisito, que apunta a otro TIPO_MODULO por REF
CREATE OR REPLACE TYPE TIPO_MODULO AS OBJECT
(
    id_modulo          NUMBER,
    nombre             VARCHAR2(100),
    descripcion        VARCHAR2(300),
    ref_prerrequisito  REF TIPO_MODULO
);
/

CREATE TABLE TABLA_MODULOS OF TIPO_MODULO
(
    id_modulo PRIMARY KEY
);

CREATE OR REPLACE TYPE TIPO_MODULO_REF_TAB
AS TABLE OF REF TIPO_MODULO;
/

CREATE OR REPLACE TYPE TIPO_CURSO AS OBJECT
(
    id_curso     NUMBER,
    nombre       VARCHAR2(100),
    descripcion  VARCHAR2(300),
    modulos      TIPO_MODULO_REF_TAB
);
/

CREATE TABLE TABLA_CURSOS OF TIPO_CURSO
(
    id_curso PRIMARY KEY
)
NESTED TABLE modulos
STORE AS curso_modulos_ref_tab;


-- la matricula conecta estudiante y curso mediante dos REF
CREATE OR REPLACE TYPE TIPO_MATRICULA AS OBJECT
(
    id_matricula    NUMBER,
    fecha           DATE,
    pensum          VARCHAR2(100),

    ref_estudiante  REF TIPO_ESTUDIANTE,
    ref_curso       REF TIPO_CURSO
);
/

CREATE TABLE TABLA_MATRICULAS OF TIPO_MATRICULA
(
    id_matricula PRIMARY KEY
);


DESCRIBE TIPO_DIRECCION;
DESCRIBE TIPO_ESTUDIANTE;
DESCRIBE TIPO_MODULO;
DESCRIBE TIPO_CURSO;
DESCRIBE TIPO_MATRICULA;


-- ANEXO B: Datos de prueba

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


-- ANEXO C: Operaciones CRUD

-- READ

-- estudiantes con su direccion (objeto anidado)
SELECT
    e.id_estudiante,
    e.nombre,
    e.email,
    e.direccion.calle      AS calle,
    e.direccion.ciudad     AS ciudad
FROM TABLA_ESTUDIANTES e
ORDER BY e.id_estudiante;

-- cursos y sus modulos, con TABLE() y DEREF()
SELECT
    c.id_curso,
    c.nombre                          AS curso,
    DEREF(t.COLUMN_VALUE).id_modulo   AS id_modulo,
    DEREF(t.COLUMN_VALUE).nombre      AS modulo
FROM TABLA_CURSOS c,
     TABLE(c.modulos) t
ORDER BY c.id_curso, id_modulo;

-- matriculas con DEREF de sus dos REF
SELECT
    m.id_matricula,
    m.fecha,
    m.pensum,
    DEREF(m.ref_estudiante).nombre    AS estudiante,
    DEREF(m.ref_curso).nombre         AS curso
FROM TABLA_MATRICULAS m
ORDER BY m.id_matricula;

-- cadena de prerrequisitos de un modulo
SELECT
    m.id_modulo,
    m.nombre                              AS modulo,
    DEREF(m.ref_prerrequisito).nombre     AS prerrequisito
FROM TABLA_MODULOS m
ORDER BY m.id_modulo;

-- distancia entre cada estudiante y el estudiante 1, usando distancia_a()
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


-- UPDATE

UPDATE TABLA_ESTUDIANTES e
SET e.email = 'matias.ruiz2@educonecta.com'
WHERE e.id_estudiante = 1;

UPDATE TABLA_ESTUDIANTES e
SET e.direccion.referencia = 'Frente a la plaza principal'
WHERE e.id_estudiante = 1;

-- agregar un modulo mas al curso 1, que solo tenia 2
INSERT INTO TABLE(
    SELECT c.modulos
    FROM TABLA_CURSOS c
    WHERE c.id_curso = 1
)
SELECT REF(m)
FROM TABLA_MODULOS m
WHERE m.id_modulo = 3;


-- DELETE

DELETE FROM TABLA_MATRICULAS
WHERE id_matricula = 3;

-- quitar el modulo agregado antes, sin borrar la fila del curso
DELETE FROM TABLE(
    SELECT c.modulos
    FROM TABLA_CURSOS c
    WHERE c.id_curso = 1
) t
WHERE DEREF(t.COLUMN_VALUE).id_modulo = 3;

COMMIT;


-- ANEXO D: Integridad referencial y consistencia (Semana 3)

-- IS DANGLING sobre cada REF del esquema
SELECT
    m.id_modulo,
    m.nombre,
    CASE
        WHEN m.ref_prerrequisito IS NULL THEN 'SIN PRERREQUISITO'
        WHEN m.ref_prerrequisito IS DANGLING THEN 'REF ROTA'
        ELSE 'REF VALIDA'
    END AS estado_ref_prerrequisito
FROM TABLA_MODULOS m
ORDER BY m.id_modulo;

SELECT
    mt.id_matricula,
    CASE WHEN mt.ref_estudiante IS DANGLING THEN 'REF ROTA' ELSE 'REF VALIDA' END AS estado_ref_estudiante
FROM TABLA_MATRICULAS mt
ORDER BY mt.id_matricula;

SELECT
    mt.id_matricula,
    CASE WHEN mt.ref_curso IS DANGLING THEN 'REF ROTA' ELSE 'REF VALIDA' END AS estado_ref_curso
FROM TABLA_MATRICULAS mt
ORDER BY mt.id_matricula;

SELECT
    c.id_curso,
    CASE WHEN t.COLUMN_VALUE IS DANGLING THEN 'REF ROTA' ELSE 'REF VALIDA' END AS estado_ref_modulo
FROM TABLA_CURSOS c,
     TABLE(c.modulos) t
ORDER BY c.id_curso;


-- demostracion: que pasa si se elimina el objeto referenciado
SAVEPOINT antes_de_prueba_dangling;

DELETE FROM TABLA_ESTUDIANTES
WHERE id_estudiante = 2;

SELECT
    mt.id_matricula,
    CASE WHEN mt.ref_estudiante IS DANGLING THEN 'SI - REF ROTA' ELSE 'NO - REF OK' END AS ref_estudiante_dangling,
    DEREF(mt.ref_curso).nombre AS curso
FROM TABLA_MATRICULAS mt
WHERE mt.id_matricula = 2;

ROLLBACK TO antes_de_prueba_dangling;

SELECT
    mt.id_matricula,
    CASE WHEN mt.ref_estudiante IS DANGLING THEN 'SI - REF ROTA' ELSE 'NO - REF OK' END AS ref_estudiante_dangling
FROM TABLA_MATRICULAS mt
WHERE mt.id_matricula = 2;


-- consistencia de identificadores entre estructuras

SELECT
    mt.id_matricula,
    DEREF(mt.ref_estudiante).id_estudiante AS id_estudiante_referenciado,
    e.id_estudiante                        AS id_estudiante_real,
    e.nombre                               AS nombre_estudiante
FROM TABLA_MATRICULAS mt
JOIN TABLA_ESTUDIANTES e
  ON e.id_estudiante = DEREF(mt.ref_estudiante).id_estudiante
ORDER BY mt.id_matricula;

SELECT
    mt.id_matricula,
    DEREF(mt.ref_curso).id_curso AS id_curso_referenciado,
    c.id_curso                   AS id_curso_real,
    c.nombre                     AS nombre_curso
FROM TABLA_MATRICULAS mt
JOIN TABLA_CURSOS c
  ON c.id_curso = DEREF(mt.ref_curso).id_curso
ORDER BY mt.id_matricula;

-- debe devolver cero filas
SELECT
    c.id_curso,
    DEREF(t.COLUMN_VALUE).id_modulo AS id_modulo_huerfano
FROM TABLA_CURSOS c,
     TABLE(c.modulos) t
WHERE DEREF(t.COLUMN_VALUE).id_modulo NOT IN (
    SELECT id_modulo FROM TABLA_MODULOS
);

SELECT
    c.id_curso,
    c.nombre,
    COUNT(mt.id_matricula) AS total_matriculas
FROM TABLA_CURSOS c
LEFT JOIN TABLA_MATRICULAS mt
  ON DEREF(mt.ref_curso).id_curso = c.id_curso
GROUP BY c.id_curso, c.nombre
ORDER BY c.id_curso;

SELECT
    c.id_curso,
    c.nombre,
    COUNT(t.COLUMN_VALUE) AS total_modulos
FROM TABLA_CURSOS c,
     TABLE(c.modulos) t
GROUP BY c.id_curso, c.nombre
ORDER BY c.id_curso;
