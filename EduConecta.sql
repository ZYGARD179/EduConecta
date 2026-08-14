CREATE OR REPLACE TYPE TIPO_DIRECCION AS OBJECT 
(
    calle       VARCHAR2(100),
    ciudad      VARCHAR2(50),
    referencia  VARCHAR2(200),
    latitud     NUMBER(9,6),
    longitud    NUMBER(9,6),

    CONSTRUCTOR FUNCTION TIPO_DIRECCION(
        p_calle VARCHAR2,
        p_ciudad VARCHAR2,
        p_lat NUMBER,
        p_lon NUMBER
    ) RETURN SELF AS RESULT,

    MEMBER FUNCTION distancia_a(
        otra TIPO_DIRECCION
    ) RETURN NUMBER
);
/